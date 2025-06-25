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
  final bool isLoadingPartyBlocks;
  final bool isLoadingPartyConstituencies;
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
  final int? selectedPartyBlock;
  final int? selectedPartyConstituency;
  final int? selectedParliamentaryConstituency;
  final int? selectedTagCategory;
  final int? selectedTagName;
  
  // Data lists
  final List<Map<String, dynamic>> connections;
  final List<Map<String, dynamic>> districts;
  final List<Map<String, dynamic>> assemblyConstituencies;
  final List<Map<String, dynamic>> partyBlocks;
  final List<Map<String, dynamic>> partyConstituencies;
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
  final Function(int?) onPartyBlockChanged;
  final Function(int?) onPartyConstituencyChanged;
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
    required this.isLoadingPartyBlocks,
    required this.isLoadingPartyConstituencies,
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
    required this.selectedPartyBlock,
    required this.selectedPartyConstituency,
    required this.selectedParliamentaryConstituency,
    required this.selectedTagCategory,
    required this.selectedTagName,
    required this.connections,
    required this.districts,
    required this.assemblyConstituencies,
    required this.partyBlocks,
    required this.partyConstituencies,
    required this.parliamentaryConstituencies,
    required this.tagCategories,
    required this.availableTagNames,
    required this.priorityLevels,
    required this.tags,
    required this.onConnectionChanged,
    required this.onPriorityChanged,
    required this.onDistrictChanged,
    required this.onAssemblyConstituencyChanged,
    required this.onPartyBlockChanged,
    required this.onPartyConstituencyChanged,
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
                          const SizedBox(height: 32),

                          // Location Details Section
                          FormUtils.buildSectionTitle('Location Details'),
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

                          // Party Block Dropdown (Optional)
                          Stack(
                            children: [
                              SizedBox(
                                height: 49,
                                child: FormUtils.buildDropdownField<int?>(
                                  value: selectedPartyBlock,
                                  labelText: 'Party Block',
                                  items: partyBlocks.map((partyBlock) {
                                    return DropdownMenuItem<int?>(
                                      value: partyBlock['id'],
                                      child: Text(
                                        partyBlock['name'],
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: partyBlocks.isEmpty || isLoadingPartyBlocks
                                      ? (value) {}
                                      : onPartyBlockChanged,
                                ),
                              ),
                              if (isLoadingPartyBlocks)
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

                          // // Party Constituency Dropdown (Optional)
                          // Stack(
                          //   children: [
                          //     SizedBox(
                          //       height: 49,
                          //       child: FormUtils.buildDropdownField<int?>(
                          //         value: selectedPartyConstituency,
                          //         labelText: 'Party Constituency',
                          //         items: partyConstituencies.map((partyConstituency) {
                          //           return DropdownMenuItem<int?>(
                          //             value: partyConstituency['id'],
                          //             child: Text(
                          //               partyConstituency['name'],
                          //               style: const TextStyle(
                          //                 fontFamily: 'Inter',
                          //                 fontWeight: FontWeight.w400,
                          //               ),
                          //             ),
                          //           );
                          //         }).toList(),
                          //         onChanged: partyConstituencies.isEmpty || isLoadingPartyConstituencies
                          //             ? (value) {}
                          //             : onPartyConstituencyChanged,
                          //       ),
                          //     ),
                          //     if (isLoadingPartyConstituencies)
                          //       const Positioned(
                          //         right: 12,
                          //         top: 12,
                          //         child: SizedBox(
                          //           width: 20,
                          //           height: 20,
                          //           child: CircularProgressIndicator(
                          //             strokeWidth: 2,
                          //           ),
                          //         ),
                          //       ),
                          //   ],
                          // ),
                          // const SizedBox(height: 16),

                          // Parliamentary Constituency Dropdown (Optional)
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildDropdownField<int?>(
                              value: selectedParliamentaryConstituency,
                              labelText: 'Parliamentary Constituency',
                              items: parliamentaryConstituencies.map((parConstituency) {
                                return DropdownMenuItem<int?>(
                                  value: parConstituency['id'],
                                  child: Text(
                                    parConstituency['name'],
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

                          // House Name Field
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildTextField(
                              controller: houseNameController,
                              labelText: 'House Name',

                            ),
                          ),
                          const SizedBox(height: 16),

                          // House Number Field
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildTextField(
                              controller: houseNumberController,
                              labelText: 'House Number',
                              keyboardType: TextInputType.number,

                            ),
                          ),
                          const SizedBox(height: 16),

                          // City Field
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildTextField(
                              controller: cityController,
                              labelText: 'City',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Post Office Field
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildTextField(
                              controller: postOfficeController,
                              labelText: 'Post Office',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Pin Code Field
                          SizedBox(
                            height: 49,
                            child: FormUtils.buildTextField(
                              controller: pinCodeController,
                              labelText: 'Pin Code',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty && value.length != 6) {
                                  return 'Pin code must be 6 digits';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Tags Section
                          // Tags Section
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
                            // Removed primaryColor - not a parameter of AddTagsWidget
                            sectionTitle: 'Add Tags', // Optional: customize section title
                            showSectionTitle: true, // Optional: show/hide section title
                          ),
                          const SizedBox(height: 32),

                          // Save Button
                          SaveButtonWidget(
                            onPressed: onSave, // Changed from onSave to onPressed
                            isLoading: isLoading,
                            buttonText: 'Save Contact', // Optional: customize button text
                            loadingText: 'Saving...', // Optional: customize loading text
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
                    color: Colors.black26,
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
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
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