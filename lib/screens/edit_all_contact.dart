import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'contact_logic.dart';

class EditAllContactScreen extends StatefulWidget {
  final Contact contact;

  const EditAllContactScreen({
    super.key,
    required this.contact,
  });

  @override
  State<EditAllContactScreen> createState() => _EditAllContactScreenState();
}

class _EditAllContactScreenState extends State<EditAllContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _countryCodeController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _noteController;
  
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
    
    // Initialize controllers with existing contact data
    _firstNameController = TextEditingController(text: widget.contact.firstName);
    _lastNameController = TextEditingController(text: widget.contact.lastName ?? '');
    _emailController = TextEditingController(text: widget.contact.email ?? '');
    _countryCodeController = TextEditingController(text: widget.contact.countryCode);
    _phoneController = TextEditingController(text: widget.contact.phone);
    _addressController = TextEditingController(text: widget.contact.address ?? '');
    _noteController = TextEditingController(text: widget.contact.note ?? '');
    
    // Set initial values for dropdowns if available
    _selectedCity = widget.contact.city != null ? int.tryParse(widget.contact.city!) : null;
    _selectedConstituency = widget.contact.constituency != null ? int.tryParse(widget.contact.constituency!) : null;
    _selectedReferredBy = widget.contact.referredBy != null && widget.contact.referredBy!['id'] != null 
      ? int.tryParse(widget.contact.referredBy!['id'].toString()) 
      : null;
      
    // Load all necessary data from APIs
    _loadInitialData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
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
      
      // After loading constituencies, update available cities
      if (_selectedConstituency != null) {
        _updateAvailableCities();
      }
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
      
      if (response.statusCode == 200) {
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
      });
    } else {
      setState(() {
        _availableCities = [];
        _selectedCity = null;
      });
    }
  }

  Future<void> _updateContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
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
      
      final response = await http.put(
        Uri.parse('http://51.21.152.136:8000/contact/contact/update/${widget.contact.id}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Create updated contact object based on the Contact class definition
        final updatedContact = Contact(
          id: responseData['id'].toString(),
          firstName: responseData['first_name'],
          lastName: responseData['last_name'],
          countryCode: responseData['country_code'],
          phone: responseData['phone'],
          email: responseData['email'],
          note: responseData['note'],
          address: responseData['address'],
          city: responseData['city']?.toString(),
          constituency: responseData['constituency']?.toString(),
          avatarUrl: widget.contact.avatarUrl, // Keep existing avatar
          hasMessages: widget.contact.hasMessages, // Maintain existing value
          type: responseData['is_primary_contact'] == true ? ContactType.primary : ContactType.all,
          priority: null, // Only set for primary contacts via a different endpoint
          connection: null, // Only set for primary contacts via a different endpoint
          tags: null, // Only set for primary contacts via a different endpoint
          isPrimary: responseData['is_primary_contact'] == true,
          referredBy: responseData['referred_by'] != null ? {
            'id': responseData['referred_by'],
            // We would need to fetch additional details from the primary contacts list
            'name': _primaryContacts.firstWhere(
              (contact) => contact['id'] == responseData['referred_by'], 
              orElse: () => {'name': 'Unknown'}
            )['name'],
          } : null,
        );
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to previous screen with updated contact
        Navigator.pop(context, updatedContact);
      } else {
        setState(() {
          _errorMessage = 'Failed to update contact. Status code: ${response.statusCode}';
          try {
            final responseData = jsonDecode(response.body);
            if (responseData['message'] != null) {
              _errorMessage = responseData['message'];
            }
          } catch (e) {
            // If response body can't be parsed, use the existing error message
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF283593);
    
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
          'Edit Contact',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateContact,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    
                    // Profile header with avatar
                    Center(
                      child: Hero(
                        tag: 'contact_avatar_${widget.contact.id}',
                        child: CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.3),
                          backgroundImage: widget.contact.avatarUrl != null ? NetworkImage(widget.contact.avatarUrl!) : null,
                          radius: 60,
                          child: widget.contact.avatarUrl == null ? Text(
                            widget.contact.firstName.isNotEmpty ? widget.contact.firstName[0].toUpperCase() : "?",
                            style: TextStyle(color: primaryColor, fontSize: 40, fontWeight: FontWeight.bold),
                          ) : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Basic information section
                    _buildSectionTitle('Basic Information'),
                    
                    // First Name
                    TextFormField(
                      controller: _firstNameController,
                      decoration: _inputDecoration('First Name', Icons.person),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Last Name
                    TextFormField(
                      controller: _lastNameController,
                      decoration: _inputDecoration('Last Name', Icons.person),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration('Email', Icons.email),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          // Simple email validation
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country Code
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: _countryCodeController,
                            decoration: _inputDecoration('Code', Icons.phone),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Phone Number
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: _inputDecoration('Phone Number', null),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Address information section
                    _buildSectionTitle('Address Information'),
                    
                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: _inputDecoration('Address', Icons.location_on),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    
                    // Constituency Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedConstituency,
                      decoration: _inputDecoration('Constituency', Icons.location_city),
                      hint: const Text('Select Constituency'),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Select Constituency'),
                        ),
                        ..._constituencies.map((constituency) => DropdownMenuItem<int>(
                          value: constituency['id'],
                          child: Text(constituency['name']),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedConstituency = value;
                          _updateAvailableCities();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // City Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedCity,
                      decoration: _inputDecoration('City', Icons.location_city),
                      hint: const Text('Select City'),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Select City'),
                        ),
                        ..._availableCities.map((city) => DropdownMenuItem<int>(
                          value: city['id'],
                          child: Text(city['name']),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Referred By section
                    _buildSectionTitle('Referred By'),
                    
                    // Referred By Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedReferredBy,
                      decoration: _inputDecoration('Referred By', Icons.people),
                      hint: const Text('Select Primary Contact'),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('None'),
                        ),
                        ..._primaryContacts.map((contact) => DropdownMenuItem<int>(
                          value: contact['id'],
                          child: Text('${contact['name']} (${contact['phone']})'),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedReferredBy = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Notes section
                    _buildSectionTitle('Notes'),
                    TextFormField(
                      controller: _noteController,
                      decoration: _inputDecoration('Notes', Icons.note),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
  
  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF283593), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF283593),
        ),
      ),
    );
  }
}