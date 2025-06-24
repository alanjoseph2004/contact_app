import 'package:flutter/material.dart';
import '../widgets/add_tags_widget.dart';
import '../widgets/personal_details_widget.dart';
import '../widgets/save_button_widget.dart';
import '../utils/form_utils.dart';

class NewPrimaryContactUI extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Color primaryColor;
  final bool isInitialLoading;
  final bool isLoading;
  final bool isLoadingAssemblyConstituencies;
  final String? errorMessage;
  
  // Controllers
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController countryCodeController;
  final TextEditingController phoneController;
  final TextEditingController noteController;
  final TextEditingController houseNameController;
  final TextEditingController houseNumberController;
  final TextEditingController cityController;
  final TextEditingController postOfficeController;
  final TextEditingController pinCodeController;
  
  // Selected values
  final int? selectedConnection;
  final int selectedPriority;
  final int? selectedDistrict;
  final int? selectedAssemblyConstituency;
  final int? selectedParliamentaryConstituency;
  final int? selectedTagCategory;
  final int? selectedTagName;
  
  // Data lists
  final List<Map<String, dynamic>> connections;
  final List<Map<String, dynamic>> districts;
  final List<Map<String, dynamic>> assemblyConstituencies;
  final List<Map<String, dynamic>> parliamentaryConstituencies;
  final List<Map<String, dynamic>> tagCategories;
  final List<Map<String, dynamic>> availableTagNames;
  final List<int> priorityLevels;
  final List<Map<String, dynamic>> tags;
  
  // Callbacks
  final Function(int?) onConnectionChanged;
  final Function(int?) onPriorityChanged;
  final Function(int?) onDistrictChanged;
  final Function(int?) onAssemblyConstituencyChanged;
  final Function(int?) onParliamentaryConstituencyChanged;
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
    required this.isLoadingAssemblyConstituencies,
    required this.errorMessage,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.countryCodeController,
    required this.phoneController,
    required this.noteController,
    required this.houseNameController,
    required this.houseNumberController,
    required this.cityController,
    required this.postOfficeController,
    required this.pinCodeController,
    required this.selectedConnection,
    required this.selectedPriority,
    required this.selectedDistrict,
    required this.selectedAssemblyConstituency,
    required this.selectedParliamentaryConstituency,
    required this.selectedTagCategory,
    required this.selectedTagName,
    required this.connections,
    required this.districts,
    required this.assemblyConstituencies,
    required this.parliamentaryConstituencies,
    required this.tagCategories,
    required this.availableTagNames,
    required this.priorityLevels,
    required this.tags,
    required this.onConnectionChanged,
    required this.onPriorityChanged,
    required this.onDistrictChanged,
    required this.onAssemblyConstituencyChanged,
    required this.onParliamentaryConstituencyChanged,
    required this.onTagCategoryChanged,
    required this.onTagNameChanged,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize country code with +91 if empty
    if (countryCodeController.text.isEmpty) {
      countryCodeController.text = '+91';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
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
            fontFamily: 'Inter',
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
                  Text(
                    'Loading data...',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
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
                          // Error message using FormUtils
                          FormUtils.buildErrorMessage(errorMessage),
                          
                          // Personal Details Section - Using PersonalDetailsWidget
                          PersonalDetailsWidget(
                            firstNameController: firstNameController,
                            lastNameController: lastNameController,
                            emailController: emailController,
                            countryCodeController: countryCodeController,
                            phoneController: phoneController,
                            noteController: noteController,
                            showNotes: true,
                            showSectionTitle: true,
                            sectionTitle: 'Personal Details',
                          ),
                          const SizedBox(height: 32),

                          // Other Details Section
                          FormUtils.buildSectionTitle('Other Details'),
                          const SizedBox(height: 16),

                          // Connection Dropdown
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildDropdownField<int?>(
                              value: selectedConnection,
                              labelText: 'Connection *',
                              items: connections.map((connection) {
                                return DropdownMenuItem<int?>(
                                  value: connection['id'],
                                  child: Text(
                                    connection['name'],
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
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
                          ),
                          const SizedBox(height: 16),

                          // Priority Dropdown
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildDropdownField<int?>(
                              value: selectedPriority,
                              labelText: 'Priority *',
                              items: priorityLevels.map((priority) {
                                return DropdownMenuItem<int?>(
                                  value: priority,
                                  child: Text(
                                    'Priority $priority',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: onPriorityChanged,
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a priority';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // District Dropdown
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildDropdownField<int?>(
                              value: selectedDistrict,
                              labelText: 'District *',
                              items: districts.map((district) {
                                return DropdownMenuItem<int?>(
                                  value: district['id'],
                                  child: Text(
                                    district['name'],
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: onDistrictChanged,
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a district';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Assembly Constituency Dropdown
                          Stack(
                            children: [
                              SizedBox(
                                height: 49,
                                child: FormUtils.buildDropdownField<int?>(
                                  value: selectedAssemblyConstituency,
                                  labelText: 'Assembly Constituency *',
                                  items: assemblyConstituencies.map((constituency) {
                                    return DropdownMenuItem<int?>(
                                      value: constituency['id'],
                                      child: Text(
                                        constituency['name'],
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: assemblyConstituencies.isEmpty || isLoadingAssemblyConstituencies
                                      ? (value) {}
                                      : onAssemblyConstituencyChanged,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select an assembly constituency';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              if (isLoadingAssemblyConstituencies)
                                const Positioned(
                                  right: 12,
                                  top: 12,
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Parliamentary Constituency Dropdown (Optional)
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildDropdownField<int?>(
                              value: selectedParliamentaryConstituency,
                              labelText: 'Parliamentary Constituency',
                              items: parliamentaryConstituencies.map((constituency) {
                                return DropdownMenuItem<int?>(
                                  value: constituency['id'],
                                  child: Text(
                                    constituency['name'],
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: onParliamentaryConstituencyChanged,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Address Details Section
                          FormUtils.buildSectionTitle('Address Details'),
                          const SizedBox(height: 16),

                          // House Name
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildTextField(
                              controller: houseNameController,
                              labelText: 'House Name',
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // House Number
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildTextField(
                              controller: houseNumberController,
                              labelText: 'House Number',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // City
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildTextField(
                              controller: cityController,
                              labelText: 'City',
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Post Office
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildTextField(
                              controller: postOfficeController,
                              labelText: 'Post Office',
                              keyboardType: TextInputType.text,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Pin Code
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildTextField(
                              controller: pinCodeController,
                              labelText: 'Pin Code',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
                                    return 'Pin code must be 6 digits';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Tags Section - Using AddTagsWidget
                          AddTagsWidget(
                            tagCategories: tagCategories,
                            availableTagNames: availableTagNames,
                            selectedTagCategory: selectedTagCategory,
                            selectedTagName: selectedTagName,
                            tags: tags,
                            onTagCategoryChanged: onTagCategoryChanged,
                            onTagNameChanged: onTagNameChanged,
                            onAddTag: onAddTag,
                            onRemoveTag: onRemoveTag,
                          ),
                          const SizedBox(height: 32),

                          // Save Button - Using SaveButtonWidget
                          SaveButtonWidget(
                            onPressed: onSave,
                            isLoading: isLoading,
                            buttonText: 'Save Contact',
                          ),
                          const SizedBox(height: 20),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Saving contact...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}