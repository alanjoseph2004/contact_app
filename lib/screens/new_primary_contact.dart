import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'new_primary_contact_ui.dart';

class NewPrimaryContactPage extends StatefulWidget {
  const NewPrimaryContactPage({super.key});

  @override
  State<NewPrimaryContactPage> createState() => _NewPrimaryContactPageState();
}

class _NewPrimaryContactPageState extends State<NewPrimaryContactPage> {
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
  List<Map<String, dynamic>> _connections = [];
  List<Map<String, dynamic>> _constituencies = [];
  
  // Tag data structure
  List<Map<String, dynamic>> _tagCategories = [];
  List<Map<String, dynamic>> _availableTagNames = []; // Available tag names for selected category
  
  // Selected values
  int? _selectedConnection;
  int _selectedPriority = 5;
  int? _selectedCity;
  int? _selectedConstituency;
  int? _selectedTagCategory;
  int? _selectedTagName;

  // Available cities based on selected constituency
  List<Map<String, dynamic>> _availableCities = [];

  final List<int> _priorityLevels = List.generate(5, (index) => index + 1);

  // Selected tags
  final List<Map<String, dynamic>> _tags = [];

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
        _fetchConnections(),
        _fetchConstituencies(),
        _fetchTagData(),
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
        
        if (_connections.isNotEmpty) {
          _selectedConnection = _connections.first['id'];
        }
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
        _selectedCity = null; // Reset selected city
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
          print("JWT token is missing");
          return;
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

        // Make the API call
        final response = await http.post(
          Uri.parse('http://51.21.152.136:8000/contact/primary-contact/create/'),
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
          _selectedTagCategory = null;
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

  @override
  Widget build(BuildContext context) {
    return NewPrimaryContactUI(
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
      selectedConnection: _selectedConnection,
      selectedPriority: _selectedPriority,
      selectedCity: _selectedCity,
      selectedConstituency: _selectedConstituency,
      selectedTagCategory: _selectedTagCategory,
      selectedTagName: _selectedTagName,
      connections: _connections,
      constituencies: _constituencies,
      availableCities: _availableCities,
      tagCategories: _tagCategories,
      availableTagNames: _availableTagNames,
      priorityLevels: _priorityLevels,
      tags: _tags,
      onConnectionChanged: (value) => setState(() => _selectedConnection = value),
      onPriorityChanged: (value) => setState(() => _selectedPriority = value!),
      onConstituencyChanged: (value) {
        setState(() {
          _selectedConstituency = value;
          _updateAvailableCities();
        });
      },
      onCityChanged: (value) => setState(() => _selectedCity = value),
      onTagCategoryChanged: (value) {
        setState(() {
          _selectedTagCategory = value;
          _updateAvailableTagNames();
        });
      },
      onTagNameChanged: (value) => setState(() => _selectedTagName = value),
      onAddTag: _addTag,
      onRemoveTag: _removeTag,
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