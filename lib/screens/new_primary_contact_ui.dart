import 'package:flutter/material.dart';

class NewPrimaryContactUI extends StatelessWidget {
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
  final int? selectedConnection;
  final int selectedPriority;
  final int? selectedCity;
  final int? selectedConstituency;
  final int? selectedTagCategory;
  final int? selectedTagName;
  
  // Data lists
  final List<Map<String, dynamic>> connections;
  final List<Map<String, dynamic>> constituencies;
  final List<Map<String, dynamic>> availableCities;
  final List<Map<String, dynamic>> tagCategories;
  final List<Map<String, dynamic>> availableTagNames;
  final List<int> priorityLevels;
  final List<Map<String, dynamic>> tags;
  
  // Callbacks
  final Function(int?) onConnectionChanged;
  final Function(int?) onPriorityChanged;
  final Function(int?) onConstituencyChanged;
  final Function(int?) onCityChanged;
  final Function(int?) onTagCategoryChanged;
  final Function(int?) onTagNameChanged;
  final Function() onAddTag;
  final Function(Map<String, dynamic>) onRemoveTag;
  final Function() onSave;

  const NewPrimaryContactUI({
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
    required this.selectedConnection,
    required this.selectedPriority,
    required this.selectedCity,
    required this.selectedConstituency,
    required this.selectedTagCategory,
    required this.selectedTagName,
    required this.connections,
    required this.constituencies,
    required this.availableCities,
    required this.tagCategories,
    required this.availableTagNames,
    required this.priorityLevels,
    required this.tags,
    required this.onConnectionChanged,
    required this.onPriorityChanged,
    required this.onConstituencyChanged,
    required this.onCityChanged,
    required this.onTagCategoryChanged,
    required this.onTagNameChanged,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'New Primary Contact',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isInitialLoading
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
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Error message if any
                          if (errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade700),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      errorMessage!,
                                      style: TextStyle(color: Colors.red.shade900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Personal Details Section
                          buildSectionTitle('Personal Details'),
                          const SizedBox(height: 16),
                          
                          // Name Fields
                          Row(
                            children: [
                              Expanded(
                                child: buildTextField(
                                  controller: firstNameController,
                                  labelText: 'First Name*',
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: buildTextField(
                                  controller: lastNameController,
                                  labelText: 'Last Name',
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
                          buildTextField(
                            controller: emailController,
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              }
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
                                child: buildTextField(
                                  controller: countryCodeController,
                                  labelText: '+91',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if(value.length > 5){
                                      return 'Max 5 chars';
                                    }
                                    return null;
                                  },
                                  maxLength: 5,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: buildTextField(
                                  controller: phoneController,
                                  labelText: 'Phone Number*',
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

                          // Notes Field
                          buildTextField(
                            controller: noteController,
                            labelText: 'Notes',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 32),

                          // Other Details Section
                          buildSectionTitle('Other Details'),
                          const SizedBox(height: 16),

                          // District Dropdown
                          buildDropdownField<int?>(
                            value: selectedConstituency,
                            labelText: 'District',
                            items: constituencies.map((constituency) {
                              return DropdownMenuItem<int?>(
                                value: constituency['id'],
                                child: Text(constituency['name']),
                              );
                            }).toList(),
                            onChanged: onConstituencyChanged,
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a district';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Assembly Constituency
                          buildDropdownField<int?>(
                            value: selectedCity,
                            labelText: 'Assembly Constituency',
                            items: availableCities.map((city) {
                              return DropdownMenuItem<int?>(
                                value: city['id'],
                                child: Text(city['name']),
                              );
                            }).toList(),
                            onChanged: availableCities.isEmpty ? (value) {} : onCityChanged,
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a constituency';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Party Block
                          buildDropdownField<int?>(
                            value: null,
                            labelText: 'Party Block',
                            items: const [],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 16),

                          // Party Constituency
                          buildDropdownField<int?>(
                            value: null,
                            labelText: 'Party Constituency',
                            items: const [],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 16),

                          // Booth
                          buildDropdownField<int?>(
                            value: null,
                            labelText: 'Booth',
                            items: const [],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 16),

                          // Parliamentary Constituency
                          buildDropdownField<int?>(
                            value: null,
                            labelText: 'Parliamentary Constituency',
                            items: const [],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 16),

                          // Local Body
                          buildDropdownField<int?>(
                            value: null,
                            labelText: 'Local Body',
                            items: const [],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 16),

                          // Ward
                          buildDropdownField<int?>(
                            value: null,
                            labelText: 'Ward',
                            items: const [],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 16),

                          // Priority
                          buildDropdownField<int>(
                            value: selectedPriority,
                            labelText: 'Priority 5',
                            items: priorityLevels.map((int priority) {
                              return DropdownMenuItem<int>(
                                value: priority,
                                child: Text(priority.toString()),
                              );
                            }).toList(),
                            onChanged: onPriorityChanged,
                          ),
                          const SizedBox(height: 32),

                          // Residential Details Section
                          buildSectionTitle('Residential Details'),
                          const SizedBox(height: 16),

                          // House Name
                          buildTextField(
                            controller: addressController,
                            labelText: 'House Name',
                          ),
                          const SizedBox(height: 16),

                          // House Number
                          buildTextField(
                            controller: TextEditingController(),
                            labelText: 'House Number',
                          ),
                          const SizedBox(height: 16),

                          // City
                          buildTextField(
                            controller: TextEditingController(),
                            labelText: 'City',
                          ),
                          const SizedBox(height: 16),

                          // Post Office
                          buildTextField(
                            controller: TextEditingController(),
                            labelText: 'Post Office',
                          ),
                          const SizedBox(height: 16),

                          // Pin Code
                          buildTextField(
                            controller: TextEditingController(),
                            labelText: 'Pin Code',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 32),

                          // Tags Section
                          buildSectionTitle('Add Tags'),
                          const SizedBox(height: 16),
                          buildTagsSection(context),
                          const SizedBox(height: 32),

                          // Save Button
                          Container(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : onSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4285F4),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save Contact',
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
                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Saving contact...',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        counterText: '',
      ),
    );
  }

  Widget buildDropdownField<T>({
    required T? value,
    required String labelText,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      items: items,
      onChanged: onChanged,
      dropdownColor: Colors.white,
    );
  }

  Widget buildTagsSection(BuildContext context) {
    return Column(
      children: [
        // Tag Category Dropdown
        buildDropdownField<int?>(
          value: selectedTagCategory,
          labelText: 'Tag Category',
          items: tagCategories.map((category) {
            return DropdownMenuItem<int?>(
              value: category['id'],
              child: Text(category['name']),
            );
          }).toList(),
          onChanged: onTagCategoryChanged,
        ),
        const SizedBox(height: 16),
        
        // Tag Name Dropdown with Add button
        Row(
          children: [
            Expanded(
              child: buildDropdownField<int?>(
                value: selectedTagName,
                labelText: 'Tag Name',
                items: availableTagNames.map((tag) {
                  return DropdownMenuItem<int?>(
                    value: tag['id'],
                    child: Text(tag['name']),
                  );
                }).toList(),
                onChanged: availableTagNames.isEmpty ? (value) {} : onTagNameChanged,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF4285F4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
                onPressed: selectedTagName != null ? onAddTag : null,
              ),
            ),
          ],
        ),
        
        // Display Added Tags
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Chip(
                label: Text(
                  tag['name'],
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                deleteIcon: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.grey,
                ),
                onDeleted: () => onRemoveTag(tag),
                backgroundColor: const Color(0xFFF0F0F0),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}