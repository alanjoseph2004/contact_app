import 'package:flutter/material.dart';
import 'contact_logic.dart';

class EditContactDialog extends StatefulWidget {
  final Contact contact;
  final Color primaryColor;

  const EditContactDialog({
    super.key, 
    required this.contact, 
    required this.primaryColor
  });

  @override
  _EditContactDialogState createState() => _EditContactDialogState();
}

class _EditContactDialogState extends State<EditContactDialog> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController referredByController;
  
  late ContactType selectedType;
  int? priority;
  List<Contact> primaryContacts = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing contact data
    nameController = TextEditingController(text: widget.contact.name);
    phoneController = TextEditingController(text: widget.contact.phoneNumber);
    emailController = TextEditingController(text: widget.contact.email ?? '');
    referredByController = TextEditingController(text: widget.contact.referredBy ?? '');
    
    selectedType = widget.contact.type;
    priority = widget.contact.priority;

    // Load primary contacts
    _loadPrimaryContacts();
  }

  Future<void> _loadPrimaryContacts() async {
    primaryContacts = await ContactService.getContactsByType(ContactType.primary);
    setState(() {});
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    referredByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Contact", style: TextStyle(color: widget.primaryColor)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email (Optional)'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ContactType>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Contact Type'),
              items: ContactType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  // Use the capitalize() extension from contact_logic.dart
                  child: Text(type.toString().split('.').last.capitalize()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedType = value;
                  });
                }
              },
            ),
            
            // Priority field for primary contacts
            if (selectedType == ContactType.primary) 
              DropdownButtonFormField<int>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: List.generate(5, (index) => index + 1)
                    .map((priorityValue) => DropdownMenuItem(
                          value: priorityValue,
                          child: Text(priorityValue.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    priority = value;
                  });
                },
              ),
            
            // Referred by field for all contacts
            if (selectedType == ContactType.all)
              DropdownButtonFormField<String>(
                value: widget.contact.referredBy,
                decoration: const InputDecoration(labelText: 'Referred By'),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('None'),
                  ),
                  ...primaryContacts.map((primaryContact) => 
                    DropdownMenuItem(
                      value: primaryContact.id,
                      child: Text(primaryContact.name),
                    )
                  ).toList(),
                ],
                onChanged: (value) {
                  referredByController.text = value ?? '';
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("CANCEL"),
        ),
        TextButton(
          onPressed: () => _saveContact(context),
          child: const Text("SAVE"),
        ),
      ],
    );
  }

  Future<void> _saveContact(BuildContext context) async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and phone number are required"))
      );
      return;
    }

    // Validate priority for primary contacts
    if (selectedType == ContactType.primary && priority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Priority is required for primary contacts"))
      );
      return;
    }

    final updatedContact = Contact(
      id: widget.contact.id,
      name: nameController.text,
      phoneNumber: phoneController.text,
      email: emailController.text.isEmpty ? null : emailController.text,
      avatarUrl: widget.contact.avatarUrl,
      hasMessages: widget.contact.hasMessages,
      type: selectedType,
      priority: selectedType == ContactType.primary ? priority : null,
      referredBy: selectedType == ContactType.all && referredByController.text.isNotEmpty 
          ? referredByController.text 
          : null,
    );

    try {
      await ContactService.updateContact(updatedContact);
      
      if (context.mounted) {
        Navigator.of(context).pop(updatedContact);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contact updated successfully"))
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating contact: ${e.toString()}"))
        );
      }
    }
  }
}