import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'contact_logic.dart';

class EditPrimaryContactScreen extends StatefulWidget {
  final Contact contact;

  const EditPrimaryContactScreen({
    Key? key,
    required this.contact,
  }) : super(key: key);

  @override
  State<EditPrimaryContactScreen> createState() => _EditPrimaryContactScreenState();
}

class _EditPrimaryContactScreenState extends State<EditPrimaryContactScreen> {
  late Contact _contact;
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = const Color(0xFF283593);
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Form controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _countryCodeController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _noteController;
  
  // API data
  Map<String, dynamic>? _contactDetails;
  List<Map<String, dynamic>> _constituencies = [];
  List<Map<String, dynamic>> _availableCities = [];
  List<Map<String, dynamic>> _connections = [];
  List<Map<String, dynamic>> _tagCategories = [];
  List<Map<String, dynamic>> _availableTagNames = [];
  
  // Selected values
  int? _selectedConstituency;
  int? _selectedCity;
  int? _selectedConnection;
  int? _selectedTagCategory;
  int? _selectedTagName;
  int _priority = 5;
  List<Map<String, dynamic>> selectedTags = [];

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
    _initializeControllers();
    _loadContactDetails();
    _loadDropdownData();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _countryCodeController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _noteController = TextEditingController();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _loadContactDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception("JWT token is missing");
      }

      final response = await http.get(
        Uri.parse('http://51.21.152.136:8000/contact/primary-contact/${_contact.id}/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _contactDetails = data;
          
          // Populate form fields
          _firstNameController.text = data['contact']['first_name'] ?? '';
          _lastNameController.text = data['contact']['last_name'] ?? '';
          _phoneController.text = data['contact']['phone'] ?? '';
          _countryCodeController.text = data['contact']['country_code'] ?? '';
          _emailController.text = data['contact']['email'] ?? '';
          _addressController.text = data['contact']['address'] ?? '';
          _noteController.text = data['contact']['note'] ?? '';
          
          // Set priority
          _priority = data['priority'] ?? 5;
          
          // Populate tags
          if (data['tags'] != null) {
            selectedTags = List<Map<String, dynamic>>.from(
              data['tags'].map((tag) => {
                'name': tag['tag_name'],
                'categoryName': tag['tag_category'],
                // Note: We'll need to find the actual IDs when the tag data is loaded
              })
            );
          }
        });
      } else {
        throw Exception('Failed to load contact details: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading contact details: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      await Future.wait([
        _fetchConstituencies(),
        _fetchConnections(),
        _fetchTagData(),
      ]);
      
      // Match existing data with retrieved IDs
      _matchExistingData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading dropdown data: $e';
      });
    }
  }
  
  void _matchExistingData() {
    if (_contactDetails == null) return;
    
    // Match constituency and city
    if (_contactDetails!['contact']['city'] != null) {
      final cityName = _contactDetails!['contact']['city']['city'];
      final constituencyName = _contactDetails!['contact']['city']['constituency'];
      
      // Find constituency ID
      final constituencyMatch = _constituencies.firstWhere(
        (c) => c['name'] == constituencyName,
        orElse: () => {'id': null},
      );
      
      if (constituencyMatch['id'] != null) {
        _selectedConstituency = constituencyMatch['id'];
        _updateAvailableCities();
        
        // Find city ID
        final cityMatch = _availableCities.firstWhere(
          (c) => c['name'] == cityName,
          orElse: () => {'id': null},
        );
        
        if (cityMatch['id'] != null) {
          _selectedCity = cityMatch['id'];
        }
      }
    }
    
    // Match connection
    if (_contactDetails!['connection'] != null) {
      final connectionName = _contactDetails!['connection']['connection'];
      final connectionMatch = _connections.firstWhere(
        (c) => c['name'] == connectionName,
        orElse: () => {'id': null},
      );
      
      if (connectionMatch['id'] != null) {
        _selectedConnection = connectionMatch['id'];
      }
    }
    
    // Match tags with IDs
    if (_contactDetails!['tags'] != null && _tagCategories.isNotEmpty) {
      List<Map<String, dynamic>> updatedTags = [];
      
      for (var tag in selectedTags) {
        // Find tag category
        final categoryMatch = _tagCategories.firstWhere(
          (c) => c['name'] == tag['categoryName'],
          orElse: () => {'id': null, 'tags': []},
        );
        
        if (categoryMatch['id'] != null) {
          // Find tag ID
          final tagMatch = categoryMatch['tags'].firstWhere(
            (t) => t['name'] == tag['name'],
            orElse: () => {'id': null},
          );
          
          if (tagMatch['id'] != null) {
            updatedTags.add({
              'id': tagMatch['id'],
              'name': tag['name'],
              'categoryId': categoryMatch['id'],
              'categoryName': tag['categoryName'],
            });
          }
        }
      }
      
      setState(() {
        selectedTags = updatedTags;
      });
    }
    
    setState(() {});
  }

  // API Call to fetch constituencies with cities
  Future<void> _fetchConstituencies() async {
    final token = await _getToken();
    if (token == null) {
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
  
  // API Call to fetch connections
  Future<void> _fetchConnections() async {
    final token = await _getToken();
    if (token == null) {
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
  
  // API Call to fetch tag data
  Future<void> _fetchTagData() async {
    final token = await _getToken();
    if (token == null) {
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

  // Update available cities when constituency is selected
  void _updateAvailableCities() {
    if (_selectedConstituency != null) {
      final constituency = _constituencies.firstWhere(
        (c) => c['id'] == _selectedConstituency,
        orElse: () => {'cities': []},
      );
      setState(() {
        _availableCities = List<Map<String, dynamic>>.from(constituency['cities'] ?? []);
        if (_availableCities.isEmpty) {
          _selectedCity = null;
        }
      });
    } else {
      setState(() {
        _availableCities = [];
        _selectedCity = null;
      });
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
        _selectedTagName = null;
      });
    } else {
      setState(() {
        _availableTagNames = [];
        _selectedTagName = null;
      });
    }
  }
  
  void _addSelectedTag() {
    if (_selectedTagCategory == null || _selectedTagName == null) return;
    
    // Find category and tag info
    final category = _tagCategories.firstWhere(
      (c) => c['id'] == _selectedTagCategory,
      orElse: () => {'name': '', 'tags': []}
    );
    
    final tag = _availableTagNames.firstWhere(
      (t) => t['id'] == _selectedTagName,
      orElse: () => {'id': null, 'name': ''}
    );
    
    if (tag['id'] != null) {
      // Check if tag is already selected
      if (!selectedTags.any((t) => t['id'] == tag['id'])) {
        setState(() {
          selectedTags.add({
            'id': tag['id'],
            'name': tag['name'],
            'categoryId': category['id'],
            'categoryName': category['name']
          });
        });
      }
    }
  }
  
  void _removeTag(Map<String, dynamic> tag) {
    setState(() {
      selectedTags.removeWhere((t) => t['id'] == tag['id']);
    });
  }

  Future<void> _saveContact() async {
  if (!_formKey.currentState!.validate()) return;
  
  if (_selectedCity == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a city')),
    );
    return;
  }
  
  if (_selectedConnection == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a connection')),
    );
    return;
  }
  
  setState(() {
    _isSaving = true;
    _errorMessage = null;
  });
  
  try {
    final token = await _getToken();
    if (token == null) {
      throw Exception("JWT token is missing");
    }
    
    // Prepare request body
    final requestBody = {
      "contact": {
        "first_name": _firstNameController.text,
        "last_name": _lastNameController.text,
        "email": _emailController.text,
        "country_code": _countryCodeController.text,
        "phone": _phoneController.text,
        "note": _noteController.text,
        "address": _addressController.text,
        "city": _selectedCity
      },
      "priority": _priority,
      "connection": _selectedConnection,
      "tags": selectedTags.map((tag) => tag['id']).toList()
    };
    
    final response = await http.put(
      Uri.parse('http://51.21.152.136:8000/contact/primary-contact/update/${_contactDetails!['id']}/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    
    if (response.statusCode == 200) {
      // Create updated contact object with new values
      final updatedContact = Contact(
        id: _contact.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text, // Fixed typo: removed dash prefix
        countryCode: _countryCodeController.text, // Fixed typo: removed dash prefix
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        city: _availableCities.firstWhere(
          (c) => c['id'] == _selectedCity,
          orElse: () => {'name': ''},
        )['name'],
        constituency: _constituencies.firstWhere(
          (c) => c['id'] == _selectedConstituency,
          orElse: () => {'name': ''},
        )['name'],
        note: _noteController.text,
        type: ContactType.primary,
        isPrimary: true,
        priority: _priority,
        connection: _connections.firstWhere(
          (c) => c['id'] == _selectedConnection,
          orElse: () => {'name': ''},
        )['name'],
        tags: selectedTags.map((tag) => tag['name'] as String).toList(),
        avatarUrl: _contact.avatarUrl,
        hasMessages: _contact.hasMessages,
      );
      
      // Update contact in local storage
      final updateSuccess = await ContactService.updateContact(updatedContact);
      if (!updateSuccess) {
        debugPrint('Warning: Failed to update contact in local storage');
      }
      
      Navigator.pop(context, updatedContact);
    } else {
      throw Exception('Failed to update contact: ${response.body}');
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Error saving contact: $e';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save: $_errorMessage')),
    );
  } finally {
    setState(() {
      _isSaving = false;
    });
  }
}

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _countryCodeController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Edit Primary Contact', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading || _isSaving ? null : _saveContact,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'SAVE',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _loadContactDetails();
                          _loadDropdownData();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Contact Information
                        _buildSectionTitle('Basic Information'),
                        
                        // Name fields (first and last name)
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _firstNameController,
                                'First Name',
                                required: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                _lastNameController,
                                'Last Name',
                                required: true,
                              ),
                            ),
                          ],
                        ),
                        
                        // Phone fields (country code and phone)
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: _buildTextField(
                                _countryCodeController,
                                'Country Code',
                                required: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              flex: 3,
                              child: _buildTextField(
                                _phoneController,
                                'Phone Number',
                                required: true,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        
                        // Email field
                        _buildTextField(
                          _emailController,
                          'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        
                        // Address field
                        _buildTextField(
                          _addressController,
                          'Address',
                          maxLines: 2,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Location Information
                        _buildSectionTitle('Location Information'),
                        
                        // Constituency dropdown
                        _buildDropdown(
                          'Constituency',
                          _selectedConstituency,
                          _constituencies.map((item) => DropdownMenuItem(
                            value: item['id'],
                            child: Text(item['name']),
                          )).toList(),
                          (value) {
                            setState(() {
                              _selectedConstituency = value as int?;
                            });
                            _updateAvailableCities();
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // City dropdown
                        _buildDropdown(
                          'City',
                          _selectedCity,
                          _availableCities.map((item) => DropdownMenuItem(
                            value: item['id'],
                            child: Text(item['name']),
                          )).toList(),
                          (value) {
                            setState(() {
                              _selectedCity = value as int?;
                            });
                          },
                          enabled: _availableCities.isNotEmpty,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Priority and Connection
                        _buildSectionTitle('Primary Contact Details'),
                        
                        // Priority slider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority: $_priority',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Slider(
                              value: _priority.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label: _priority.toString(),
                              activeColor: primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  _priority = value.round();
                                });
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Connection dropdown
                        _buildDropdown(
                          'Connection',
                          _selectedConnection,
                          _connections.map((item) => DropdownMenuItem(
                            value: item['id'],
                            child: Text(item['name']),
                          )).toList(),
                          (value) {
                            setState(() {
                              _selectedConnection = value as int?;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Tags section
                        _buildSectionTitle('Tags'),
                        
                        // Tag category dropdown
                        _buildDropdown(
                          'Tag Category',
                          _selectedTagCategory,
                          _tagCategories.map((item) => DropdownMenuItem(
                            value: item['id'],
                            child: Text(item['name']),
                          )).toList(),
                          (value) {
                            setState(() {
                              _selectedTagCategory = value as int?;
                            });
                            _updateAvailableTagNames();
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Tag name dropdown and add button
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                'Tag',
                                _selectedTagName,
                                _availableTagNames.map((item) => DropdownMenuItem(
                                  value: item['id'],
                                  child: Text(item['name']),
                                )).toList(),
                                (value) {
                                  setState(() {
                                    _selectedTagName = value as int?;
                                  });
                                },
                                enabled: _availableTagNames.isNotEmpty,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _selectedTagName != null ? _addSelectedTag : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Add Tag'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Selected tags
                        if (selectedTags.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedTags.map((tag) => Chip(
                              label: Text(
                                "${tag['name']} (${tag['categoryName']})",
                                style: TextStyle(color: primaryColor),
                              ),
                              backgroundColor: primaryColor.withOpacity(0.1),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeTag(tag),
                            )).toList(),
                          ),
                        
                        const SizedBox(height: 24),
                        
                        // Notes
                        _buildSectionTitle('Notes'),
                        _buildTextField(
                          _noteController,
                          'Notes',
                          maxLines: 4,
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    void Function(T?) onChanged, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text('Select $label'),
              items: items,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }
}