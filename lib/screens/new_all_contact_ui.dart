import 'package:flutter/material.dart';
import '../widgets/add_tags_widget.dart';
import '../widgets/personal_details_widget.dart';
import '../widgets/save_button_widget.dart';
import '../utils/form_utils.dart';

class NewAllContactUI extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Color primaryColor;
  final bool isInitialLoading;
  final bool isLoading;
  final String? errorMessage;

  // Text Controllers
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

  // Selected Values
  final int? selectedReferredBy;
  final int? selectedDistrict;
  final int? selectedAssemblyConstituency;
  final int? selectedPartyBlock;
  final int? selectedPartyConstituency;
  final int? selectedParliamentaryConstituency;
  // final int? selectedBooth;
  // final int? selectedLocalBody;
  // final int? selectedWard;
  final int? selectedTagCategory;
  final int? selectedTagName;
  final List<int> selectedTagIds;

  // Data Lists
  final List<Map<String, dynamic>> primaryContacts;
  final List<Map<String, dynamic>> districts;
  final List<Map<String, dynamic>> assemblyConstituencies;
  final List<Map<String, dynamic>> partyBlocks;
  final List<Map<String, dynamic>> partyConstituencies;
  final List<Map<String, dynamic>> parliamentaryConstituencies;
  final List<Map<String, dynamic>> tagCategories;
  final List<Map<String, dynamic>> tags;

  // Callbacks
  final Function(int?) onReferredByChanged;
  final Function(int?) onDistrictChanged;
  final Function(int?) onAssemblyConstituencyChanged;
  final Function(int?) onPartyBlockChanged;
  final Function(int?) onPartyConstituencyChanged;
  final Function(int?) onParliamentaryConstituencyChanged;
  // final Function(int?) onBoothChanged;
  // final Function(int?) onLocalBodyChanged;
  // final Function(int?) onWardChanged;
  final Function(int?) onTagCategoryChanged;
  final Function(int?) onTagNameChanged;
  final VoidCallback onAddTag;
  final Function(int) onRemoveTag;
  final String Function(int) getTagName;
  final VoidCallback onSave;

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
    required this.houseNameController,
    required this.houseNumberController,
    required this.cityController,
    required this.postOfficeController,
    required this.pinCodeController,
    required this.selectedReferredBy,
    required this.selectedDistrict,
    required this.selectedAssemblyConstituency,
    required this.selectedPartyBlock,
    required this.selectedPartyConstituency,
    required this.selectedParliamentaryConstituency,
    // required this.selectedBooth,
    // required this.selectedLocalBody,
    // required this.selectedWard,
    required this.selectedTagCategory,
    required this.selectedTagName,
    required this.selectedTagIds,
    required this.primaryContacts,
    required this.districts,
    required this.assemblyConstituencies,
    required this.partyBlocks,
    required this.partyConstituencies,
    required this.parliamentaryConstituencies,
    required this.tagCategories,
    required this.tags,
    required this.onReferredByChanged,
    required this.onDistrictChanged,
    required this.onAssemblyConstituencyChanged,
    required this.onPartyBlockChanged,
    required this.onPartyConstituencyChanged,
    required this.onParliamentaryConstituencyChanged,
    // required this.onBoothChanged,
    // required this.onLocalBodyChanged,
    // required this.onWardChanged,
    required this.onTagCategoryChanged,
    required this.onTagNameChanged,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.getTagName,
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
          'Add New Contact',
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
                      fontSize: 16,
                      color: Colors.black87,
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
                          
                          // Basic Information Section
                          FormUtils.buildSectionTitle('Basic Information'),
                          const SizedBox(height: 16),
                          
                          // Referred By Dropdown
                          FormUtils.buildDropdownField<int?>(
                            value: selectedReferredBy,
                            labelText: 'Referred By *',
                            items: primaryContacts.map((contact) {
                              return DropdownMenuItem<int?>(
                                value: contact['id'],
                                child: Text(
                                  contact['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: onReferredByChanged,
                            validator: (value) {
                              if (value == null) {
                                return 'Please select who referred this contact';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Personal Details Section - Using PersonalDetailsWidget
                          PersonalDetailsWidget(
                            firstNameController: firstNameController,
                            lastNameController: lastNameController,
                            emailController: emailController,
                            countryCodeController: countryCodeController,
                            phoneController: phoneController,
                            noteController: noteController,
                            showNotes: false, // We'll show notes separately
                            showSectionTitle: true,
                            sectionTitle: 'Personal Details',
                          ),
                          const SizedBox(height: 32),

                          // Location Information Section
                          FormUtils.buildSectionTitle('Location Information'),
                          const SizedBox(height: 16),
                          
                          // District Dropdown
                          FormUtils.buildDropdownField<int?>(
                            value: selectedDistrict,
                            labelText: 'District *',
                            items: districts.map((district) {
                              return DropdownMenuItem<int?>(
                                value: district['id'],
                                child: Text(
                                  district['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.black87,
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
                          const SizedBox(height: 16),
                          
                          // Assembly Constituency Dropdown
                          FormUtils.buildDropdownField<int?>(
                            value: selectedAssemblyConstituency,
                            labelText: 'Assembly Constituency *',
                            items: assemblyConstituencies.map((constituency) {
                              return DropdownMenuItem<int?>(
                                value: constituency['id'],
                                child: Text(
                                  constituency['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: selectedDistrict != null ? onAssemblyConstituencyChanged : (value) {},
                            validator: (value) {
                              if (value == null) {
                                return 'Please select an assembly constituency';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Party Block Dropdown
                          FormUtils.buildDropdownField<int?>(
                            value: selectedPartyBlock,
                            labelText: 'Party Block',
                            items: partyBlocks.map((partyBlock) {
                              return DropdownMenuItem<int?>(
                                value: partyBlock['id'],
                                child: Text(
                                  partyBlock['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: selectedAssemblyConstituency != null ? onPartyBlockChanged : (value) {},
                          ),
                          const SizedBox(height: 16),
                          
                          // Party Constituency Dropdown
                          FormUtils.buildDropdownField<int?>(
                            value: selectedPartyConstituency,
                            labelText: 'Party Constituency',
                            items: partyConstituencies.map((partyConstituency) {
                              return DropdownMenuItem<int?>(
                                value: partyConstituency['id'],
                                child: Text(
                                  partyConstituency['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: selectedPartyBlock != null ? onPartyConstituencyChanged : (value) {},
                          ),
                          const SizedBox(height: 16),
                          
                          // Parliamentary Constituency Dropdown
                          FormUtils.buildDropdownField<int?>(
                            value: selectedParliamentaryConstituency,
                            labelText: 'Parliamentary Constituency',
                            items: parliamentaryConstituencies.map((constituency) {
                              return DropdownMenuItem<int?>(
                                value: constituency['id'],
                                child: Text(
                                  constituency['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: onParliamentaryConstituencyChanged,
                          ),
                          const SizedBox(height: 32),

                          // Address Details Section
                          FormUtils.buildSectionTitle('Address Details'),
                          const SizedBox(height: 16),

                          // House Name
                          FormUtils.buildTextField(
                            controller: houseNameController,
                            labelText: 'House Name',
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 16),

                          // House Number
                          FormUtils.buildTextField(
                            controller: houseNumberController,
                            labelText: 'House Number',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          // City
                          FormUtils.buildTextField(
                            controller: cityController,
                            labelText: 'City',
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 16),

                          // Post Office
                          FormUtils.buildTextField(
                            controller: postOfficeController,
                            labelText: 'Post Office',
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 16),

                          // Pin Code
                          FormUtils.buildTextField(
                            controller: pinCodeController,
                            labelText: 'PIN Code',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
                                  return 'PIN code must be 6 digits';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Tags Section - Using AddTagsWidget
                          AddTagsWidget(
                            selectedTagCategory: selectedTagCategory,
                            selectedTagName: selectedTagName,
                            tagCategories: tagCategories,
                            availableTagNames: tags,
                            tags: selectedTagIds.map((tagId) {
                              return {
                                'id': tagId,
                                'name': getTagName(tagId),
                              };
                            }).toList(),
                            onTagCategoryChanged: onTagCategoryChanged,
                            onTagNameChanged: onTagNameChanged,
                            onAddTag: onAddTag,
                            onRemoveTag: (tag) => onRemoveTag(tag['id']),
                            sectionTitle: 'Tags',
                            showSectionTitle: true,
                          ),
                          const SizedBox(height: 32),

                          // Additional Information Section
                          FormUtils.buildSectionTitle('Additional Information'),
                          const SizedBox(height: 16),
                          
                          // Note
                          FormUtils.buildTextField(
                            controller: noteController,
                            labelText: 'Note',
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
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