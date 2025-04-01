import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'new_all_contact_ui.dart';

class NewAllContactPage extends StatefulWidget {
  const NewAllContactPage({super.key});

  @override
  State<NewAllContactPage> createState() => _NewAllContactPageState();
}

class _NewAllContactPageState extends State<NewAllContactPage> {
  final Color primaryColor = const Color(0xFF283593);
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // API data lists
  List<Map<String, dynamic>> _primaryContacts = [];
  List<Map<String, dynamic>> _constituencies = [];
  
  // Selected values
  int? _selectedReferredBy;
  int? _selectedCity;
  int? _selectedConstituency;

  // Available cities based on selected constituency
  List<Map<String, dynamic>> _availableCities = [];

  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  // Load all necessary data from APIs
  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
    });
    
    try {
      await Future.wait([
        _fetchPrimaryContacts(),
        _fetchConstituencies(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load initial data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  // API Call to fetch primary contacts
  Future<void> _fetchPrimaryContacts() async {
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('jwt_token');

  if (token == null || token.isEmpty) {
    throw Exception("JWT token is missing");
  }

  try {
    final response = await http.get(
      Uri.parse('http://51.21.152.136:8000/contact/all-primary-contacts/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('Primary contacts API status code: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      // Debug: Print the first 100 chars of the response
      
      final dynamic responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['results'];
      setState(() {
        _primaryContacts = data.map((item) => {
          'id': item['id'],
          'name': '${item['contact']['first_name']} ${item['contact']['last_name'] ?? ''}',
          'phone': item['contact']['phone'],
        }).toList();
      });
    } else {
      print('Error response body: ${response.body}');
      throw Exception('Failed to load primary contacts. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception in _fetchPrimaryContacts: $e');
    rethrow;
  }
}
  // API Call to fetch constituencies with cities
  Future<void> _fetchConstituencies() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception("JWT token is missing");
    }

    final response = await http.get(
      Uri.parse('http://51.21.152.136:8000/contact/all-cities/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _constituencies = data.map((item) => {
          'id': item['id'],
          'name': item['constituency'],
          'cities': List<Map<String, dynamic>>.from(
            item['cities'].map((city) => {
              'id': city['id'],
              'name': city['city'],
            })
          ),
        }).toList();
      });
    } else {
      throw Exception('Failed to load constituencies');
    }
  }

  // Update available cities when constituency is selected
  void _updateAvailableCities() {
    if (_selectedConstituency != null) {
      final constituency = _constituencies.firstWhere(
        (c) => c['id'] == _selectedConstituency,
        orElse: () => {'cities': []},
      );
      
      setState(() {
        _availableCities = List<Map<String, dynamic>>.from(constituency['cities'] ?? []);
        _selectedCity = null; // Reset selected city
      });
    } else {
      setState(() {
        _availableCities = [];
        _selectedCity = null;
      });
    }
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('jwt_token');

        if (token == null || token.isEmpty) {
          throw Exception("JWT token is missing");
        }
        
        // Format the data according to the API schema
        final Map<String, dynamic> requestBody = {
          'referred_by': _selectedReferredBy,
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text.isEmpty ? null : _lastNameController.text,
          'email': _emailController.text.isEmpty ? null : _emailController.text,
          'country_code': _countryCodeController.text,
          'phone': _phoneController.text,
          'note': _noteController.text.isEmpty ? null : _noteController.text,
          'address': _addressController.text.isEmpty ? null : _addressController.text,
          'city': _selectedCity,
        };

        // Make the API call
        final response = await http.post(
          Uri.parse('http://51.21.152.136:8000/contact/contact/create/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestBody),
        );

        // Handle the response
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back or to a success page
          Navigator.of(context).pop();
        } else {
          // Error
          final responseData = jsonDecode(response.body);
          setState(() {
            _errorMessage = responseData['message'] ?? 'Failed to save contact. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NewAllContactUI(
      formKey: _formKey,
      primaryColor: primaryColor,
      isInitialLoading: _isInitialLoading,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      emailController: _emailController,
      countryCodeController: _countryCodeController,
      phoneController: _phoneController,
      noteController: _noteController,
      addressController: _addressController,
      selectedReferredBy: _selectedReferredBy,
      selectedCity: _selectedCity,
      selectedConstituency: _selectedConstituency,
      primaryContacts: _primaryContacts,
      constituencies: _constituencies,
      availableCities: _availableCities,
      onReferredByChanged: (value) => setState(() => _selectedReferredBy = value),
      onConstituencyChanged: (value) {
        setState(() {
          _selectedConstituency = value;
          _updateAvailableCities();
        });
      },
      onCityChanged: (value) => setState(() => _selectedCity = value),
      onSave: _saveContact,
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}