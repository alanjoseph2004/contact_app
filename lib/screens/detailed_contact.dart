import 'package:flutter/material.dart';
import 'contact_logic.dart';
import 'edit_contact.dart';

class DetailedContactPage extends StatefulWidget {
  final Contact contact;

  const DetailedContactPage({
    Key? key,
    required this.contact,
  }) : super(key: key);

  @override
  State<DetailedContactPage> createState() => _DetailedContactPageState();
}

class _DetailedContactPageState extends State<DetailedContactPage> {
  late Contact _contact;
  final Color primaryColor = const Color(0xFF283593);

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _contact.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _navigateToEditContact(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              color: primaryColor.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Row(
                children: [
                  Hero(
                    tag: 'contact_avatar_${_contact.id}',
                    child: CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.3),
                      backgroundImage: _contact.avatarUrl != null ? NetworkImage(_contact.avatarUrl!) : null,
                      radius: 40,
                      child: _contact.avatarUrl == null ? Text(
                        _contact.name.isNotEmpty ? _contact.name[0].toUpperCase() : "?",
                        style: TextStyle(color: primaryColor, fontSize: 28, fontWeight: FontWeight.bold),
                      ) : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _contact.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildContactInfoRow(Icons.phone, _contact.phoneNumber),
                        if (_contact.email != null && _contact.email!.isNotEmpty)
                          _buildContactInfoRow(Icons.email, _contact.email!),
                        if (_contact.isPrimary && _contact.priority != null)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(_contact.priority!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Priority ${_contact.priority}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick action buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(Icons.phone, 'Call', () {
                    // Implement call functionality
                  }),
                  _buildActionButton(Icons.message, 'Message', () {
                    // Implement message functionality
                  }),
                  _buildActionButton(Icons.share, 'Share', () {
                    // Implement share functionality
                  }),
                ],
              ),
            ),

            const Divider(),

            // Contact Details Section
            _buildSectionTitle('Contact Details'),
            
            // Address information
            if (_contact.address != null && _contact.address!.isNotEmpty)
              _buildDetailItem('Address', _contact.address!),
            
            // City information
            if (_contact.city != null && _contact.city!.isNotEmpty)
              _buildDetailItem('City', _contact.city!),
            
            // Constituency information
            if (_contact.constituency != null && _contact.constituency!.isNotEmpty)
              _buildDetailItem('Constituency', _contact.constituency!),
            
            const Divider(),

            // Additional Information
            if (_contact.type == ContactType.primary) ...[
              _buildSectionTitle('Primary Contact Information'),
              
              // Connection information
              if (_contact.connection != null && _contact.connection!.isNotEmpty)
                _buildDetailItem('Connection', _contact.connection!),
              
              // Tags information
              if (_contact.tags != null && _contact.tags!.isNotEmpty)
                _buildTagsList('Tags', _contact.tags!),
            ],

            // Referral Information (for All Contacts)
            if (_contact.type == ContactType.all && _contact.referredBy != null) ...[
              _buildSectionTitle('Referral Information'),
              _buildDetailItem('Referred By', 
                '${_contact.referredBy!['referred_first_name']} ${_contact.referredBy!['referred_last_name'] ?? ''}'),
              _buildDetailItem('Referral Phone', 
                '${_contact.referredBy!['referred_country_code'] ?? ''} ${_contact.referredBy!['referred_phone'] ?? ''}'),
            ],

            const Divider(),

            // Notes Section
            _buildSectionTitle('Notes'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _contact.note ?? 'No notes available.',
                  style: TextStyle(
                    fontSize: 16,
                    color: _contact.note == null ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
        currentIndex: 2,
      ),
    );
  }

  Widget _buildContactInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsList(String label, List<String> tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => Chip(
              backgroundColor: primaryColor.withOpacity(0.1),
              label: Text(
                tag,
                style: TextStyle(color: primaryColor),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.green;
      case 5:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _navigateToEditContact() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditContactScreen(contact: _contact),
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
    Key? key,
    required this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF283593),
        title: const Text('Edit Contact', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: EditContactDialog(
        contact: contact,
        primaryColor: const Color(0xFF283593),
        isFullScreen: true,
      ),
    );
  }
}