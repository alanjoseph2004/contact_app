import 'package:flutter/material.dart';
import 'contact_logic.dart';
import '../services/edit_primary_contact_service.dart';

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
  
  // API data lists
  List<Map<String, dynamic>> _connections = [];
  List<Map<String, dynamic>> _constituencies = [];
  List<Map<String, dynamic>> _tagCategories = [];
  List<Map<String, dynamic>> _availableTagNames = [];
  
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
  }
  
  void _disposeControllers() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
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
    const Color primaryColor = Color(0xFF283593);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(primaryColor),
      body: _buildBody(primaryColor),
      bottomNavigationBar: _buildBottomNavigationBar(primaryColor),
    );
  }
  
  PreferredSizeWidget _buildAppBar(Color primaryColor) {
    return AppBar(
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
    );
  }
  
  Widget _buildBody(Color primaryColor) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null) _buildErrorMessage(),
            _buildProfileHeader(primaryColor),
            const SizedBox(height: 24),
            _buildBasicInformationSection(),
            const SizedBox(height: 24),
            _buildAddressInformationSection(),
            const SizedBox(height: 24),
            _buildPrimaryContactDetailsSection(primaryColor),
            const SizedBox(height: 24),
            _buildTagsSection(primaryColor),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorMessage() {
    return Container(
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
    );
  }
  
  Widget _buildProfileHeader(Color primaryColor) {
    return Center(
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
    );
  }
  
  Widget _buildBasicInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information'),
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
        TextFormField(
          controller: _lastNameController,
          decoration: _inputDecoration('Last Name', Icons.person),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: _inputDecoration('Email', Icons.email),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
      ],
    );
  }
  
  Widget _buildAddressInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Address Information'),
        TextFormField(
          controller: _addressController,
          decoration: _inputDecoration('Address', Icons.location_on),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _selectedConstituency,
          decoration: _inputDecoration('Constituency', Icons.location_city),
          hint: const Text('Select Constituency'),
          isExpanded: true,
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('Select Constituency'),
            ),
            ..._constituencies.map((constituency) => DropdownMenuItem<int>(
              value: constituency['id'],
              child: Text(
                constituency['name'],
                overflow: TextOverflow.ellipsis,
              ),
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
        DropdownButtonFormField<int>(
          value: _selectedCity,
          decoration: _inputDecoration('City', Icons.location_city),
          hint: const Text('Select City'),
          isExpanded: true,
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('Select City'),
            ),
            ..._availableCities.map((city) => DropdownMenuItem<int>(
              value: city['id'],
              child: Text(
                city['name'],
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCity = value;
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildPrimaryContactDetailsSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Primary Contact Details'),
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
        DropdownButtonFormField<int>(
          value: _selectedConnection,
          decoration: _inputDecoration('Connection', Icons.people),
          hint: const Text('Select Connection'),
          isExpanded: true,
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('Select Connection'),
            ),
            ..._connections.map((connection) => DropdownMenuItem<int>(
              value: connection['id'],
              child: Text(
                connection['name'],
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedConnection = value;
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildTagsSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tags'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedTagCategory,
              decoration: _inputDecoration('Tag Category', Icons.category),
              hint: const Text('Select Category'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('Select Category'),
                ),
                ..._tagCategories.map((category) => DropdownMenuItem<int>(
                  value: category['id'],
                  child: Text(
                    category['name'],
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTagCategory = value;
                  _updateAvailableTagNames();
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedTagName,
                    decoration: _inputDecoration('Tag Name', Icons.label),
                    hint: const Text('Select Tag'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('Select Tag'),
                      ),
                      ..._availableTagNames.map((tag) => DropdownMenuItem<int>(
                        value: tag['id'],
                        child: Text(
                          tag['name'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTagName = value;
                      });
                    },
                  ),
                ),
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
          ],
        ),
        const SizedBox(height: 16),
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
      ],
    );
  }
  
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Notes'),
        TextFormField(
          controller: _noteController,
          decoration: _inputDecoration('Notes', Icons.note),
          maxLines: 4,
        ),
      ],
    );
  }
  
  Widget _buildBottomNavigationBar(Color primaryColor) {
    return Container(
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