import 'package:flutter/material.dart';

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
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _constituencyController = TextEditingController();

  // Dropdown values
  String? _selectedConnection;
  int _selectedPriority = 5;
  
  // Connections list
  final List<String> _connections = [
    'Friend',
    'Family', 
    'Political Relation',
    'Celebrity',
    'Other'
  ];

  List<int> _priorityLevels = List.generate(10, (index) => index + 1);

  // Tags
  List<Map<String, String>> _tags = [];
  final TextEditingController _tagNameController = TextEditingController();
  final TextEditingController _tagCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial selected connection to null or first item
    _selectedConnection = _connections.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'New Primary Contact',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name Fields
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter first name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    // Allow null or empty email
                    if (value == null || value.isEmpty) {
                      return null;
                    }
                    // If email is provided, validate its format
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
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
                      child: TextFormField(
                        controller: _countryCodeController,
                        decoration: InputDecoration(
                          labelText: 'Code',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Code';
                          }
                          if(value.length > 5){
                            return 'Country code must be 5 characters or less';
                          }
                          return null;
                        },
                        maxLength: 5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          if(value.length > 11){
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

                // Address and City Fields
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter city';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _constituencyController,
                        decoration: InputDecoration(
                          labelText: 'Constituency',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter constituency';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Connection Dropdown
                DropdownButtonFormField<String?>(
                  value: _selectedConnection,
                  decoration: InputDecoration(
                    labelText: 'Connection',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _connections.map((String connection) {
                    return DropdownMenuItem<String?>(
                      value: connection,
                      child: Text(connection),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedConnection = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a connection';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Priority Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _priorityLevels.map((int priority) {
                    return DropdownMenuItem<int>(
                      value: priority,
                      child: Text(priority.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedPriority = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Notes Field
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Tags Section
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tagNameController,
                        decoration: InputDecoration(
                          labelText: 'Tag Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _tagCategoryController,
                        decoration: InputDecoration(
                          labelText: 'Tag Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: primaryColor),
                      onPressed: () {
                        if (_tagNameController.text.isNotEmpty && 
                            _tagCategoryController.text.isNotEmpty) {
                          setState(() {
                            _tags.add({
                              'name': _tagNameController.text,
                              'tag_category': _tagCategoryController.text
                            });
                            _tagNameController.clear();
                            _tagCategoryController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                
                // Display Added Tags
                if (_tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text('${tag['name']} (${tag['tag_category']})'),
                        onDeleted: () {
                          setState(() {
                            _tags.remove(tag);
                          });
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),

                // Save Button
                ElevatedButton(
                  onPressed: _saveContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Contact',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      // Prepare the contact data
      final contactData = {
        'contact': {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'email': _emailController.text,
          'country_code': _countryCodeController.text,
          'phone': _phoneController.text,
          'note': _noteController.text,
          'address': _addressController.text,
          'is_primary_contact': true,
          'city': {
            'name': _cityController.text,
            'constituency': {
              'name': _constituencyController.text
            }
          }
        },
        'priority': _selectedPriority,
        'connection': _selectedConnection,
        'tags': _tags.map((tag) => {
          'name': tag['name'],
          'tag_category': {
            'name': tag['tag_category']
          }
        }).toList()
      };

      // TODO: Implement actual save logic (e.g., API call)
      print(contactData);

      // Show success dialog or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact saved successfully!'),
          backgroundColor: primaryColor,
        ),
      );
    }
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
    _cityController.dispose();
    _constituencyController.dispose();
    _tagNameController.dispose();
    _tagCategoryController.dispose();
    super.dispose();
  }
}