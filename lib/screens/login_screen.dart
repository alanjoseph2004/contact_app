import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'contact_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show a SnackBar if either field is empty.
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username/email and password.'),
          backgroundColor: Color.fromARGB(255, 8, 2, 1),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Make API call to your auth endpoint
      final response = await http.post(
        Uri.parse('http://localhost:8000/contact/token/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response to get the JWT token
        final Map<String, dynamic> data = json.decode(response.body);
        final String token = data['access']?? '';
        
        // Store the token securely using shared_preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        
        // Navigate to the Contacts page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ContactsPage()),
          );
        }
      } else {
        // Handle authentication error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication failed: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Handle network or other errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background Image
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              child: Image.asset(
                'assets/background2.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Main Content with Rounded Corners
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.25 * 0.80),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          "Login First",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Color(0xDD122786),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Hello there, login in to continue!",
                          style: TextStyle(
                            color: Color.fromARGB(255, 58, 57, 57),
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(height: 120),
                        const Text("Username or email",
                            style: TextStyle(
                                color: Color(0xFF3A3939), fontSize: 18)),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Enter your username or email',
                            hintStyle:
                                TextStyle(color: Colors.grey.shade500),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 23),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your username or email'
                              : null,
                        ),
                        const SizedBox(height: 22),
                        const Text("Password",
                            style: TextStyle(
                                color: Color(0xFF3A3939), fontSize: 18)),
                        const SizedBox(height: 9),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle:
                                TextStyle(color: Colors.grey.shade500),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 23),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter your password' : null,
                        ),
                        const SizedBox(height: 35),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC5CAE9),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Color(0xFF283593),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Color(0xFF283593),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 22,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}