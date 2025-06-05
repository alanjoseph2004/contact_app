import 'package:flutter/material.dart';
import 'contact_logic.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_contact_ui.dart';

class EditContactDialog extends StatefulWidget {
  final Contact contact;
  final Color primaryColor;

  const EditContactDialog({
    super.key, 
    required this.contact, 
    required this.primaryColor, required bool isFullScreen
  });

  @override
  _EditContactDialogState createState() => _EditContactDialogState();
}

class _EditContactDialogState extends State<EditContactDialog> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController countryCodeController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController referredByController;
  late TextEditingController noteController;
  late TextEditingController addressController;
  
  late ContactType selectedType;
  int? priority;
  String? connectionId;
  List<Contact> primaryContacts = [];
  
  // Dropdown values for API data
  int? _selectedConstituency;
  int? _selectedCity;
  int? _selectedTagCategory;
  int? _selectedTagName;
  
  // Lists to store API data
  List<Map<String, dynamic>> _constituencies = [];
  List<Map<String, dynamic>> _availableCities = [];
  List<Map<String, dynamic>> _tagCategories = [];
  List<Map<String, dynamic>> _availableTagNames = [];
  
  // Selected tags list
  List<Map<String, dynamic>> selectedTags = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing contact data
    firstNameController = TextEditingController(text: widget.contact.firstName);
    lastNameController = TextEditingController(text: widget.contact.lastName ?? '');
    countryCodeController = TextEditingController(text: widget.contact.countryCode);
    phoneController = TextEditingController(text: widget.contact.phone);
    emailController = TextEditingController(text: widget.contact.email ?? '');
    referredByController = TextEditingController(text: widget.contact.connection ?? '');
    noteController = TextEditingController(text: widget.contact.note ?? '');
    addressController = TextEditingController(text: widget.contact.address ?? '');
    
    selectedType = widget.contact.type;
    priority = widget.contact.priority;
    connectionId = widget.contact.connection;
    
    // Load primary contacts for the connection dropdown
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load all necessary data in parallel
      await Future.wait([
        _loadPrimaryContacts(),
        _fetchConstituencies(),
        _fetchTagData()
      ]);
      
      // Set initial values based on existing contact data
      if (widget.contact.constituency != null) {
        // Try to find the constituency by name in the loaded data
        final constituencyData = _constituencies.firstWhere(
          (c) => c['name'] == widget.contact.constituency,
          orElse: () => {'id': null}
        );
        
        if (constituencyData['id'] != null) {
          _selectedConstituency = constituencyData['id'];
          _updateAvailableCities();
          
          // If we have city data, try to find it in available cities
          if (widget.contact.city != null) {
            final cityData = _availableCities.firstWhere(
              (c) => c['name'] == widget.contact.city,
              orElse: () => {'id': null}
            );
            
            if (cityData['id'] != null) {
              _selectedCity = cityData['id'];
            }
          }
        }
      }
      
      // Initialize selected tags if any
      if (widget.contact.tags != null && widget.contact.tags!.isNotEmpty) {
        await _loadExistingTags();
      }
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadExistingTags() async {
    // For each tag in the contact, find its corresponding tag data
    selectedTags = [];
    
    for (String tagName in widget.contact.tags ?? []) {
      // Search through all categories and their tags
      for (var category in _tagCategories) {
        final foundTag = (category['tags'] as List).firstWhere(
          (tag) => tag['name'] == tagName,
          orElse: () => null
        );
        
        if (foundTag != null) {
          // Add the tag with category info
          selectedTags.add({
            'id': foundTag['id'],
            'name': foundTag['name'],
            'categoryId': category['id'],
            'categoryName': category['name']
          });
          break;
        }
      }
    }
  }

  Future<void> _loadPrimaryContacts() async {
    primaryContacts = await ContactService.getContactsByType(ContactType.primary);
    setState(() {});
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

  Future<void> _saveContact(BuildContext context) async {
    // Show loading indicator
    setState(() {
      _isLoading = true;
    });
    
    // Validation
    if (firstNameController.text.isEmpty || 
        phoneController.text.isEmpty || 
        countryCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("First name, country code, and phone number are required"))
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validate priority for primary contacts
    if (selectedType == ContactType.primary && priority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Priority is required for primary contacts"))
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Get constituency and city names for local storage
      String? constituencyName;
      if (_selectedConstituency != null) {
        final constituency = _constituencies.firstWhere(
          (c) => c['id'] == _selectedConstituency,
          orElse: () => {'name': null}
        );
        constituencyName = constituency['name'];
      }
      
      String? cityName;
      if (_selectedCity != null) {
        final city = _availableCities.firstWhere(
          (c) => c['id'] == _selectedCity,
          orElse: () => {'name': null}
        );
        cityName = city['name'];
      }
      
      // Extract tag names for local storage
      List<String> tagNames = selectedTags.map((tag) => tag['name'].toString()).toList();
      
      final updatedContact = Contact(
        id: widget.contact.id,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.isEmpty ? null : lastNameController.text.trim(),
        countryCode: countryCodeController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.isEmpty ? null : emailController.text.trim(),
        avatarUrl: widget.contact.avatarUrl,
        hasMessages: widget.contact.hasMessages,
        type: selectedType,
        priority: selectedType == ContactType.primary ? priority : null,
        connection: selectedType == ContactType.all ? connectionId : null,
        note: noteController.text.isEmpty ? null : noteController.text.trim(),
        address: addressController.text.isEmpty ? null : addressController.text.trim(),
        city: cityName,
        constituency: constituencyName,
        tags: tagNames.isEmpty ? null : tagNames,
      );

      // For primary contacts, update via API
      if (selectedType == ContactType.primary) {
        await _updatePrimaryContactViaAPI(updatedContact);
      }
      
      // Always update in local storage
      await ContactService.updateContact(updatedContact);
      
      if (context.mounted) {
        Navigator.of(context).pop(updatedContact);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contact updated successfully"))
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating contact: ${e.toString()}"))
        );
      }
    }
  }

  Future<void> _updatePrimaryContactViaAPI(Contact contact) async {
    // Get JWT token
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    if (token == null || token.isEmpty) {
      throw Exception("JWT token is missing");
    }
    
    // Extract tag IDs for API request
    List<int> tagIds = selectedTags.map((tag) => tag['id'] as int).toList();

    // Prepare the request body according to API requirements
    final Map<String, dynamic> requestBody = {
      "contact": {
        "first_name": contact.firstName,
        "last_name": contact.lastName ?? "",
        "email": contact.email ?? "",
        "country_code": contact.countryCode,
        "phone": contact.phone,
        "note": contact.note ?? "",
        "address": contact.address ?? "",
        "city": _selectedCity ?? 1,  // Use the city ID from dropdown
      },
      "priority": contact.priority ?? 1,  // Default to 1 if null
      "connection": connectionId != null && connectionId!.isNotEmpty ? int.tryParse(connectionId!) ?? 1 : 1,
      "tags": tagIds,
    };

    // Make the API call
    final response = await http.put(
      Uri.parse('http://51.21.152.136:8000/contact/primary-contact/update/${contact.id}/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    // Handle the response
    if (response.statusCode != 200) {
      throw Exception('Failed to update contact: ${response.body}');
    }

  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    countryCodeController.dispose();
    phoneController.dispose();
    emailController.dispose();
    referredByController.dispose();
    noteController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditContactUI(
      primaryColor: widget.primaryColor,
      isLoading: _isLoading,
      firstNameController: firstNameController,
      lastNameController: lastNameController,
      countryCodeController: countryCodeController,
      phoneController: phoneController,
      emailController: emailController,
      addressController: addressController,
      noteController: noteController,
      selectedType: selectedType,
      onTypeChanged: (value) {
        if (value != null) {
          setState(() {
            selectedType = value;
            // Reset priority if changing from primary to all
            if (value != ContactType.primary) {
              priority = null;
            }
          });
        }
      },
      priority: priority,
      onPriorityChanged: (value) {
        setState(() {
          priority = value;
        });
      },
      connectionId: connectionId,
      onConnectionChanged: (value) {
        setState(() {
          connectionId = value;
        });
      },
      primaryContacts: primaryContacts,
      selectedConstituency: _selectedConstituency,
      onConstituencyChanged: (value) {
        setState(() {
          _selectedConstituency = value;
          _updateAvailableCities();
        });
      },
      constituencies: _constituencies,
      selectedCity: _selectedCity,
      onCityChanged: (value) {
        setState(() {
          _selectedCity = value;
        });
      },
      availableCities: _availableCities,
      selectedTagCategory: _selectedTagCategory,
      onTagCategoryChanged: (value) {
        setState(() {
          _selectedTagCategory = value;
          _updateAvailableTagNames();
        });
      },
      tagCategories: _tagCategories,
      selectedTagName: _selectedTagName,
      onTagNameChanged: (value) {
        setState(() {
          _selectedTagName = value;
        });
      },
      availableTagNames: _availableTagNames,
      selectedTags: selectedTags,
      onTagDeleted: (tagId) {
        setState(() {
          selectedTags.removeWhere((t) => t['id'] == tagId);
        });
      },
      onAddTag: _addSelectedTag,
      onSave: () => _saveContact(context),
      onCancel: () => Navigator.of(context).pop(),
    );
  }
}