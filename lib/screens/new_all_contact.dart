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
  final TextEditingController _houseNameController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postOfficeController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  // API data lists
  List<Map<String, dynamic>> _primaryContacts = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _assemblyConstituencies = [];
  List<Map<String, dynamic>> _partyBlocks = [];
  List<Map<String, dynamic>> _partyConstituencies = [];
  List<Map<String, dynamic>> _parliamentaryConstituencies = [];
  List<Map<String, dynamic>> _tagCategories = [];
  List<Map<String, dynamic>> _tags = [];
  
  // Selected values
  int? _selectedReferredBy;
  int? _selectedDistrict;
  int? _selectedAssemblyConstituency;
  int? _selectedPartyBlock;
  int? _selectedPartyConstituency;
  int? _selectedParliamentaryConstituency;
  // int? _selectedBooth;
  // int? _selectedLocalBody;
  // int? _selectedWard;
  int? _selectedTagCategory;
  int? _selectedTagName;
  List<int> _selectedTagIds = [];

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
      _errorMessage = null;
    });
    
    try {
      await Future.wait([
        _fetchPrimaryContacts(),
        _fetchDistricts(),
        _fetchParliamentaryConstituencies(),
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

  // Fetch districts using service
  Future<void> _fetchDistricts() async {
    try {
      final districts = await NewAllContactService.fetchDistricts();
      setState(() {
        _districts = districts;
      });
    } catch (e) {
      print('Exception in _fetchDistricts: $e');
      rethrow;
    }
  }

  // Fetch assembly constituencies for selected district
  Future<void> _fetchAssemblyConstituencies(int districtId) async {
    try {
      final constituencies = await NewAllContactService.fetchAssemblyConstituencies(districtId);
      setState(() {
        _assemblyConstituencies = constituencies;
        _selectedAssemblyConstituency = null; // Reset selection
        // Reset dependent dropdowns
        _partyBlocks = [];
        _selectedPartyBlock = null;
        _partyConstituencies = [];
        _selectedPartyConstituency = null;
      });
    } catch (e) {
      print('Exception in _fetchAssemblyConstituencies: $e');
      setState(() {
        _assemblyConstituencies = [];
        _selectedAssemblyConstituency = null;
        _partyBlocks = [];
        _selectedPartyBlock = null;
        _partyConstituencies = [];
        _selectedPartyConstituency = null;
      });
    }
  }

  // Fetch party blocks for selected assembly constituency
  Future<void> _fetchPartyBlocks(int districtId, int assemblyConstituencyId) async {
    try {
      final partyBlocks = await NewAllContactService.fetchPartyBlocks(districtId, assemblyConstituencyId);
      setState(() {
        _partyBlocks = partyBlocks;
        _selectedPartyBlock = null; // Reset selection
        // Reset dependent dropdowns
        _partyConstituencies = [];
        _selectedPartyConstituency = null;
      });
    } catch (e) {
      print('Exception in _fetchPartyBlocks: $e');
      setState(() {
        _partyBlocks = [];
        _selectedPartyBlock = null;
        _partyConstituencies = [];
        _selectedPartyConstituency = null;
      });
    }
  }

  // Fetch party constituencies for selected party block
  Future<void> _fetchPartyConstituencies(int districtId, int assemblyConstituencyId, int partyBlockId) async {
    try {
      final partyConstituencies = await NewAllContactService.fetchPartyConstituencies(districtId, assemblyConstituencyId, partyBlockId);
      setState(() {
        _partyConstituencies = partyConstituencies;
        _selectedPartyConstituency = null; // Reset selection
      });
    } catch (e) {
      print('Exception in _fetchPartyConstituencies: $e');
      setState(() {
        _partyConstituencies = [];
        _selectedPartyConstituency = null;
      });
    }
  }

  // Fetch parliamentary constituencies using service
  Future<void> _fetchParliamentaryConstituencies() async {
    try {
      final constituencies = await NewAllContactService.fetchParliamentaryConstituencies();
      setState(() {
        _parliamentaryConstituencies = constituencies;
      });
    } catch (e) {
      print('Exception in _fetchParliamentaryConstituencies: $e');
      rethrow;
    }
  }

  // Fetch tag categories and tags using service
  Future<void> _fetchTagData() async {
    try {
      final tagData = await NewAllContactService.fetchTagData();
      setState(() {
        _tagCategories = tagData;
      });
    } catch (e) {
      print('Exception in _fetchTagData: $e');
      rethrow;
    }
  }

  // Update available assembly constituencies when district is selected
  void _updateAssemblyConstituencies() {
    if (_selectedDistrict != null) {
      _fetchAssemblyConstituencies(_selectedDistrict!);
    } else {
      setState(() {
        _assemblyConstituencies = [];
        _selectedAssemblyConstituency = null;
        _partyBlocks = [];
        _selectedPartyBlock = null;
        _partyConstituencies = [];
        _selectedPartyConstituency = null;
      });
    }
  }

  // Update available party blocks when assembly constituency is selected
  void _updatePartyBlocks() {
    if (_selectedDistrict != null && _selectedAssemblyConstituency != null) {
      _fetchPartyBlocks(_selectedDistrict!, _selectedAssemblyConstituency!);
    } else {
      setState(() {
        _partyBlocks = [];
        _selectedPartyBlock = null;
        _partyConstituencies = [];
        _selectedPartyConstituency = null;
      });
    }
  }

  // Update available party constituencies when party block is selected
  void _updatePartyConstituencies() {
    if (_selectedDistrict != null && _selectedAssemblyConstituency != null && _selectedPartyBlock != null) {
      _fetchPartyConstituencies(_selectedDistrict!, _selectedAssemblyConstituency!, _selectedPartyBlock!);
    } else {
      setState(() {
        _partyConstituencies = [];
        _selectedPartyConstituency = null;
      });
    }
  }

  // Update available tags when tag category is selected
  void _updateAvailableTags() {
    if (_selectedTagCategory != null) {
      final category = _tagCategories.firstWhere(
        (c) => c['id'] == _selectedTagCategory,
        orElse: () => {'tags': []},
      );
      
      setState(() {
        _tags = List<Map<String, dynamic>>.from(category['tags'] ?? []);
        _selectedTagName = null; // Reset selected tag name
      });
    } else {
      setState(() {
        _tags = [];
        _selectedTagName = null;
      });
    }
  }

  // Add tag to the selected list
  void _addTag() {
    if (_selectedTagName != null && !_selectedTagIds.contains(_selectedTagName)) {
      setState(() {
        _selectedTagIds.add(_selectedTagName!);
        _selectedTagName = null; // Reset selection
      });
    }
  }

  // Remove tag from the selected list
  void _removeTag(int tagId) {
    setState(() {
      _selectedTagIds.remove(tagId);
    });
  }

  // Get tag name by ID
  String _getTagName(int tagId) {
    for (var category in _tagCategories) {
      final tags = category['tags'] as List<dynamic>;
      final tag = tags.firstWhere(
        (t) => t['id'] == tagId,
        orElse: () => {'name': 'Unknown Tag'},
      );
      if (tag['name'] != 'Unknown Tag') {
        return tag['name'];
      }
    }
    return 'Unknown Tag';
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      // Validate required fields
      if (_selectedReferredBy == null) {
        setState(() {
          _errorMessage = 'Please select who referred this contact';
        });
        return;
      }

      if (_selectedDistrict == null) {
        setState(() {
          _errorMessage = 'Please select a district';
        });
        return;
      }

      if (_selectedAssemblyConstituency == null) {
        setState(() {
          _errorMessage = 'Please select an assembly constituency';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Call the service to create contact
        final result = await NewAllContactService.createContact(
          referredBy: _selectedReferredBy!,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text.isEmpty ? null : _lastNameController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          countryCode: _countryCodeController.text,
          phone: _phoneController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          districtId: _selectedDistrict!,
          assemblyConstituencyId: _selectedAssemblyConstituency!,
          partyBlockId: _selectedPartyBlock,
          partyConstituencyId: _selectedPartyConstituency,
          // boothId: _selectedBooth,
          parliamentaryConstituencyId: _selectedParliamentaryConstituency,
          // localBodyId: _selectedLocalBody,
          // wardId: _selectedWard,
          houseName: _houseNameController.text.isEmpty ? null : _houseNameController.text,
          houseNumber: _houseNumberController.text.isEmpty ? null : int.tryParse(_houseNumberController.text),
          city: _cityController.text.isEmpty ? null : _cityController.text,
          postOffice: _postOfficeController.text.isEmpty ? null : _postOfficeController.text,
          pinCode: _pinCodeController.text.isEmpty ? null : _pinCodeController.text,
          tagIds: _selectedTagIds,
        );

        if (result['success']) {
          // Success
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Contact saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navigate back or to a success page
            Navigator.of(context).pop();
          }
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
      houseNameController: _houseNameController,
      houseNumberController: _houseNumberController,
      cityController: _cityController,
      postOfficeController: _postOfficeController,
      pinCodeController: _pinCodeController,
      selectedReferredBy: _selectedReferredBy,
      selectedDistrict: _selectedDistrict,
      selectedAssemblyConstituency: _selectedAssemblyConstituency,
      selectedPartyBlock: _selectedPartyBlock,
      selectedPartyConstituency: _selectedPartyConstituency,
      selectedParliamentaryConstituency: _selectedParliamentaryConstituency,
      // selectedBooth: _selectedBooth,
      // selectedLocalBody: _selectedLocalBody,
      // selectedWard: _selectedWard,
      selectedTagCategory: _selectedTagCategory,
      selectedTagName: _selectedTagName,
      selectedTagIds: _selectedTagIds,
      primaryContacts: _primaryContacts,
      districts: _districts,
      assemblyConstituencies: _assemblyConstituencies,
      partyBlocks: _partyBlocks,
      partyConstituencies: _partyConstituencies,
      parliamentaryConstituencies: _parliamentaryConstituencies,
      tagCategories: _tagCategories,
      tags: _tags,
      onReferredByChanged: (value) => setState(() => _selectedReferredBy = value),
      onDistrictChanged: (value) {
        setState(() {
          _selectedDistrict = value;
          _updateAssemblyConstituencies();
        });
      },
      onAssemblyConstituencyChanged: (value) {
        setState(() {
          _selectedAssemblyConstituency = value;
          _updatePartyBlocks();
        });
      },
      onPartyBlockChanged: (value) {
        setState(() {
          _selectedPartyBlock = value;
          _updatePartyConstituencies();
        });
      },
      onPartyConstituencyChanged: (value) => setState(() => _selectedPartyConstituency = value),
      onParliamentaryConstituencyChanged: (value) => setState(() => _selectedParliamentaryConstituency = value),
      // onBoothChanged: (value) => setState(() => _selectedBooth = value),
      // onLocalBodyChanged: (value) => setState(() => _selectedLocalBody = value),
      // onWardChanged: (value) => setState(() => _selectedWard = value),
      onTagCategoryChanged: (value) {
        setState(() {
          _selectedTagCategory = value;
          _updateAvailableTags();
        });
      },
      onTagNameChanged: (value) => setState(() => _selectedTagName = value),
      onAddTag: _addTag,
      onRemoveTag: _removeTag,
      getTagName: _getTagName,
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