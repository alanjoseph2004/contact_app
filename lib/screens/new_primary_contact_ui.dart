import 'package:flutter/material.dart';
import '../widgets/add_tags_widget.dart';
import '../widgets/personal_details_widget.dart';
import '../widgets/save_button_widget.dart'; // Import the new SaveButtonWidget
import '../utils/form_utils.dart';

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
                          // Error message using FormUtils
                          FormUtils.buildErrorMessage(errorMessage),
                          
                          // Personal Details Section - Now using PersonalDetailsWidget
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

                          // District Dropdown
                          FormUtils.buildDropdownField<int?>(
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
                          FormUtils.buildDropdownField<int?>(
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
                          FormUtils.buildDropdownField<int?>(
                            value: null,
                            labelText: 'Party Block',
                            items: const [],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 16),

                          // Party Constituency
                          FormUtils.buildDropdownField<int?>(
                            value: null,
                            labelText: 'Party Constituency',
                            items: const [],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 16),

                          // Booth
                          FormUtils.buildDropdownField<int?>(
                            value: null,
                            labelText: 'Booth',
                            items: const [],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 16),

                          // Parliamentary Constituency
                          FormUtils.buildDropdownField<int?>(
                            value: null,
                            labelText: 'Parliamentary Constituency',
                            items: const [],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 16),

                          // Local Body
                          FormUtils.buildDropdownField<int?>(
                            value: null,
                            labelText: 'Local Body',
                            items: const [],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 16),

                          // Ward
                          FormUtils.buildDropdownField<int?>(
                            value: null,
                            labelText: 'Ward',
                            items: const [],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 16),

                          // Priority
                          FormUtils.buildDropdownField<int>(
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
                          FormUtils.buildSectionTitle('Residential Details'),
                          const SizedBox(height: 16),

                          // House Name
                          FormUtils.buildTextField(
                            controller: addressController,
                            labelText: 'House Name',
                          ),
                          const SizedBox(height: 16),

                          // House Number
                          FormUtils.buildTextField(
                            controller: TextEditingController(),
                            labelText: 'House Number',
                          ),
                          const SizedBox(height: 16),

                          // City
                          FormUtils.buildTextField(
                            controller: TextEditingController(),
                            labelText: 'City',
                          ),
                          const SizedBox(height: 16),

                          // Post Office
                          FormUtils.buildTextField(
                            controller: TextEditingController(),
                            labelText: 'Post Office',
                          ),
                          const SizedBox(height: 16),

                          // Pin Code
                          FormUtils.buildTextField(
                            controller: TextEditingController(),
                            labelText: 'Pin Code',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 32),

                          // Tags Section
                          AddTagsWidget(
                            selectedTagCategory: selectedTagCategory,
                            selectedTagName: selectedTagName,
                            tagCategories: tagCategories,
                            availableTagNames: availableTagNames,
                            tags: tags,
                            onTagCategoryChanged: onTagCategoryChanged,
                            onTagNameChanged: onTagNameChanged,
                            onAddTag: onAddTag,
                            onRemoveTag: onRemoveTag,
                            sectionTitle: 'Add Tags',
                            showSectionTitle: true,
                          ),
                          const SizedBox(height: 32),

                          // Save Button - Now using SaveButtonWidget
                          SaveButtonWidget(
                            isLoading: isLoading,
                            onPressed: onSave,
                            buttonText: 'Save Contact',
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                // Loading overlay using FormUtils
                FormUtils.buildLoadingOverlay(
                  message: 'Saving contact...',
                  isVisible: isLoading,
                ),
              ],
            ),
    );
  }
}