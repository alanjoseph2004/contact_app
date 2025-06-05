import 'package:flutter/material.dart';
import 'contact_logic.dart';
import '../services/edit_primary_contact_service.dart';
import '../widgets/add_tags_widget.dart';
import '../widgets/personal_details_widget.dart';
import '../utils/form_utils.dart';

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
  final _apiService = ContactApiService();
  
  // Controllers
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
  List<Map<String, dynamic>> _connections = [];
  List<Map<String, dynamic>> _constituencies = [];
  List<Map<String, dynamic>> _tagCategories = [];
  List<Map<String, dynamic>> _availableTagNames = [];
  List<int> _priorityLevels = [1, 2, 3, 4, 5];
  
  // Selected values
  int? _selectedCity;
  int? _selectedConstituency;
  int? _selectedConnection;
  int _selectedPriority = 5;
  int? _selectedTagCategory;
  int? _selectedTagName;
  int? _selectedPartyBlock;
  int? _selectedPartyConstituency;
  int? _selectedBooth;
  int? _selectedParliamentaryConstituency;
  int? _selectedLocalBody;
  int? _selectedWard;
  
  // Available cities based on selected constituency
  List<Map<String, dynamic>> _availableCities = [];
  
  // Selected tags
  List<Map<String, dynamic>> _tags = [];
  
  // State variables
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setInitialValues();
    _loadInitialData();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }
  
  void _initializeControllers() {
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
  }
  
  void _disposeControllers() {
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
  }
  
  void _setInitialValues() {
    _selectedCity = widget.contact.city != null ? int.tryParse(widget.contact.city!) : null;
    _selectedConstituency = widget.contact.constituency != null ? int.tryParse(widget.contact.constituency!) : null;
    _selectedConnection = widget.contact.connection != null ? int.tryParse(widget.contact.connection!) : null;
    _selectedPriority = widget.contact.priority ?? 5;
  }
  
  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
    });
    
    try {
      final data = await _apiService.loadInitialData();
      
      setState(() {
        _connections = data['connections'];
        _constituencies = data['constituencies'];
        _tagCategories = data['tagCategories'];
      });
      
      // After loading constituencies, update available cities
      if (_selectedConstituency != null) {
        _updateAvailableCities();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

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
  
  void _addTag() {
    if (_selectedTagName != null && _selectedTagCategory != null) {
      final tagName = _availableTagNames.firstWhere(
        (tag) => tag['id'] == _selectedTagName,
        orElse: () => {'id': _selectedTagName, 'name': 'Unknown'},
      );
      
      final tagCategory = _tagCategories.firstWhere(
        (category) => category['id'] == _selectedTagCategory,
        orElse: () => {'id': _selectedTagCategory, 'name': 'Unknown'},
      );
      
      final isTagAlreadyAdded = _tags.any((tag) => tag['id'] == _selectedTagName);
      
      if (!isTagAlreadyAdded) {
        setState(() {
          _tags.add({
            'id': _selectedTagName,
            'name': tagName['name'],
            'tag_category': tagCategory['name'],
            'category_id': _selectedTagCategory,
          });
          _selectedTagName = null;
        });
      } else {
        _showSnackBar('Tag "${tagName['name']}" is already added', Colors.orange);
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
      final updatedContact = await _apiService.updatePrimaryContact(
        contactId: widget.contact.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text.isEmpty ? null : _lastNameController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        countryCode: _countryCodeController.text,
        phone: _phoneController.text,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        city: _selectedCity,
        priority: _selectedPriority,
        connection: _selectedConnection,
        tagIds: _tags.map((tag) => tag['id'] as int).toList(),
        originalContact: widget.contact,
      );
      
      _showSnackBar('Contact updated successfully!', Colors.green);
      Navigator.pop(context, updatedContact);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
          'Edit Primary Contact',
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
                          FormUtils.buildErrorMessage(_errorMessage),
                          
                          // Personal Details Section - Using PersonalDetailsWidget
                          PersonalDetailsWidget(
                            firstNameController: _firstNameController,
                            lastNameController: _lastNameController,
                            emailController: _emailController,
                            countryCodeController: _countryCodeController,
                            phoneController: _phoneController,
                            noteController: _noteController,
                            showNotes: true,
                            showSectionTitle: true,
                            sectionTitle: 'Personal Details',
                          ),
                          const SizedBox(height: 32),

                          // Other Details Section
                          FormUtils.buildSectionTitle('Other Details'),
                          const SizedBox(height: 16),

                          // District Dropdown
                          FormUtils.buildDropdownField<int?>(
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
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a district';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Assembly Constituency
                          FormUtils.buildDropdownField<int?>(
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
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a constituency';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Party Block
                          FormUtils.buildDropdownField<int?>(
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
                          FormUtils.buildDropdownField<int?>(
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
                          FormUtils.buildDropdownField<int?>(
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
                          FormUtils.buildDropdownField<int?>(
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
                          FormUtils.buildDropdownField<int?>(
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
                          FormUtils.buildDropdownField<int?>(
                            value: _selectedWard,
                            labelText: 'Ward',
                            items: const [],
                            onChanged: (value) {
                              setState(() {
                                _selectedWard = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Priority
                          FormUtils.buildDropdownField<int>(
                            value: _selectedPriority,
                            labelText: 'Priority 5',
                            items: _priorityLevels.map((int priority) {
                              return DropdownMenuItem<int>(
                                value: priority,
                                child: Text(priority.toString()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPriority = value ?? 5;
                              });
                            },
                          ),
                          const SizedBox(height: 32),

                          // Residential Details Section
                          FormUtils.buildSectionTitle('Residential Details'),
                          const SizedBox(height: 16),

                          // House Name
                          FormUtils.buildTextField(
                            controller: _addressController,
                            labelText: 'House Name',
                          ),
                          const SizedBox(height: 16),

                          // House Number
                          FormUtils.buildTextField(
                            controller: _houseNumberController,
                            labelText: 'House Number',
                          ),
                          const SizedBox(height: 16),

                          // City
                          FormUtils.buildTextField(
                            controller: _cityController,
                            labelText: 'City',
                          ),
                          const SizedBox(height: 16),

                          // Post Office
                          FormUtils.buildTextField(
                            controller: _postOfficeController,
                            labelText: 'Post Office',
                          ),
                          const SizedBox(height: 16),

                          // Pin Code
                          FormUtils.buildTextField(
                            controller: _pinCodeController,
                            labelText: 'Pin Code',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 32),

                          // Tags Section - Using the reusable widget
                          AddTagsWidget(
                            selectedTagCategory: _selectedTagCategory,
                            selectedTagName: _selectedTagName,
                            tagCategories: _tagCategories,
                            availableTagNames: _availableTagNames,
                            tags: _tags,
                            onTagCategoryChanged: (value) {
                              setState(() {
                                _selectedTagCategory = value;
                                _updateAvailableTagNames();
                              });
                            },
                            onTagNameChanged: (value) {
                              setState(() {
                                _selectedTagName = value;
                              });
                            },
                            onAddTag: _addTag,
                            onRemoveTag: _removeTag,
                            sectionTitle: 'Add Tags',
                            showSectionTitle: true,
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
                // Loading overlay using FormUtils
                FormUtils.buildLoadingOverlay(
                  message: 'Updating contact...',
                  isVisible: _isLoading,
                ),
              ],
            ),
    );
  }
}