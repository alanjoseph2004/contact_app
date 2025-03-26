import 'package:flutter/material.dart';

class NewAllContactPage extends StatefulWidget {
  const NewAllContactPage({super.key});

  @override
  State<NewAllContactPage> createState() => _NewAllContactPageState();
}

class _NewAllContactPageState extends State<NewAllContactPage> {
  final Color primaryColor = const Color(0xFF283593);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'New All Contact',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text('New All Contact Page'),
      ),
    );
  }
}