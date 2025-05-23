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
                                borderRadius: BorderRadius.circular(8),
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
                          
                          // Name Fields
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: firstNameController,
                                  decoration: InputDecoration(
                                    labelText: 'First Name *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(Icons.person),
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
                                    prefixIcon: const Icon(Icons.person_outline),
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
                              prefixIcon: const Icon(Icons.email),
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
                                    labelText: 'Code *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(Icons.flag),
                                  ),
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
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: phoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(Icons.phone),
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
                              prefixIcon: const Icon(Icons.location_on),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),

                          // Constituency Dropdown
                          DropdownButtonFormField<int?>(
                            value: selectedConstituency,
                            decoration: InputDecoration(
                              labelText: 'Constituency *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.location_city),
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
                              labelText: 'City *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.apartment),
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
                              labelText: 'Connection *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.people),
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
                              prefixIcon: const Icon(Icons.priority_high),
                            ),
                            items: priorityLevels.map((int priority) {
                              return DropdownMenuItem<int>(
                                value: priority,
                                child: Row(
                                  children: [
                                    Text(priority.toString()),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.star,
                                      color: priority <= 2 
                                        ? Colors.red 
                                        : priority <= 4 
                                          ? Colors.orange 
                                          : Colors.green,
                                      size: 16,
                                    ),
                                  ],
                                ),
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
                              prefixIcon: const Icon(Icons.note),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          // Tags Section
                          buildTagsSection(context),
                          const SizedBox(height: 24),

                          // Save Button
                          ElevatedButton(
                            onPressed: isLoading ? null : onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: isLoading 
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Saving...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Save Contact',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                          ),
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

  Widget buildTagsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title for the tags section
            Row(
              children: [
                Icon(Icons.label, color: primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Add Tags',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tag Category Dropdown
            DropdownButtonFormField<int?>(
              value: selectedTagCategory,
              decoration: InputDecoration(
                labelText: 'Tag Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.category),
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
            
            // Tag Name Dropdown with Add button
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
                      prefixIcon: const Icon(Icons.local_offer),
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
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: selectedTagName != null ? onAddTag : null,
                    tooltip: 'Add Tag',
                  ),
                ),
              ],
            ),
            
            // Display Added Tags
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.label_outline, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Selected Tags:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor.withOpacity(0.1), primaryColor.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: Chip(
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tag['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            tag['tag_category'],
                            style: TextStyle(
                              fontSize: 11,
                              color: primaryColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      deleteIcon: Icon(
                        Icons.close,
                        size: 18,
                        color: primaryColor,
                      ),
                      onDeleted: () => onRemoveTag(tag),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}