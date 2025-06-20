import 'package:flutter/material.dart';
import 'contact_logic.dart';
import 'edit_contact_primary.dart';
import 'edit_all_contact.dart';
import 'edit_primary_contact.dart';

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
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: Material(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _navigateToEditContact(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      // Priority number (replacing star) - Fixed condition
                      if (_contact.type == ContactType.primary && _contact.priority != null)
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
                  
                  // Use fullAddress helper or individual address fields
                  if (_contact.fullAddress.isNotEmpty)
                    _buildDetailRow('Address', _contact.fullAddress),
                  
                  // Pin code
                  if (_contact.pinCode != null && _contact.pinCode!.isNotEmpty)
                    _buildDetailRow('Pin Code', _contact.pinCode!),
                  
                  // Constituency information (backward compatibility)
                  if (_contact.constituency != null && _contact.constituency!.isNotEmpty)
                    _buildDetailRow('Constituency', _contact.constituency!),
                ],
              ),
            ),

            // Geographic/Political Information Section (New fields)
            if (_hasGeographicInfo()) ...[
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
                      'Geographic/Political Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_contact.district != null)
                      _buildDetailRow('District ID', _contact.district.toString()),
                    
                    if (_contact.assemblyConstituency != null)
                      _buildDetailRow('Assembly Constituency', _contact.assemblyConstituency.toString()),
                    
                    if (_contact.partyBlock != null)
                      _buildDetailRow('Party Block', _contact.partyBlock.toString()),
                    
                    if (_contact.partyConstituency != null)
                      _buildDetailRow('Party Constituency', _contact.partyConstituency.toString()),
                    
                    if (_contact.booth != null)
                      _buildDetailRow('Booth', _contact.booth.toString()),
                    
                    if (_contact.parliamentaryConstituency != null)
                      _buildDetailRow('Parliamentary Constituency', _contact.parliamentaryConstituency.toString()),
                    
                    if (_contact.localBody != null)
                      _buildDetailRow('Local Body', _contact.localBody.toString()),
                    
                    if (_contact.ward != null)
                      _buildDetailRow('Ward', _contact.ward.toString()),
                  ],
                ),
              ),
            ],

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
                    
                    // Primary ID
                    if (_contact.primaryID != null && _contact.primaryID!.isNotEmpty)
                      _buildDetailRow('Primary ID', _contact.primaryID!),
                    
                    // Tags as chips - Fixed to handle List<int>
                    if (_contact.tags != null && _contact.tags!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tags',
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
                                'Tag $tagId', // Since tags are now IDs, display as "Tag ID"
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
                      ),
                  ],
                ),
              ),
            ],

            // Referral Information (for All Contacts) - Fixed field access
            if (_contact.type == ContactType.all && _contact.referredByDetails != null) ...[
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
                    
                    // Show referredBy ID if available
                    if (_contact.referredBy != null)
                      _buildDetailRow('Referred By ID', _contact.referredBy.toString()),
                    
                    // Show referral details
                    if (_contact.referredByDetails!['referred_first_name'] != null)
                      _buildDetailRow('Referred by', 
                        '${_contact.referredByDetails!['referred_first_name']} ${_contact.referredByDetails!['referred_last_name'] ?? ''}'),
                    
                    if (_contact.referredByDetails!['referred_phone'] != null)
                      _buildDetailRow('Referral Phone', 
                        '${_contact.referredByDetails!['referred_country_code'] ?? ''} ${_contact.referredByDetails!['referred_phone'] ?? ''}'),
                    
                    // Connection field for all contacts
                    if (_contact.connection != null && _contact.connection!.isNotEmpty)
                      _buildDetailRow('Connection', _contact.connection!),
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

  // Helper method to check if geographic info exists
  bool _hasGeographicInfo() {
    return _contact.district != null ||
           _contact.assemblyConstituency != null ||
           _contact.partyBlock != null ||
           _contact.partyConstituency != null ||
           _contact.booth != null ||
           _contact.parliamentaryConstituency != null ||
           _contact.localBody != null ||
           _contact.ward != null;
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

  void _navigateToEditContact() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _contact.type == ContactType.primary 
            ? EditPrimaryContactScreen(contact: _contact)
            : EditAllContactScreen(contact: _contact),
      ),
    );

    // If contact was edited successfully, update the UI
    if (result != null && result is Contact) {
      setState(() {
        _contact = result;
      });
    }
  }
}

// Create a separate EditContactScreen for full screen editing
class EditContactScreen extends StatelessWidget {
  final Contact contact;

  const EditContactScreen({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4285F4), // Updated to match primary blue
        title: const Text(
          'Edit Contact',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: EditContactDialog(
        contact: contact,
        primaryColor: const Color(0xFF4285F4), // Updated to match primary blue
        isFullScreen: true,
      ),
    );
  }
}