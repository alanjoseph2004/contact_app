import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'contact_logic.dart';
import '../services/contact_service.dart' as contact_service;
import '../services/ui_service.dart';

class DetailedContactAllPage extends StatefulWidget {
  final Contact contact;

  const DetailedContactAllPage({
    super.key,
    required this.contact,
  });

  @override
  State<DetailedContactAllPage> createState() => _DetailedContactAllPageState();
}

class _DetailedContactAllPageState extends State<DetailedContactAllPage> {
  late Contact _contact;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _allContactData;
  
  // Color scheme to match contacts page
  static const Color _primaryBlue = Color(0xFF4285F4);
  static const Color _textPrimary = Color(0xFF212121);
  static const Color _textSecondary = Color(0xFF757575);
  static const Color _textTertiary = Color(0xFF9E9E9E);
  static const Color _dividerColor = Color(0xFFE0E0E0);
  static const Color _backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
    _fetchContactDetails();
  }

  Future<void> _fetchContactDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _fetchAllContactData();
      
      // Update the contact with the fetched data
      setState(() {
        _contact = _mergeContactData();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading contact details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAllContactData() async {
    try {
      final response = await http.get(
        Uri.parse('https://contact.krisko.in/contact/contact/${_contact.id}/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _allContactData = json.decode(response.body);
      } else {
        debugPrint('All contact API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching all contact: $e');
    }
  }

  Contact _mergeContactData() {
    // Start with the original contact
    Contact mergedContact = _contact;

    // If we have all contact data, use it as the primary source
    if (_allContactData != null) {
      mergedContact = _parseAllContactResponse(_allContactData!);
    }

    return mergedContact;
  }

  Contact _parseAllContactResponse(Map<String, dynamic> data) {
    final referredByData = data['referred_by'] as Map<String, dynamic>?;
    
    return Contact(
      id: _safeParseInt(data['id'])!,
      referredBy: _safeParseInt(referredByData?['referred_id']),
      firstName: data['first_name']?.toString() ?? '',
      lastName: data['last_name']?.toString(),
      email: data['email']?.toString(),
      countryCode: _parseCountryCode(data['country_code']),
      phone: data['phone']?.toString() ?? '',
      note: data['note']?.toString(),
      district: _extractNestedIntValue(data['district']),
      assemblyConstituency: _extractNestedIntValue(data['assembly_constituency']),
      partyBlock: _extractNestedIntValue(data['party_block']),
      partyConstituency: _extractNestedIntValue(data['party_constituency']),
      booth: _extractNestedIntValue(data['booth']),
      parliamentaryConstituency: _extractNestedIntValue(data['parliamentary_constituency']),
      localBody: _extractNestedIntValue(data['local_body']),
      ward: _extractNestedIntValue(data['ward']),
      houseName: data['house_name']?.toString(),
      houseNumber: _safeParseInt(data['house_number']),
      city: data['city']?.toString(),
      postOffice: data['post_office']?.toString(),
      pinCode: data['pin_code']?.toString(),
      tags: _extractTagIds(data['tags']),
      isPrimaryContact: data['is_primary_contact'] == true,
      type: ContactType.all,
      referralDetails: referredByData,
    );
  }

  // Helper method to safely parse integers
  int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        debugPrint('Error parsing int from string: $value');
        return null;
      }
    }
    return null;
  }

  // Helper method to parse country code, removing + if present
  String _parseCountryCode(dynamic countryCode) {
    if (countryCode == null) return '91'; // Default
    String code = countryCode.toString();
    if (code.startsWith('+')) {
      code = code.substring(1);
    }
    return code;
  }

  // Helper method to extract integer values from nested objects
  int? _extractNestedIntValue(dynamic field) {
    if (field == null) return null;
    if (field is int) return field;
    if (field is Map<String, dynamic>) {
      // Try to find the first non-null integer value in the map
      for (var value in field.values) {
        final intValue = _safeParseInt(value);
        if (intValue != null) return intValue;
      }
    }
    return _safeParseInt(field);
  }

  List<int>? _extractTagIds(dynamic tagsData) {
    if (tagsData is List) {
      return tagsData
          .where((tag) => tag is Map<String, dynamic> && tag['id'] != null)
          .map<int>((tag) => _safeParseInt(tag['id']) ?? 0)
          .where((id) => id > 0)
          .toList();
    }
    return null;
  }

  // Contact action methods
  Future<void> _handleCall() async {
    if (!contact_service.ContactService.isValidPhoneNumber(_contact.phoneNumber)) {
      UIService.showErrorSnackBar(context, 'Invalid phone number');
      return;
    }
    
    final success = await contact_service.ContactService.makeCall(_contact.phoneNumber);
    if (!success) {
      UIService.showErrorSnackBar(context, 'Unable to make call');
    }
  }

  Future<void> _handleMessage() async {
    if (!contact_service.ContactService.isValidPhoneNumber(_contact.phoneNumber)) {
      UIService.showErrorSnackBar(context, 'Invalid phone number');
      return;
    }

    // Show options for different messaging apps
    final option = await UIService.showOptionsBottomSheet<String>(
      context,
      title: 'Send Message',
      options: [
        const BottomSheetOption<String>(
          icon: Icons.chat,
          title: 'WhatsApp',
          subtitle: 'Send message via WhatsApp',
          value: 'whatsapp',
          color: Color(0xFF25D366),
        ),
        const BottomSheetOption<String>(
          icon: Icons.sms,
          title: 'SMS',
          subtitle: 'Send text message',
          value: 'sms',
          color: Color(0xFF4285F4),
        ),
      ],
    );

    if (option != null) {
      bool success = false;
      
      if (option == 'whatsapp') {
        success = await contact_service.ContactService.sendWhatsAppMessage(_contact.phoneNumber);
        if (!success) {
          UIService.showErrorSnackBar(context, 'Unable to open WhatsApp');
        }
      } else if (option == 'sms') {
        // For SMS, we'll use the same URL launcher approach
        success = await contact_service.ContactService.makeCall('sms:${_contact.phoneNumber}');
        if (!success) {
          UIService.showErrorSnackBar(context, 'Unable to open messaging app');
        }
      }
    }
  }

  Future<void> _handleShare() async {
    // Show options for different sharing methods
    final option = await UIService.showOptionsBottomSheet<String>(
      context,
      title: 'Share Contact',
      options: [
        const BottomSheetOption<String>(
          icon: Icons.share,
          title: 'Share as Text',
          subtitle: 'Share contact details as text',
          value: 'text',
          color: Color(0xFF4285F4),
        ),
        const BottomSheetOption<String>(
          icon: Icons.contact_page,
          title: 'Share as VCard',
          subtitle: 'Share as contact file',
          value: 'vcard',
          color: Color(0xFF34A853),
        ),
        const BottomSheetOption<String>(
          icon: Icons.copy,
          title: 'Copy to Clipboard',
          subtitle: 'Copy contact details',
          value: 'copy',
          color: Color(0xFFFF9800),
        ),
      ],
    );

    if (option != null) {
      bool success = false;
      
      switch (option) {
        case 'text':
          success = await contact_service.ContactService.shareContact(
            name: _contact.name,
            phoneNumber: _contact.phoneNumber,
            email: _contact.email,
            address: _contact.fullAddress.isNotEmpty ? _contact.fullAddress : null,
            note: _contact.note,
          );
          break;
        case 'vcard':
          success = await contact_service.ContactService.shareContactAsVCard(
            name: _contact.name,
            phoneNumber: _contact.phoneNumber,
            email: _contact.email,
            address: _contact.fullAddress.isNotEmpty ? _contact.fullAddress : null,
            note: _contact.note,
          );
          break;
        case 'copy':
          success = await contact_service.ContactService.copyToClipboard(
            name: _contact.name,
            phoneNumber: _contact.phoneNumber,
            email: _contact.email,
          );
          if (success) {
            UIService.showSuccessSnackBar(context, 'Contact details copied to clipboard');
          }
          break;
      }
      
      if (!success && option != 'copy') {
        UIService.showErrorSnackBar(context, 'Unable to share contact');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textPrimary, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _contact.name,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          if (_errorMessage != null)
            IconButton(
              icon: Icon(Icons.refresh, color: _primaryBlue),
              onPressed: _fetchContactDetails,
              tooltip: 'Retry',
            ),
        ],
      ),
      body: _isLoading 
        ? const Center(
            child: CircularProgressIndicator(
              color: _primaryBlue,
            ),
          )
        : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: _textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchContactDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header with quick actions
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile section
                        Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              backgroundColor: _primaryBlue.withOpacity(0.1),
                              backgroundImage: _contact.avatarUrl != null ? NetworkImage(_contact.avatarUrl!) : null,
                              radius: 32,
                              child: _contact.avatarUrl == null ? Text(
                                _contact.name.isNotEmpty ? _contact.name[0].toUpperCase() : "?",
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: _primaryBlue,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ) : null,
                            ),
                            const SizedBox(width: 16),
                            // Contact info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _contact.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: _textPrimary,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.phone, size: 16, color: _textSecondary),
                                      const SizedBox(width: 6),
                                      Text(
                                        _contact.phoneNumber,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: _textSecondary,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (_contact.email != null && _contact.email!.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(Icons.email, size: 16, color: _textSecondary),
                                        const SizedBox(width: 6),
                                        Text(
                                          _contact.email!,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: _textSecondary,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 14),
                        
                        // Divider
                        Container(
                          height: 1,
                          color: _dividerColor,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Quick action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(Icons.phone, 'Call', _handleCall, isOutlined: false),
                            _buildActionButton(Icons.message, 'Message', _handleMessage, isOutlined: true),
                            _buildActionButton(Icons.share, 'Share', _handleShare, isOutlined: true),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Contact Details Section
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Address information
                        if (_contact.fullAddress.isNotEmpty)
                          _buildDetailRow('Address', _contact.fullAddress),
                        
                        // City information
                        if (_contact.city != null && _contact.city!.isNotEmpty)
                          _buildDetailRow('City', _contact.city!),
                        
                        // District information
                        if (_getDisplayValue('district') != null)
                          _buildDetailRow('District', _getDisplayValue('district')!),
                        
                        // Assembly Constituency information
                        if (_getDisplayValue('assembly_constituency') != null)
                          _buildDetailRow('Assembly Constituency', _getDisplayValue('assembly_constituency')!),
                        
                        // Parliamentary Constituency information
                        if (_getDisplayValue('parliamentary_constituency') != null)
                          _buildDetailRow('Parliamentary Constituency', _getDisplayValue('parliamentary_constituency')!),
                        
                        // Local Body information
                        if (_getDisplayValue('local_body') != null)
                          _buildDetailRow('Local Body', _getDisplayValue('local_body')!),

                        // Party Block information
                        if (_getDisplayValue('party_block') != null)
                          _buildDetailRow('Party Block', _getDisplayValue('party_block')!),

                        // Party Constituency information
                        // if (_getDisplayValue('party_constituency') != null)
                        //  _buildDetailRow('Party Constituency', _getDisplayValue('party_constituency')!),    
                        
                        // Ward information
                        if (_contact.ward != null)
                          _buildDetailRow('Ward', 'Ward: ${_contact.ward}'),
                        
                        // Booth information
                        if (_getDisplayValue('booth') != null)
                          _buildDetailRow('Booth', _getDisplayValue('booth')!),
                        
                        // Post Office information
                        if (_contact.postOffice != null && _contact.postOffice!.isNotEmpty)
                          _buildDetailRow('Post Office', _contact.postOffice!),
                        
                        // PIN Code information
                        if (_contact.pinCode != null && _contact.pinCode!.isNotEmpty)
                          _buildDetailRow('PIN Code', _contact.pinCode!),
                      ],
                    ),
                  ),

                  // Tags Section
                  if (_hasValidTags()) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _getTagWidgets(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Referral Information Section
                  if (_contact.referralDetails != null) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Referral Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Referral ID
                          if (_contact.referralDetails!['referred_id'] != null)
                            _buildDetailRow('Referred by ID', _contact.referralDetails!['referred_id'].toString()),
                          
                          // Referral Name
                          if (_contact.referralDetails!['referred_first_name'] != null)
                            _buildDetailRow('Referred by Name', 
                              '${_contact.referralDetails!['referred_first_name']} ${_contact.referralDetails!['referred_last_name'] ?? ''}'),
                          
                          // Referral Phone
                          if (_contact.referralDetails!['referred_phone'] != null)
                            _buildDetailRow('Referral Phone', 
                              '${_contact.referralDetails!['referred_country_code'] ?? ''} ${_contact.referralDetails!['referred_phone'] ?? ''}'),
                        ],
                      ),
                    ),
                  ],

                  // Notes Section
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _contact.note ?? 'No notes available.',
                          style: TextStyle(
                            fontSize: 15,
                            color: _contact.note == null ? _textTertiary : _textPrimary,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String? _getDisplayValue(String field) {
    // Check if we have the data from API response
    if (_allContactData != null && _allContactData![field] != null) {
      final fieldData = _allContactData![field];
      if (fieldData is Map<String, dynamic>) {
        return fieldData[field]?.toString();
      } else if (fieldData is String || fieldData is int) {
        return fieldData.toString();
      }
    }
    
    return null;
  }

  bool _hasValidTags() {
    // Check for tags in API response
    if (_allContactData != null && _allContactData!['tags'] is List) {
      final tags = _allContactData!['tags'] as List;
      return tags.isNotEmpty;
    }
    
    return false;
  }

  List<Widget> _getTagWidgets() {
    List<dynamic> tags = [];
    
    // Get tags from API response
    if (_allContactData != null && _allContactData!['tags'] is List) {
      tags = _allContactData!['tags'] as List;
    }
    
    return tags.map((tag) {
      if (tag is Map<String, dynamic>) {
        final tagName = tag['tag_name']?.toString() ?? 'Unknown';
        final tagCategory = tag['tag_category']?.toString() ?? '';
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _primaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tagName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
              if (tagCategory.isNotEmpty)
                Text(
                  tagCategory,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {bool isOutlined = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : _primaryBlue,
          borderRadius: BorderRadius.circular(24),
          border: isOutlined ? Border.all(color: _primaryBlue, width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isOutlined ? _primaryBlue : Colors.white, 
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isOutlined ? _primaryBlue : Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: _textSecondary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: _textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}