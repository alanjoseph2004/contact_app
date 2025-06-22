import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'contact_logic.dart';

class DetailedContactPage extends StatefulWidget {
  final Contact contact;

  const DetailedContactPage({
    super.key,
    required this.contact,
  });

  @override
  State<DetailedContactPage> createState() => _DetailedContactPageState();
}

class _DetailedContactPageState extends State<DetailedContactPage> {
  late Contact _contact;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _apiContactData;
  
  // Updated to match contacts page color scheme
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
      String apiUrl;
      
      // Determine which API endpoint to use based on contact type
      if (_contact.type == ContactType.primary && _contact.primaryContactId != null) {
        // Use primary contact endpoint
        apiUrl = 'http://51.21.152.136:8000/contact/primary-contact/${_contact.primaryContactId}/';
      } else {
        // Use regular contact endpoint
        apiUrl = 'http://51.21.152.136:8000/contact/contact/${_contact.id}/';
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _apiContactData = data;
          _contact = _parseApiResponse(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load contact details. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading contact details: $e';
        _isLoading = false;
      });
    }
  }

  Contact _parseApiResponse(Map<String, dynamic> data) {
    // Check if this is a primary contact response (has nested contact structure)
    if (data.containsKey('contact') && data['contact'] is Map<String, dynamic>) {
      final contactData = data['contact'] as Map<String, dynamic>;
      final connectionData = data['connection'] as Map<String, dynamic>?;
      
      return Contact(
        id: contactData['id'],
        referredBy: contactData['referred_by'],
        firstName: contactData['first_name'] ?? '',
        lastName: contactData['last_name'],
        email: contactData['email'],
        countryCode: contactData['country_code'] ?? '91',
        phone: contactData['phone'] ?? '',
        note: contactData['note'],
        district: contactData['district'],
        assemblyConstituency: contactData['assembly_constituency'],
        partyBlock: contactData['party_block'],
        partyConstituency: contactData['party_constituency'],
        booth: contactData['booth'],
        parliamentaryConstituency: contactData['parliamentary_constituency'],
        localBody: contactData['local_body'],
        ward: contactData['ward'],
        houseName: contactData['house_name'],
        houseNumber: contactData['house_number'],
        city: contactData['city'],
        postOffice: contactData['post_office'],
        pinCode: contactData['pin_code'],
        tags: contactData['tags'] != null ? List<int>.from(contactData['tags']) : null,
        isPrimaryContact: contactData['is_primary_contact'] ?? true,
        type: ContactType.primary,
        priority: data['priority'],
        connection: connectionData?['connection']?.toString(),
        primaryContactId: data['id'],
      );
    } else {
      // Regular contact response (flat structure)
      final referredByData = data['referred_by'] as Map<String, dynamic>?;
      
      return Contact(
        id: data['id'],
        referredBy: referredByData?['referred_id'],
        firstName: data['first_name'] ?? '',
        lastName: data['last_name'],
        email: data['email'],
        countryCode: data['country_code'] ?? '91',
        phone: data['phone'] ?? '',
        note: data['note'],
        district: data['district'],
        assemblyConstituency: data['assembly_constituency'],
        partyBlock: data['party_block'],
        partyConstituency: data['party_constituency'],
        booth: data['booth'],
        parliamentaryConstituency: data['parliamentary_constituency'],
        localBody: data['local_body'],
        ward: data['ward'],
        houseName: data['house_name'],
        houseNumber: data['house_number'],
        city: data['city'],
        postOffice: data['post_office'],
        pinCode: data['pin_code'],
        tags: data['tags'] != null ? List<int>.from(data['tags']) : null,
        isPrimaryContact: data['is_primary_contact'] ?? false,
        type: ContactType.all,
        referralDetails: referredByData,
      );
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
                  // Merged profile header with quick actions
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
                            // Avatar - updated to match contacts page style
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
                            // Priority number (replacing star) - Fixed property name
                            if (_contact.isPrimaryContact && _contact.priority != null)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: _primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${_contact.priority}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 14),
                        
                        // Divider - updated color
                        Container(
                          height: 1,
                          color: _dividerColor,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Quick action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(Icons.phone, 'Call', () {
                              // Implement call functionality
                            }, isOutlined: false),
                            _buildActionButton(Icons.message, 'Message', () {
                              // Implement message functionality
                            }, isOutlined: true),
                            _buildActionButton(Icons.share, 'Share', () {
                              // Implement share functionality
                            }, isOutlined: true),
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
                        
                        // Address information - Using fullAddress property
                        if (_contact.fullAddress.isNotEmpty)
                          _buildDetailRow('Address', _contact.fullAddress),
                        
                        // City information
                        if (_contact.city != null && _contact.city!.isNotEmpty)
                          _buildDetailRow('City', _contact.city!),
                        
                        // District information - Using correct property name
                        if (_contact.district != null)
                          _buildDetailRow('District', 'District ID: ${_contact.district}'),
                        
                        // Assembly Constituency information - Using correct property name
                        if (_contact.assemblyConstituency != null)
                          _buildDetailRow('Assembly Constituency', 'AC ID: ${_contact.assemblyConstituency}'),
                        
                        // Parliamentary Constituency information
                        if (_contact.parliamentaryConstituency != null)
                          _buildDetailRow('Parliamentary Constituency', 'PC ID: ${_contact.parliamentaryConstituency}'),
                        
                        // Local Body information
                        if (_contact.localBody != null)
                          _buildDetailRow('Local Body', 'LB ID: ${_contact.localBody}'),
                        
                        // Ward information
                        if (_contact.ward != null)
                          _buildDetailRow('Ward', 'Ward: ${_contact.ward}'),
                        
                        // Booth information
                        if (_contact.booth != null)
                          _buildDetailRow('Booth', 'Booth: ${_contact.booth}'),
                        
                        // Post Office information
                        if (_contact.postOffice != null && _contact.postOffice!.isNotEmpty)
                          _buildDetailRow('Post Office', _contact.postOffice!),
                        
                        // PIN Code information
                        if (_contact.pinCode != null && _contact.pinCode!.isNotEmpty)
                          _buildDetailRow('PIN Code', _contact.pinCode!),
                      ],
                    ),
                  ),

                  // Additional Information
                  if (_contact.type == ContactType.primary) ...[
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
                            'Primary Contact Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Party information
                          if (_contact.partyBlock != null)
                            _buildDetailRow('Party Block', 'PB ID: ${_contact.partyBlock}'),
                          
                          if (_contact.partyConstituency != null)
                            _buildDetailRow('Party Constituency', 'PC ID: ${_contact.partyConstituency}'),
                          
                          // Connection information
                          if (_contact.connection != null && _contact.connection!.isNotEmpty)
                            _buildDetailRow('Connection', _contact.connection!),
                          
                          // Tags as chips - Using List<int> instead of List<String>
                          if (_contact.tags != null && _contact.tags!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Tags:',
                              style: TextStyle(
                                fontSize: 15,
                                color: _textSecondary,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _contact.tags!.map((tagId) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _primaryBlue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Tag $tagId', // Since tags are IDs, display as "Tag ID"
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Referral Information (for All Contacts) - Updated to use API data
                  if (_contact.type == ContactType.all && _contact.referralDetails != null) ...[
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