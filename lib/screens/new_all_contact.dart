import 'package:flutter/material.dart';
import 'new_all_contact_ui.dart';
import '../services/new_all_contact_service.dart';

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
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postOfficeController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  // API data lists
  List<Map<String, dynamic>> _primaryContacts = [];
  List<Map<String, dynamic>> _constituencies = [];
  List<Map<String, dynamic>> _tagCategories = [];
  List<Map<String, dynamic>> _availableTagNames = [];
  List<int> _priorityLevels = [1, 2, 3, 4, 5];
  List<Map<String, dynamic>> _tags = [];
  
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
  int _selectedPriority = 5;
  int? _selectedTagCategory;
  int? _selectedTagName;

  // Available cities based on selected constituency
  List<Map<String, dynamic>> _availableCities = [];

  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _countryCodeController.text = '+91'; // Set default country code
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
        _fetchTagCategories(),
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

  // Fetch primary contacts using service
  Future<void> _fetchPrimaryContacts() async {
    try {
      final contacts = await NewAllContactService.fetchPrimaryContacts();
      setState(() {
        _primaryContacts = contacts;
      });
    } catch (e) {
      print('Exception in _fetchPrimaryContacts: $e');
      rethrow;
    }
  }

  // Fetch constituencies using service
  Future<void> _fetchConstituencies() async {
    try {
      final constituencies = await NewAllContactService.fetchConstituencies();
      setState(() {
        _constituencies = constituencies;
      });
    } catch (e) {
      print('Exception in _fetchConstituencies: $e');
      rethrow;
    }
  }

  // Fetch tag categories using service
  Future<void> _fetchTagCategories() async {
    try {
      // Replace with actual service call when available
      // final tagCategories = await NewAllContactService.fetchTagCategories();
      setState(() {
        _tagCategories = []; // Placeholder - replace with actual data
      });
    } catch (e) {
      print('Exception in _fetchTagCategories: $e');
      rethrow;
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

  // Update available tag names when tag category is selected
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

  // Add tag to the list
  void _addTag() {
    if (_selectedTagName != null) {
      final tagName = _availableTagNames.firstWhere(
        (tag) => tag['id'] == _selectedTagName,
        orElse: () => {'name': ''},
      );
      
      final newTag = {
        'id': _selectedTagName,
        'name': tagName['name'],
      };
      
      // Check if tag already exists
      if (!_tags.any((tag) => tag['id'] == _selectedTagName)) {
        setState(() {
          _tags.add(newTag);
          _selectedTagName = null; // Reset selection
        });
      }
    }
  }

  // Remove tag from the list
  void _removeTag(Map<String, dynamic> tagToRemove) {
    setState(() {
      _tags.removeWhere((tag) => tag['id'] == tagToRemove['id']);
    });
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Call the service to create contact
        final result = await NewAllContactService.createContact(
          referredBy: _selectedReferredBy,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text.isEmpty ? null : _lastNameController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          countryCode: _countryCodeController.text,
          phone: _phoneController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          address: _addressController.text.isEmpty ? null : _addressController.text,
          city: _selectedCity,
          // Add additional parameters as needed for the expanded form
          
        );

        if (result['success']) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Contact saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back or to a success page
          Navigator.of(context).pop();
        } else {
          // Error
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to save contact. Please try again.';
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
      houseNumberController: _houseNumberController,
      cityController: _cityController,
      postOfficeController: _postOfficeController,
      pinCodeController: _pinCodeController,
      selectedReferredBy: _selectedReferredBy,
      selectedCity: _selectedCity,
      selectedConstituency: _selectedConstituency,
      selectedPartyBlock: _selectedPartyBlock,
      selectedPartyConstituency: _selectedPartyConstituency,
      selectedBooth: _selectedBooth,
      selectedParliamentaryConstituency: _selectedParliamentaryConstituency,
      selectedLocalBody: _selectedLocalBody,
      selectedWard: _selectedWard,
      selectedPriority: _selectedPriority,
      selectedTagCategory: _selectedTagCategory,
      selectedTagName: _selectedTagName,
      primaryContacts: _primaryContacts,
      constituencies: _constituencies,
      availableCities: _availableCities,
      tagCategories: _tagCategories,
      availableTagNames: _availableTagNames,
      priorityLevels: _priorityLevels,
      tags: _tags,
      onReferredByChanged: (value) => setState(() => _selectedReferredBy = value),
      onConstituencyChanged: (value) {
        setState(() {
          _selectedConstituency = value;
          _updateAvailableCities();
        });
      },
      onCityChanged: (value) => setState(() => _selectedCity = value),
      onPriorityChanged: (value) => setState(() => _selectedPriority = value ?? 5),
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
    _houseNumberController.dispose();
    _cityController.dispose();
    _postOfficeController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }
}