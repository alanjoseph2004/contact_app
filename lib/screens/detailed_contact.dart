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
  final Color primaryColor = const Color(0xFF2196F3); // Blue color from screenshot

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
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _contact.name,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: Material(
              color: primaryColor,
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
          color: Colors.white,
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
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: _contact.avatarUrl != null 
                      ? ClipOval(
                          child: Image.network(
                            _contact.avatarUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: Colors.grey.shade600,
                          size: 32,
                        ),
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
                          color: Colors.black,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            _contact.phoneNumber,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (_contact.email != null && _contact.email!.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              _contact.email!,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Star icon with priority
                if (_contact.isPrimary && _contact.priority != null)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 24,
                        ),
                        Positioned(
                          child: Text(
                            '${_contact.priority}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Icon(
                    Icons.star,
                    color: primaryColor,
                    size: 28,
                  ),
              ],
            ),
            
            const SizedBox(height: 14),
            
            // Divider
            Container(
              height: 1,
              color: Colors.grey.shade200,
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

      const SizedBox(height: 8),
            // Contact Details Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                      color: Colors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Address information
                  if (_contact.address != null && _contact.address!.isNotEmpty)
                    _buildDetailRow('Address', _contact.address!),
                  
                  // City information
                  if (_contact.city != null && _contact.city!.isNotEmpty)
                    _buildDetailRow('City', _contact.city!),
                  
                  // Constituency information
                  if (_contact.constituency != null && _contact.constituency!.isNotEmpty)
                    _buildDetailRow('Constituency', _contact.constituency!),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Additional Information
            if (_contact.type == ContactType.primary) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                        color: Colors.black,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Tags as chips
                    if (_contact.tags != null && _contact.tags!.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _contact.tags!.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
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
              ),
              const SizedBox(height: 16),
            ],

            // Referral Information (for All Contacts)
            if (_contact.type == ContactType.all && _contact.referredBy != null) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                        color: Colors.black,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Referred by', 
                      '${_contact.referredBy!['referred_first_name']} ${_contact.referredBy!['referred_last_name'] ?? ''}'),
                    _buildDetailRow('Referral Phone', 
                      '${_contact.referredBy!['referred_country_code'] ?? ''} ${_contact.referredBy!['referred_phone'] ?? ''}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
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
                      color: Colors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _contact.note ?? 'No notes available.',
                    style: TextStyle(
                      fontSize: 15,
                      color: _contact.note == null ? Colors.grey.shade500 : Colors.black87,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
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
          color: isOutlined ? Colors.transparent : primaryColor,
          borderRadius: BorderRadius.circular(24),
          border: isOutlined ? Border.all(color: primaryColor, width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isOutlined ? primaryColor : Colors.white, 
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isOutlined ? primaryColor : Colors.white,
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
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
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
                color: Colors.black87,
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
        backgroundColor: const Color(0xFF2196F3),
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
        primaryColor: const Color(0xFF2196F3),
        isFullScreen: true,
      ),
    );
  }
}