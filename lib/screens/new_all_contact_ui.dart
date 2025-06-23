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
  final int? selectedParliamentaryConstituency;
  final int? selectedPartyBlock;
  final int? selectedPartyConstituency;
  final int? selectedBooth;
  final int? selectedLocalBody;
  final int? selectedWard;
  final int? selectedTagCategory;
  final int? selectedTagName;
  final List<int> selectedTagIds;

  // Data Lists
  final List<Map<String, dynamic>> primaryContacts;
  final List<Map<String, dynamic>> districts;
  final List<Map<String, dynamic>> assemblyConstituencies;
  final List<Map<String, dynamic>> parliamentaryConstituencies;
  final List<Map<String, dynamic>> tagCategories;
  final List<Map<String, dynamic>> tags;

  // Callbacks
  final Function(int?) onReferredByChanged;
  final Function(int?) onDistrictChanged;
  final Function(int?) onAssemblyConstituencyChanged;
  final Function(int?) onParliamentaryConstituencyChanged;
  final Function(int?) onPartyBlockChanged;
  final Function(int?) onPartyConstituencyChanged;
  final Function(int?) onBoothChanged;
  final Function(int?) onLocalBodyChanged;
  final Function(int?) onWardChanged;
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
    required this.selectedParliamentaryConstituency,
    required this.selectedPartyBlock,
    required this.selectedPartyConstituency,
    required this.selectedBooth,
    required this.selectedLocalBody,
    required this.selectedWard,
    required this.selectedTagCategory,
    required this.selectedTagName,
    required this.selectedTagIds,
    required this.primaryContacts,
    required this.districts,
    required this.assemblyConstituencies,
    required this.parliamentaryConstituencies,
    required this.tagCategories,
    required this.tags,
    required this.onReferredByChanged,
    required this.onDistrictChanged,
    required this.onAssemblyConstituencyChanged,
    required this.onParliamentaryConstituencyChanged,
    required this.onPartyBlockChanged,
    required this.onPartyConstituencyChanged,
    required this.onBoothChanged,
    required this.onLocalBodyChanged,
    required this.onWardChanged,
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
                                child: Text(contact['name'] ?? 'Unknown'),
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
                                child: Text(district['name'] ?? 'Unknown'),
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
                                child: Text(constituency['name'] ?? 'Unknown'),
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
                          
                          // Parliamentary Constituency Dropdown
                          FormUtils.buildDropdownField<int?>(
                            value: selectedParliamentaryConstituency,
                            labelText: 'Parliamentary Constituency',
                            items: parliamentaryConstituencies.map((constituency) {
                              return DropdownMenuItem<int?>(
                                value: constituency['id'],
                                child: Text(constituency['name'] ?? 'Unknown'),
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
                          
                          // Political Information Section
                          FormUtils.buildSectionTitle('Political Information'),
                          const SizedBox(height: 16),
                          
                          // Party Block Dropdown (placeholder)
                          FormUtils.buildDropdownField<int?>(
                            value: selectedPartyBlock,
                            labelText: 'Party Block',
                            items: const [], // Add actual data here later
                            onChanged: (value) {}, // Disabled until you have the data
                          ),
                          const SizedBox(height: 16),
                          
                          // Party Constituency Dropdown (placeholder)
                          FormUtils.buildDropdownField<int?>(
                            value: selectedPartyConstituency,
                            labelText: 'Party Constituency',
                            items: const [], // Add actual data here later
                            onChanged: (value) {}, // Disabled until you have the data
                          ),
                          const SizedBox(height: 16),
                          
                          // Booth Dropdown (placeholder)
                          FormUtils.buildDropdownField<int?>(
                            value: selectedBooth,
                            labelText: 'Booth',
                            items: const [], // Add actual data here later
                            onChanged: (value) {}, // Disabled until you have the data
                          ),
                          const SizedBox(height: 16),
                          
                          // Local Body Dropdown (placeholder)
                          FormUtils.buildDropdownField<int?>(
                            value: selectedLocalBody,
                            labelText: 'Local Body',
                            items: const [], // Add actual data here later
                            onChanged: (value) {}, // Disabled until you have the data
                          ),
                          const SizedBox(height: 16),
                          
                          // Ward Dropdown (placeholder)
                          FormUtils.buildDropdownField<int?>(
                            value: selectedWard,
                            labelText: 'Ward',
                            items: const [], // Add actual data here later
                            onChanged: (value) {}, // Disabled until you have the data
                          ),
                          const SizedBox(height: 32),

                          // Tags Section - Custom implementation to match your existing structure
                          FormUtils.buildSectionTitle('Tags'),
                          const SizedBox(height: 16),
                          
                          // Tag Category Dropdown
                          FormUtils.buildDropdownField<int?>(
                            value: selectedTagCategory,
                            labelText: 'Tag Category',
                            items: tagCategories.map((category) {
                              return DropdownMenuItem<int?>(
                                value: category['id'],
                                child: Text(category['name'] ?? 'Unknown'),
                              );
                            }).toList(),
                            onChanged: onTagCategoryChanged,
                          ),
                          const SizedBox(height: 16),
                          
                          // Tag Name Dropdown with Add Button
                          Row(
                            children: [
                              Expanded(
                                child: FormUtils.buildDropdownField<int?>(
                                  value: selectedTagName,
                                  labelText: 'Tag Name',
                                  items: tags.map((tag) {
                                    return DropdownMenuItem<int?>(
                                      value: tag['id'],
                                      child: Text(tag['name'] ?? 'Unknown'),
                                    );
                                  }).toList(),
                                  onChanged: selectedTagCategory != null ? onTagNameChanged : (value) {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: selectedTagName != null ? onAddTag : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Selected Tags Display
                          if (selectedTagIds.isNotEmpty) ...[
                            const Text(
                              'Selected Tags:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: selectedTagIds.map((tagId) {
                                return Chip(
                                  label: Text(getTagName(tagId)),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () => onRemoveTag(tagId),
                                  backgroundColor: primaryColor.withOpacity(0.1),
                                  labelStyle: TextStyle(color: primaryColor),
                                  deleteIconColor: primaryColor,
                                );
                              }).toList(),
                            ),
                          ],
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