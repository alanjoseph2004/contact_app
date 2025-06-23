import 'package:flutter/material.dart';
import 'new_primary_contact_ui.dart';
import '../services/new_primary_contact_service.dart';

class NewPrimaryContactPage extends StatefulWidget {
  const NewPrimaryContactPage({super.key});

  @override
  State<NewPrimaryContactPage> createState() => _NewPrimaryContactPageState();
}

class _NewPrimaryContactPageState extends State<NewPrimaryContactPage> {
  final Color primaryColor = const Color(0xFF283593);
  final PrimaryContactService _contactService = PrimaryContactService();
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _houseNameController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postOfficeController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  // API data lists
  List<Map<String, dynamic>> _connections = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _assemblyConstituencies = [];
  List<Map<String, dynamic>> _parliamentaryConstituencies = [];
  
  // Tag data structure
  List<Map<String, dynamic>> _tagCategories = [];
  List<Map<String, dynamic>> _availableTagNames = [];
  
  // Selected values
  int? _selectedConnection;
  int _selectedPriority = 5;
  int? _selectedDistrict;
  int? _selectedAssemblyConstituency;
  int? _selectedParliamentaryConstituency;
  int? _selectedTagCategory;
  int? _selectedTagName;

  final List<int> _priorityLevels = List.generate(5, (index) => index + 1);

  // Selected tags
  final List<Map<String, dynamic>> _tags = [];

  bool _isLoading = false;
  bool _isInitialLoading = true;
  bool _isLoadingAssemblyConstituencies = false;
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
      _errorMessage = null;
    });
    
    try {
      final results = await Future.wait([
        _contactService.fetchConnections(),
        _contactService.fetchDistricts(),
        _contactService.fetchParliamentaryConstituencies(),
        _contactService.fetchTagData(),
      ]);

      setState(() {
        _connections = results[0];
        _districts = results[1];
        _parliamentaryConstituencies = results[2];
        _tagCategories = results[3];
        
        // Set default connection if available
        if (_connections.isNotEmpty) {
          _selectedConnection = _connections.first['id'];
        }
      });
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

  // Update available assembly constituencies when district is selected
  Future<void> _updateAvailableAssemblyConstituencies() async {
    if (_selectedDistrict != null) {
      setState(() {
        _isLoadingAssemblyConstituencies = true;
        _selectedAssemblyConstituency = null; // Reset selected assembly constituency
        _assemblyConstituencies = [];
      });

      try {
        final constituencies = await _contactService.fetchAssemblyConstituencies(_selectedDistrict!);
        setState(() {
          _assemblyConstituencies = constituencies;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to load assembly constituencies: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoadingAssemblyConstituencies = false;
        });
      }
    } else {
      setState(() {
        _assemblyConstituencies = [];
        _selectedAssemblyConstituency = null;
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
      // Validate required fields
      if (_selectedDistrict == null || 
          _selectedAssemblyConstituency == null || 
          _selectedConnection == null) {
        setState(() {
          _errorMessage = 'Please fill all required fields (District, Assembly Constituency, Connection)';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final success = await _contactService.createPrimaryContact(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text.isEmpty ? null : _lastNameController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          countryCode: _countryCodeController.text,
          phone: _phoneController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          districtId: _selectedDistrict!,
          assemblyConstituencyId: _selectedAssemblyConstituency!,
          parliamentaryConstituencyId: _selectedParliamentaryConstituency,
          houseName: _houseNameController.text.isEmpty ? null : _houseNameController.text,
          houseNumber: _houseNumberController.text.isEmpty ? null : int.tryParse(_houseNumberController.text),
          city: _cityController.text.isEmpty ? null : _cityController.text,
          postOffice: _postOfficeController.text.isEmpty ? null : _postOfficeController.text,
          pinCode: _pinCodeController.text.isEmpty ? null : _pinCodeController.text,
          priority: _selectedPriority,
          connectionId: _selectedConnection!,
          tagIds: _tags.map((tag) => tag['id'] as int).toList(),
        );

        if (success) {
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contact saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navigate back
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
      isLoadingAssemblyConstituencies: _isLoadingAssemblyConstituencies,
      errorMessage: _errorMessage,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      emailController: _emailController,
      countryCodeController: _countryCodeController,
      phoneController: _phoneController,
      noteController: _noteController,
      houseNameController: _houseNameController,
      houseNumberController: _houseNumberController,
      cityController: _cityController,
      postOfficeController: _postOfficeController,
      pinCodeController: _pinCodeController,
      selectedConnection: _selectedConnection,
      selectedPriority: _selectedPriority,
      selectedDistrict: _selectedDistrict,
      selectedAssemblyConstituency: _selectedAssemblyConstituency,
      selectedParliamentaryConstituency: _selectedParliamentaryConstituency,
      selectedTagCategory: _selectedTagCategory,
      selectedTagName: _selectedTagName,
      connections: _connections,
      districts: _districts,
      assemblyConstituencies: _assemblyConstituencies,
      parliamentaryConstituencies: _parliamentaryConstituencies,
      tagCategories: _tagCategories,
      availableTagNames: _availableTagNames,
      priorityLevels: _priorityLevels,
      tags: _tags,
      onConnectionChanged: (value) => setState(() => _selectedConnection = value),
      onPriorityChanged: (value) => setState(() => _selectedPriority = value!),
      onDistrictChanged: (value) {
        setState(() {
          _selectedDistrict = value;
          _updateAvailableAssemblyConstituencies();
        });
      },
      onAssemblyConstituencyChanged: (value) => setState(() => _selectedAssemblyConstituency = value),
      onParliamentaryConstituencyChanged: (value) => setState(() => _selectedParliamentaryConstituency = value),
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
    _houseNameController.dispose();
    _houseNumberController.dispose();
    _cityController.dispose();
    _postOfficeController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }
}