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
  late TextEditingController _houseNumberController;
  late TextEditingController _cityController;
  late TextEditingController _postOfficeController;
  late TextEditingController _pinCodeController;
  
  // API data lists
  List<Map<String, dynamic>> _primaryContacts = [];
  List<Map<String, dynamic>> _constituencies = [];
  
  // Selected values
  int? _selectedReferredBy;
  int? _selectedCity;
  int? _selectedConstituency;
  int? _selectedPartyBlock;
  int? _selectedPartyConstituency;
  int? _selectedBooth;
  int? _selectedParliamentaryConstituency;
  int? _selectedLocalBody;
  int? _selectedWard;
  
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
    _houseNumberController = TextEditingController();
    _cityController = TextEditingController();
    _postOfficeController = TextEditingController();
    _pinCodeController = TextEditingController();
    
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
    _houseNumberController.dispose();
    _cityController.dispose();
    _postOfficeController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }
  
  // Load all necessary data from APIs
  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
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
        _showSnackBar('Contact updated successfully!', Colors.green);
        
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

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Contact',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isInitialLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading data...'),
                ],
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Error message if any
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade700),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(color: Colors.red.shade900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Personal Details Section
                          _buildSectionTitle('Personal Details'),
                          const SizedBox(height: 16),
                          
                          // Name Fields
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _firstNameController,
                                  labelText: 'First Name*',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter first name';
                                    }
                                    if (value.length > 63) {
                                      return 'First name must be 63 characters or less';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _lastNameController,
                                  labelText: 'Last Name',
                                  validator: (value) {
                                    if (value != null && value.length > 63) {
                                      return 'Last name must be 63 characters or less';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Email Field
                          _buildTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              }
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              if (value.length > 255) {
                                return 'Email must be 255 characters or less';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone Number Fields
                          Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: _buildTextField(
                                  controller: _countryCodeController,
                                  labelText: '+91',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (value.length > 5) {
                                      return 'Max 5 chars';
                                    }
                                    return null;
                                  },
                                  maxLength: 5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _phoneController,
                                  labelText: 'Phone Number*',
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter phone number';
                                    }
                                    if (value.length > 11) {
                                      return 'Phone number must be 11 characters or less';
                                    }
                                    return null;
                                  },
                                  maxLength: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Notes Field
                          _buildTextField(
                            controller: _noteController,
                            labelText: 'Notes',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 32),

                          // Other Details Section
                          _buildSectionTitle('Other Details'),
                          const SizedBox(height: 16),

                          // District Dropdown
                          _buildDropdownField<int?>(
                            value: _selectedConstituency,
                            labelText: 'District',
                            items: _constituencies.map((constituency) {
                              return DropdownMenuItem<int?>(
                                value: constituency['id'],
                                child: Text(constituency['name']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedConstituency = value;
                                _updateAvailableCities();
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Assembly Constituency
                          _buildDropdownField<int?>(
                            value: _selectedCity,
                            labelText: 'Assembly Constituency',
                            items: _availableCities.map((city) {
                              return DropdownMenuItem<int?>(
                                value: city['id'],
                                child: Text(city['name']),
                              );
                            }).toList(),
                            onChanged: _availableCities.isEmpty ? (value) {} : (value) {
                              setState(() {
                                _selectedCity = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Party Block
                          _buildDropdownField<int?>(
                            value: _selectedPartyBlock,
                            labelText: 'Party Block',
                            items: const [],
                            onChanged: (value) {
                              setState(() {
                                _selectedPartyBlock = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Party Constituency
                          _buildDropdownField<int?>(
                            value: _selectedPartyConstituency,
                            labelText: 'Party Constituency',
                            items: const [],
                            onChanged: (value) {
                              setState(() {
                                _selectedPartyConstituency = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Booth
                          _buildDropdownField<int?>(
                            value: _selectedBooth,
                            labelText: 'Booth',
                            items: const [],
                            onChanged: (value) {
                              setState(() {
                                _selectedBooth = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Parliamentary Constituency
                          _buildDropdownField<int?>(
                            value: _selectedParliamentaryConstituency,
                            labelText: 'Parliamentary Constituency',
                            items: const [],
                            onChanged: (value) {
                              setState(() {
                                _selectedParliamentaryConstituency = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Local Body
                          _buildDropdownField<int?>(
                            value: _selectedLocalBody,
                            labelText: 'Local Body',
                            items: const [],
                            onChanged: (value) {
                              setState(() {
                                _selectedLocalBody = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Ward
                          _buildDropdownField<int?>(
                            value: _selectedWard,
                            labelText: 'Ward',
                            items: const [],
                            onChanged: (value) {
                              setState(() {
                                _selectedWard = value;
                              });
                            },
                          ),
                          const SizedBox(height: 32),

                          // Residential Details Section
                          _buildSectionTitle('Residential Details'),
                          const SizedBox(height: 16),

                          // House Name
                          _buildTextField(
                            controller: _addressController,
                            labelText: 'House Name',
                          ),
                          const SizedBox(height: 16),

                          // House Number
                          _buildTextField(
                            controller: _houseNumberController,
                            labelText: 'House Number',
                          ),
                          const SizedBox(height: 16),

                          // City
                          _buildTextField(
                            controller: _cityController,
                            labelText: 'City',
                          ),
                          const SizedBox(height: 16),

                          // Post Office
                          _buildTextField(
                            controller: _postOfficeController,
                            labelText: 'Post Office',
                          ),
                          const SizedBox(height: 16),

                          // Pin Code
                          _buildTextField(
                            controller: _pinCodeController,
                            labelText: 'Pin Code',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 32),

                          // Referred By Section
                          _buildSectionTitle('Referred By'),
                          const SizedBox(height: 16),

                          // Referred By Dropdown
                          _buildDropdownField<int?>(
                            value: _selectedReferredBy,
                            labelText: 'Referred By',
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('None'),
                              ),
                              ..._primaryContacts.map((contact) => DropdownMenuItem<int?>(
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
                          const SizedBox(height: 32),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _updateContact,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4285F4),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                // Loading overlay
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Updating contact...',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        counterText: '',
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String labelText,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      items: items,
      onChanged: onChanged,
      dropdownColor: Colors.white,
    );
  }
}