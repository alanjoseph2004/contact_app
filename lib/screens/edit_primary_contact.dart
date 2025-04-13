import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'contact_logic.dart';

class EditPrimaryContactScreen extends StatefulWidget {
  final Contact contact;

  const EditPrimaryContactScreen({
    super.key,
    required this.contact,
  });

  @override
  State<EditPrimaryContactScreen> createState() => _EditPrimaryContactScreenState();
}

class _EditPrimaryContactScreenState extends State<EditPrimaryContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _countryCodeController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _noteController;
  
  // API data lists
  List<Map<String, dynamic>> _connections = [];
  List<Map<String, dynamic>> _constituencies = [];
  List<Map<String, dynamic>> _tagCategories = [];
  List<Map<String, dynamic>> _availableTagNames = []; // Available tag names for selected category
  
  // Selected values
  int? _selectedCity;
  int? _selectedConstituency;
  int? _selectedConnection;
  int _selectedPriority = 5;
  int? _selectedTagCategory;
  int? _selectedTagName;
  
  // Available cities based on selected constituency
  List<Map<String, dynamic>> _availableCities = [];
  
  // Selected tags
  List<Map<String, dynamic>> _tags = [];
  
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
    _selectedConnection = widget.contact.connection != null ? int.tryParse(widget.contact.connection!) : null;
    _selectedPriority = widget.contact.priority ?? 5;
    
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
        _fetchConnections(),
        _fetchConstituencies(),
        _fetchTagData(),
        _fetchContactTags(),
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

  // API Call to fetch connections
  Future<void> _fetchConnections() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception("JWT token is missing");
    }

    final response = await http.get(
      Uri.parse('http://51.21.152.136:8000/contact/all-connections/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _connections = data.map((item) => {
          'id': item['id'],
          'name': item['connection'],
        }).toList();
      });
    } else {
      throw Exception('Failed to load connections');
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

  // API Call to fetch tag data (both categories and tags)
  Future<void> _fetchTagData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception("JWT token is missing");
    }

    final response = await http.get(
      Uri.parse('http://51.21.152.136:8000/contact/all-tags/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _tagCategories = data.map((category) => {
          'id': category['id'],
          'name': category['tag_category'],
          'tags': List<Map<String, dynamic>>.from(
            category['tags'].map((tag) => {
              'id': tag['id'],
              'name': tag['tag_name'],
            })
          ),
        }).toList();
      });
    } else {
      throw Exception('Failed to load tag data');
    }
  }
  
  // API Call to fetch tags for this contact
  Future<void> _fetchContactTags() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception("JWT token is missing");
    }

    final response = await http.get(
      Uri.parse('http://51.21.152.136:8000/contact/primary-contact/${widget.contact.id}/tags/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _tags = data.map((tag) => {
          'id': tag['id'],
          'name': tag['tag_name'],
          'tag_category': tag['tag_category'],
          'category_id': tag['category_id'],
        }).toList();
      });
    } else {
      // Just log the error but don't throw, as this isn't critical
      print('Failed to load contact tags: ${response.statusCode}');
    }
  }

  // Update available tag names when category is selected
  void _updateAvailableTagNames() {
    if (_selectedTagCategory != null) {
      final category = _tagCategories.firstWhere(
        (c) => c['id'] == _selectedTagCategory,
        orElse: () => {'tags': []},
      );
      
      setState(() {
        _availableTagNames = List<Map<String, dynamic>>.from(category['tags'] ?? []);
        _selectedTagName = null; // Reset selected tag name
      });
    } else {
      setState(() {
        _availableTagNames = [];
        _selectedTagName = null;
      });
    }
  }
  
  void _addTag() {
    if (_selectedTagName != null && _selectedTagCategory != null) {
      // Find the tag name from the available tags
      final tagName = _availableTagNames.firstWhere(
        (tag) => tag['id'] == _selectedTagName,
        orElse: () => {'id': _selectedTagName, 'name': 'Unknown'},
      );
      
      // Find the category from the categories list
      final tagCategory = _tagCategories.firstWhere(
        (category) => category['id'] == _selectedTagCategory,
        orElse: () => {'id': _selectedTagCategory, 'name': 'Unknown'},
      );
      
      // Check if this tag is already added
      final isTagAlreadyAdded = _tags.any((tag) => tag['id'] == _selectedTagName);
      
      if (!isTagAlreadyAdded) {
        setState(() {
          _tags.add({
            'id': _selectedTagName,
            'name': tagName['name'],
            'tag_category': tagCategory['name'],
            'category_id': _selectedTagCategory,
          });
          
          // Reset tag name selection but keep category selected
          _selectedTagName = null;
        });
      } else {
        // Show a message that the tag is already added
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tag "${tagName['name']}" is already added'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
  
  void _removeTag(Map<String, dynamic> tag) {
    setState(() {
      _tags.remove(tag);
    });
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
        'contact': {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text.isEmpty ? null : _lastNameController.text,
          'email': _emailController.text.isEmpty ? null : _emailController.text,
          'country_code': _countryCodeController.text,
          'phone': _phoneController.text,
          'note': _noteController.text.isEmpty ? null : _noteController.text,
          'address': _addressController.text.isEmpty ? null : _addressController.text,
          'city': _selectedCity,
          'constituency': _selectedConstituency,
        },
        'priority': _selectedPriority,
        'connection': _selectedConnection,
        'tags': _tags.map((tag) => tag['id']).toList(),
      };
      
      final response = await http.put(
        Uri.parse('http://51.21.152.136:8000/contact/primary-contact/update/${widget.contact.id}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      print('Contact ID: ${widget.contact.id}');

      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Create updated contact object based on the Contact class definition
        final updatedContact = Contact(
          id: responseData['contact']['id'].toString(),
          firstName: responseData['contact']['first_name'],
          lastName: responseData['contact']['last_name'],
          countryCode: responseData['contact']['country_code'],
          phone: responseData['contact']['phone'],
          email: responseData['contact']['email'],
          note: responseData['contact']['note'],
          address: responseData['contact']['address'],
          city: responseData['contact']['city']?.toString(),
          constituency: responseData['contact']['constituency']?.toString(),
          avatarUrl: widget.contact.avatarUrl, // Keep existing avatar
          hasMessages: widget.contact.hasMessages, // Maintain existing value
          type: ContactType.primary,
          priority: responseData['priority'],
          connection: responseData['connection']?.toString(),
          tags: responseData['tags']?.map<String>((tag) => tag.toString()).toList(),
          isPrimary: true,
          referredBy: null, // Primary contacts don't have referrals
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
          'Edit Primary Contact',
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
                    
                    // Primary Contact Details section
                    _buildSectionTitle('Primary Contact Details'),
                    
                    // Priority
                    Row(
                      children: [
                        const Text(
                          'Priority:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Slider(
                            value: _selectedPriority.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            activeColor: _getPriorityColor(_selectedPriority),
                            label: _selectedPriority.toString(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPriority = value.toInt();
                              });
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(_selectedPriority),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _selectedPriority.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Connection Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedConnection,
                      decoration: _inputDecoration('Connection', Icons.people),
                      hint: const Text('Select Connection'),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('Select Connection'),
                        ),
                        ..._connections.map((connection) => DropdownMenuItem<int>(
                          value: connection['id'],
                          child: Text(connection['name']),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedConnection = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Tags section
                    _buildSectionTitle('Tags'),
                    
                    // Tag selector
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag Category
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedTagCategory,
                            decoration: _inputDecoration('Tag Category', Icons.category),
                            hint: const Text('Select Category'),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Select Category'),
                              ),
                              ..._tagCategories.map((category) => DropdownMenuItem<int>(
                                value: category['id'],
                                child: Text(category['name']),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedTagCategory = value;
                                _updateAvailableTagNames();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Tag Name
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedTagName,
                            decoration: _inputDecoration('Tag Name', Icons.label),
                            hint: const Text('Select Tag'),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Select Tag'),
                              ),
                              ..._availableTagNames.map((tag) => DropdownMenuItem<int>(
                                value: tag['id'],
                                child: Text(tag['name']),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedTagName = value;
                              });
                            },
                          ),
                        ),
                        
                        // Add Tag Button
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _selectedTagName != null ? _addTag : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.all(12),
                            shape: const CircleBorder(),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tags List
                    if (_tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag['name']),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => _removeTag(tag),
                            backgroundColor: primaryColor.withOpacity(0.1),
                            deleteIconColor: primaryColor,
                            labelStyle: TextStyle(color: primaryColor),
                          );
                        }).toList(),
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
}