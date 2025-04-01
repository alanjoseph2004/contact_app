import 'package:flutter/material.dart';

class NewAllContactUI extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Color primaryColor;
  final bool isInitialLoading;
  final bool isLoading;
  final String? errorMessage;
  
  // Controllers
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController countryCodeController;
  final TextEditingController phoneController;
  final TextEditingController noteController;
  final TextEditingController addressController;
  
  // Selected values
  final int? selectedReferredBy;
  final int? selectedCity;
  final int? selectedConstituency;
  
  // Data lists
  final List<Map<String, dynamic>> primaryContacts;
  final List<Map<String, dynamic>> constituencies;
  final List<Map<String, dynamic>> availableCities;
  
  // Callbacks
  final Function(int?) onReferredByChanged;
  final Function(int?) onConstituencyChanged;
  final Function(int?) onCityChanged;
  final Function() onSave;

  const NewAllContactUI({
    super.key,
    required this.formKey,
    required this.primaryColor,
    required this.isInitialLoading,
    required this.isLoading,
    required this.errorMessage,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.countryCodeController,
    required this.phoneController,
    required this.noteController,
    required this.addressController,
    required this.selectedReferredBy,
    required this.selectedCity,
    required this.selectedConstituency,
    required this.primaryContacts,
    required this.constituencies,
    required this.availableCities,
    required this.onReferredByChanged,
    required this.onConstituencyChanged,
    required this.onCityChanged,
    required this.onSave,
  });

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
          'New Contact',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Error message if any
                          if (errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Text(
                                errorMessage!,
                                style: TextStyle(color: Colors.red.shade900),
                              ),
                            ),
                          
                          // Referred By Dropdown
                          DropdownButtonFormField<int?>(
                            value: selectedReferredBy,
                            decoration: InputDecoration(
                              labelText: 'Referred By',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: primaryContacts.map((contact) {
                              return DropdownMenuItem<int?>(
                                value: contact['id'],
                                child: Text("${contact['name']} (${contact['phone']})"),
                              );
                            }).toList(),
                            onChanged: onReferredByChanged,
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a referring primary contact';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Name Fields
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: firstNameController,
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
                                  controller: lastNameController,
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
                            controller: emailController,
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
                                  controller: countryCodeController,
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
                                  controller: phoneController,
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
                            controller: addressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Constituency Dropdown
                          DropdownButtonFormField<int?>(
                            value: selectedConstituency,
                            decoration: InputDecoration(
                              labelText: 'Constituency',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: constituencies.map((constituency) {
                              return DropdownMenuItem<int?>(
                                value: constituency['id'],
                                child: Text(constituency['name']),
                              );
                            }).toList(),
                            onChanged: onConstituencyChanged,
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a constituency';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // City Dropdown (filtered by constituency)
                          DropdownButtonFormField<int?>(
                            value: selectedCity,
                            decoration: InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: availableCities.map((city) {
                              return DropdownMenuItem<int?>(
                                value: city['id'],
                                child: Text(city['name']),
                              );
                            }).toList(),
                            onChanged: availableCities.isEmpty 
                              ? null 
                              : onCityChanged,
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
                            controller: noteController,
                            decoration: InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),

                          // Save Button
                          ElevatedButton(
                            onPressed: isLoading ? null : onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
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
                if (isLoading)
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
}