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

                          // Connection Dropdown
                          DropdownButtonFormField<int?>(
                            value: selectedConnection,
                            decoration: InputDecoration(
                              labelText: 'Connection',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: connections.map((connection) {
                              return DropdownMenuItem<int?>(
                                value: connection['id'],
                                child: Text(connection['name']),
                              );
                            }).toList(),
                            onChanged: onConnectionChanged,
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
                            value: selectedPriority,
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: priorityLevels.map((int priority) {
                              return DropdownMenuItem<int>(
                                value: priority,
                                child: Text(priority.toString()),
                              );
                            }).toList(),
                            onChanged: onPriorityChanged,
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
                          const SizedBox(height: 16),

                          // Tags Section
                          buildTagsSection(context),
                          const SizedBox(height: 16),

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

  Widget buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title for the tags section
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Add Tags',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Tag Category Dropdown
        DropdownButtonFormField<int?>(
          value: selectedTagCategory,
          decoration: InputDecoration(
            labelText: 'Tag Category',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: tagCategories.map((category) {
            return DropdownMenuItem<int?>(
              value: category['id'],
              child: Text(category['name']),
            );
          }).toList(),
          onChanged: onTagCategoryChanged,
        ),
        const SizedBox(height: 12),
        
        // Tag Name Dropdown (only enabled if a category is selected)
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int?>(
                value: selectedTagName,
                decoration: InputDecoration(
                  labelText: 'Tag Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: availableTagNames.map((tag) {
                  return DropdownMenuItem<int?>(
                    value: tag['id'],
                    child: Text(tag['name']),
                  );
                }).toList(),
                onChanged: availableTagNames.isEmpty ? null : onTagNameChanged,
                hint: selectedTagCategory == null 
                  ? const Text('Select category first') 
                  : const Text('Select tag'),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add, color: primaryColor),
              onPressed: selectedTagName != null ? onAddTag : null,
              tooltip: 'Add Tag',
            ),
          ],
        ),
        
        // Display Added Tags
        if (tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Tags:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) {
                    return Chip(
                      label: Text('${tag['name']} (${tag['tag_category']})'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => onRemoveTag(tag),
                      backgroundColor: Colors.blue.shade50,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}