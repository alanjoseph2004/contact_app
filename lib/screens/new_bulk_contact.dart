import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BulkContactsUploadPage extends StatefulWidget {
  const BulkContactsUploadPage({super.key});

  @override
  State<BulkContactsUploadPage> createState() => _BulkContactsUploadPageState();
}

class _BulkContactsUploadPageState extends State<BulkContactsUploadPage> {
  final Color primaryColor = const Color(0xFF283593);
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // API data lists
  List<Map<String, dynamic>> _primaryContacts = [];
  List<Map<String, dynamic>> _constituencies = [];
  
  // Selected values
  int? _selectedReferredBy;
  
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _errorMessage;

  // List of contact forms
  final List<ContactFormData> _contactForms = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    // Add first empty contact form
    _addNewContactForm();
  }
  
  // Add a new contact form
  void _addNewContactForm() {
    setState(() {
      _contactForms.add(ContactFormData());
    });
  }

  // Remove a contact form at specific index
  void _removeContactForm(int index) {
    if (_contactForms.length > 1) {
      setState(() {
        _contactForms.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least one contact'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  // API Call to fetch primary contacts
  Future<void> _fetchPrimaryContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception("JWT token is missing");
    }

    try {
      final response = await http.get(
        Uri.parse('http://51.21.152.136:8000/contact/all-primary-contacts/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['results'];
        setState(() {
          _primaryContacts = data.map((item) => {
            'id': item['id'],
            'name': '${item['contact']['first_name']} ${item['contact']['last_name'] ?? ''}',
            'phone': item['contact']['phone'],
          }).toList();
        });
      } else {
        throw Exception('Failed to load primary contacts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in _fetchPrimaryContacts: $e');
      rethrow;
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
  List<Map<String, dynamic>> _getAvailableCities(int? constituencyId) {
    if (constituencyId != null) {
      final constituency = _constituencies.firstWhere(
        (c) => c['id'] == constituencyId,
        orElse: () => {'cities': []},
      );
      
      return List<Map<String, dynamic>>.from(constituency['cities'] ?? []);
    }
    return [];
  }

  Future<void> _saveBulkContacts() async {
    if (_formKey.currentState!.validate()) {
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
        
        // Prepare the contacts data
        List<Map<String, dynamic>> contactsData = _contactForms.map((form) {
          return {
            'first_name': form.firstNameController.text,
            'last_name': form.lastNameController.text.isEmpty ? null : form.lastNameController.text,
            'email': form.emailController.text.isEmpty ? null : form.emailController.text,
            'country_code': form.countryCodeController.text,
            'phone': form.phoneController.text,
            'note': form.noteController.text.isEmpty ? null : form.noteController.text,
            'address': form.addressController.text.isEmpty ? null : form.addressController.text,
            'city': form.selectedCity,
          };
        }).toList();

        // Format the data according to the API schema
        final Map<String, dynamic> requestBody = {
          'referred_by': _selectedReferredBy,
          'contacts': contactsData,
        };

        // Make the API call
        final response = await http.post(
          Uri.parse('http://51.21.152.136:8000/contact/contacts/bulk-create/'),
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
              content: Text('Contacts saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back or to a success page
          Navigator.of(context).pop();
        } else {
          // Error
          final responseData = jsonDecode(response.body);
          setState(() {
            _errorMessage = responseData['message'] ?? 'Failed to save contacts. Please try again.';
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
          'Bulk Contacts Upload',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Error message if any
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                      
                      // Referred By Dropdown
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DropdownButtonFormField<int?>(
                          value: _selectedReferredBy,
                          decoration: InputDecoration(
                            labelText: 'Referred By',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: _primaryContacts.map((contact) {
                            return DropdownMenuItem<int?>(
                              value: contact['id'],
                              child: Text("${contact['name']} (${contact['phone']})"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedReferredBy = value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a referring primary contact';
                            }
                            return null;
                          },
                        ),
                      ),

                      // Contact Forms in Expanded to allow scrolling
                      Expanded(
                        child: ListView.builder(
                          itemCount: _contactForms.length,
                          itemBuilder: (context, index) {
                            return ContactFormWidget(
                              contactForm: _contactForms[index],
                              constituencies: _constituencies,
                              getAvailableCities: _getAvailableCities,
                              onRemove: () => _removeContactForm(index),
                              showRemoveButton: _contactForms.length > 1,
                              index: index,
                            );
                          },
                        ),
                      ),

                      // Add Contact Button and Save Button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _addNewContactForm,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Contact'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveBulkContacts,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isLoading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Save All Contacts',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers for all contact forms
    for (var form in _contactForms) {
      form.dispose();
    }
    super.dispose();
  }
}

// Class to hold form data for each contact
class ContactFormData {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  
  int? selectedConstituency;
  int? selectedCity;

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    countryCodeController.dispose();
    phoneController.dispose();
    noteController.dispose();
    addressController.dispose();
  }
}

// Widget to display a single contact form
class ContactFormWidget extends StatefulWidget {
  final ContactFormData contactForm;
  final List<Map<String, dynamic>> constituencies;
  final Function(int?) getAvailableCities;
  final VoidCallback onRemove;
  final bool showRemoveButton;
  final int index;

  const ContactFormWidget({
    super.key,
    required this.contactForm,
    required this.constituencies,
    required this.getAvailableCities,
    required this.onRemove,
    required this.showRemoveButton,
    required this.index,
  });

  @override
  State<ContactFormWidget> createState() => _ContactFormWidgetState();
}

// Fix the error in the ContactFormWidget class
class _ContactFormWidgetState extends State<ContactFormWidget> {
  @override
  Widget build(BuildContext context) {
    // Get cities based on selected constituency
    final availableCities = widget.getAvailableCities(widget.contactForm.selectedConstituency);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contact #${widget.index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.showRemoveButton)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            
            // Name Fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.contactForm.firstNameController,
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
                      if (value.length > 63) {
                        return 'First name must be 63 characters or less';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: widget.contactForm.lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.length > 63) {
                        return 'Last name must be 63 characters or less';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: widget.contactForm.emailController,
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
                if (value.length > 255) {
                  return 'Email must be 255 characters or less';
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
                    controller: widget.contactForm.countryCodeController,
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
                    controller: widget.contactForm.phoneController,
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

            // Address Field
            TextFormField(
              controller: widget.contactForm.addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Constituency Dropdown - THIS IS THE FIXED PART
            DropdownButtonFormField<int?>(
              value: widget.contactForm.selectedConstituency,
              decoration: InputDecoration(
                labelText: 'Constituency',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                for (var constituency in widget.constituencies)
                  DropdownMenuItem<int?>(
                    value: constituency['id'],
                    child: Text(constituency['name'].toString()),
                  )
              ],
              onChanged: (value) {
                setState(() {
                  widget.contactForm.selectedConstituency = value;
                  widget.contactForm.selectedCity = null; // Reset city when constituency changes
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
            
            // City Dropdown - THIS IS THE FIXED PART
            DropdownButtonFormField<int?>(
              value: widget.contactForm.selectedCity,
              decoration: InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                for (var city in availableCities)
                  DropdownMenuItem<int?>(
                    value: city['id'],
                    child: Text(city['name'].toString()),
                  )
              ],
              onChanged: availableCities.isEmpty 
                ? null 
                : (value) {
                    setState(() {
                      widget.contactForm.selectedCity = value;
                    });
                  },
              validator: (value) {
                if (value == null) {
                  return 'Please select a city';
                }
                return null;
              },
              hint: availableCities.isEmpty
                ? const Text('Select constituency first')
                : const Text('Select city'),
            ),
            const SizedBox(height: 16),

            // Notes Field
            TextFormField(
              controller: widget.contactForm.noteController,
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}