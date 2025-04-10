import 'package:flutter/material.dart';
import 'contact_logic.dart';

class EditAllContactScreen extends StatefulWidget {
  final Contact contact;

  const EditAllContactScreen({
    Key? key,
    required this.contact,
  }) : super(key: key);

  @override
  State<EditAllContactScreen> createState() => _EditAllContactScreenState();
}

class _EditAllContactScreenState extends State<EditAllContactScreen> {
  late Contact _contact;
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = const Color(0xFF283593);

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Edit Contact', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Save contact logic will go here
              Navigator.pop(context, _contact);
            },
            child: const Text(
              'SAVE',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Regular Contact Editor',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This is a placeholder for the Regular Contact edit form. '
                'You will add form fields here for name, phone, email, address, '
                'city, constituency, referral information, and notes.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}