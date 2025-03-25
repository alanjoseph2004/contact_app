import 'package:flutter/material.dart';
import 'contact_logic.dart';

class NewContactPage extends StatefulWidget {
  const NewContactPage({super.key});

  @override
  State<NewContactPage> createState() => _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final priorityController = TextEditingController();
  final referredByController = TextEditingController();
  
  // Contact type checkboxes
  bool isPrimary = false;
  bool isAll = false;
  
  // List to store primary contacts for referral
  List<Contact> primaryContacts = [];

  // Primary theme color to match the main page
  final Color primaryColor = const Color(0xFF283593);

  @override
  void initState() {
    super.initState();
    // Load primary contacts for referral dropdown
    _loadPrimaryContacts();
  }

  Future<void> _loadPrimaryContacts() async {
    final contacts = await ContactService.getContactsByType(ContactType.primary);
    setState(() {
      primaryContacts = contacts;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    priorityController.dispose();
    referredByController.dispose();
    super.dispose();
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
        title: const Text(
          'New Contact',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact avatar placeholder
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 50,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: primaryColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            // Implement photo selection functionality
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Form fields with improved styling
            _buildTextField(
              controller: nameController,
              label: 'Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 24),
            
            _buildTextField(
              controller: phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            
            _buildTextField(
              controller: emailController,
              label: 'Email (Optional)',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 32),
            
            // Contact type selector with checkboxes
            Text(
              'Contact Type',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildCheckbox(
                    title: 'Primary',
                    value: isPrimary,
                    onChanged: (value) {
                      setState(() {
                        isPrimary = value ?? false;
                        // Reset priority when changing type
                        if (!isPrimary) priorityController.clear();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildCheckbox(
                    title: 'All',
                    value: isAll,
                    onChanged: (value) {
                      setState(() {
                        isAll = value ?? false;
                        // Reset referred by when changing type
                        if (!isAll) referredByController.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Conditional fields
            if (isPrimary) ...[
              _buildTextField(
                controller: priorityController,
                label: 'Priority (1-5)',
                icon: Icons.priority_high_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
            ],
            
            if (isAll) ...[
              _buildReferredByDropdown(),
              const SizedBox(height: 24),
            ],
            
            // Save button with improved styling
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saveContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'SAVE CONTACT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dropdown for selecting primary contact as referrer
  Widget _buildReferredByDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.person_add_outlined, color: primaryColor.withOpacity(0.7), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Referred By',
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              items: primaryContacts.map((contact) {
                return DropdownMenuItem(
                  value: contact.id,
                  child: Text(contact.name),
                );
              }).toList(),
              onChanged: (value) {
                referredByController.text = value ?? '';
              },
              hint: const Text('Select Primary Contact'),
            ),
          ),
        ],
      ),
    );
  }

  // Text field builder method
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: primaryColor.withOpacity(0.7), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              keyboardType: keyboardType,
            ),
          ),
        ],
      ),
    );
  }

  // Checkbox builder method
  Widget _buildCheckbox({
    required String title,
    required bool value,
    required Function(bool?)? onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged!(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
          ),
          Text(
            title,
            style: TextStyle(
              color: value ? primaryColor : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveContact() async {
    // Validate input
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and phone number are required"))
      );
      return;
    }
    
    // Validate priority for primary contacts
    if (isPrimary && priorityController.text.isNotEmpty) {
      int? priority = int.tryParse(priorityController.text);
      if (priority == null || priority < 1 || priority > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Priority must be a number between 1 and 5"))
        );
        return;
      }
    }
    
    // Determine contact type
    ContactType contactType;
    if (isPrimary && isAll) {
      contactType = ContactType.both;
    } else if (isPrimary) {
      contactType = ContactType.primary;
    } else if (isAll) {
      contactType = ContactType.all;
    } else {
      // Default if none selected
      contactType = ContactType.all;
    }
    
    try {
      // Create new contact
      final newContact = Contact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        phoneNumber: phoneController.text,
        email: emailController.text.isEmpty ? null : emailController.text,
        type: contactType,
        priority: isPrimary ? int.parse(priorityController.text) : null,
        referredBy: isAll && referredByController.text.isNotEmpty 
            ? referredByController.text 
            : null,
      );
      
      // Save contact
      await ContactService.addContact(newContact);
      
      if (context.mounted) {
        // Show success message and return to previous screen
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Contact added successfully"),
            backgroundColor: Color(0xFF283593),
          )
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle any validation errors
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }
}