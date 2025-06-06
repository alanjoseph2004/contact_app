import 'package:flutter/material.dart';
import 'new_bulk_contact.dart';
import '../utils/form_utils.dart';
import '../widgets/personal_details_widget.dart';

class BulkContactsUI extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Color backgroundColor;
  final Color primaryColor;
  final bool isInitialLoading;
  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> primaryContacts;
  final int? selectedReferredBy;
  final List<ContactFormData> contactForms;
  final List<Map<String, dynamic>> constituencies;
  final Function(int?) onReferredByChanged;
  final Function(int) onRemoveContactForm;
  final List<Map<String, dynamic>> Function(int?) getAvailableCities;
  final VoidCallback onAddNewContactForm;
  final VoidCallback onSaveBulkContacts;

  // Define consistent color scheme matching contacts_page_ui.dart
  static const Color _primaryBlue = Color(0xFF4285F4);
  static const Color _textPrimary = Color(0xFF212121);
  static const Color _backgroundColor = Colors.white;

  const BulkContactsUI({
    super.key,
    required this.formKey,
    required this.backgroundColor,
    required this.primaryColor,
    required this.isInitialLoading,
    required this.isLoading,
    required this.errorMessage,
    required this.primaryContacts,
    required this.selectedReferredBy,
    required this.contactForms,
    required this.constituencies,
    required this.onReferredByChanged,
    required this.onRemoveContactForm,
    required this.getAvailableCities,
    required this.onAddNewContactForm,
    required this.onSaveBulkContacts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Bulk Contacts Upload',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: isInitialLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
              ),
            )
          : Stack(
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Error message using FormUtils
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: FormUtils.buildErrorMessage(errorMessage),
                      ),
                      
                      // Referred By Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: FormUtils.buildDropdownField<int?>(
                          value: selectedReferredBy,
                          labelText: 'Referred By',
                          items: primaryContacts.map((contact) {
                            return DropdownMenuItem<int?>(
                              value: contact['id'],
                              child: Text(
                                "${contact['name']} (${contact['phone']})",
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: _textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
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
                      ),

                      // Contact Forms in Expanded to allow scrolling
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: contactForms.length,
                          itemBuilder: (context, index) {
                            return ContactFormWidget(
                              contactForm: contactForms[index],
                              constituencies: constituencies,
                              getAvailableCities: getAvailableCities,
                              onRemove: () => onRemoveContactForm(index),
                              showRemoveButton: contactForms.length > 1,
                              index: index,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Fixed bottom buttons
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onAddNewContactForm,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: _primaryBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: _primaryBlue, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Add Contact',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: _primaryBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : onSaveBulkContacts,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading 
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save All Contacts',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Loading overlay using FormUtils
                FormUtils.buildLoadingOverlay(
                  message: 'Saving contacts...',
                  isVisible: isLoading,
                ),
              ],
            ),
    );
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

class _ContactFormWidgetState extends State<ContactFormWidget> {
  // Define consistent color scheme matching contacts_page_ui.dart
  static const Color _textPrimary = Color(0xFF212121);
  static const Color _backgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    // Get cities based on selected constituency
    final availableCities = widget.getAvailableCities(widget.contactForm.selectedConstituency);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: _backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contact #${widget.index + 1}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                if (widget.showRemoveButton)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Personal Details Section using PersonalDetailsWidget
            PersonalDetailsWidget(
              firstNameController: widget.contactForm.firstNameController,
              lastNameController: widget.contactForm.lastNameController,
              emailController: widget.contactForm.emailController,
              countryCodeController: widget.contactForm.countryCodeController,
              phoneController: widget.contactForm.phoneController,
              noteController: widget.contactForm.noteController,
              showNotes: true,
              showSectionTitle: true,
              sectionTitle: 'Personal Details',
            ),
            
            const SizedBox(height: 24),

            // Other Details Section
            FormUtils.buildSectionTitle('Other Details'),
            const SizedBox(height: 16),
            
            FormUtils.buildDropdownField<int?>(
              value: widget.contactForm.selectedConstituency,
              labelText: 'District',
              items: widget.constituencies.map<DropdownMenuItem<int?>>((constituency) {
                return DropdownMenuItem<int?>(
                  value: constituency['id'],
                  child: Text(
                    constituency['name'].toString(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  widget.contactForm.selectedConstituency = value;
                  widget.contactForm.selectedCity = null;
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
            
            FormUtils.buildDropdownField<int?>(
              value: widget.contactForm.selectedCity,
              labelText: 'Assembly Constituency',
              items: availableCities.map<DropdownMenuItem<int?>>((city) {
                return DropdownMenuItem<int?>(
                  value: city['id'],
                  child: Text(
                    city['name'].toString(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (!availableCities.isEmpty) {
                  setState(() {
                    widget.contactForm.selectedCity = value;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a city';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            FormUtils.buildDropdownField<int?>(
              value: widget.contactForm.selectedPartyBlock,
              labelText: 'Party Block',
              items: const <DropdownMenuItem<int?>>[],
              onChanged: (value) {
                setState(() {
                  widget.contactForm.selectedPartyBlock = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            FormUtils.buildDropdownField<int?>(
              value: widget.contactForm.selectedPartyConstituency,
              labelText: 'Party Constituency',
              items: const <DropdownMenuItem<int?>>[],
              onChanged: (value) {
                setState(() {
                  widget.contactForm.selectedPartyConstituency = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            FormUtils.buildDropdownField<int?>(
              value: widget.contactForm.selectedBooth,
              labelText: 'Booth',
              items: const <DropdownMenuItem<int?>>[],
              onChanged: (value) {
                setState(() {
                  widget.contactForm.selectedBooth = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            FormUtils.buildDropdownField<int?>(
              value: widget.contactForm.selectedParliamentaryConstituency,
              labelText: 'Parliamentary Constituency',
              items: const <DropdownMenuItem<int?>>[],
              onChanged: (value) {
                setState(() {
                  widget.contactForm.selectedParliamentaryConstituency = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            FormUtils.buildDropdownField<int?>(
              value: widget.contactForm.selectedLocalBody,
              labelText: 'Local Body',
              items: const <DropdownMenuItem<int?>>[],
              onChanged: (value) {
                setState(() {
                  widget.contactForm.selectedLocalBody = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            FormUtils.buildDropdownField<int?>(
              value: widget.contactForm.selectedWard,
              labelText: 'Ward',
              items: const <DropdownMenuItem<int?>>[],
              onChanged: (value) {
                setState(() {
                  widget.contactForm.selectedWard = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // Residential Details Section
            FormUtils.buildSectionTitle('Residential Details'),
            const SizedBox(height: 16),
            
            FormUtils.buildTextField(
              controller: widget.contactForm.houseNameController,
              labelText: 'House Name',
            ),
            const SizedBox(height: 16),
            
            FormUtils.buildTextField(
              controller: widget.contactForm.houseNumberController,
              labelText: 'House Number',
            ),
            const SizedBox(height: 16),
            
            FormUtils.buildTextField(
              controller: widget.contactForm.addressController,
              labelText: 'City',
            ),
            const SizedBox(height: 16),
            
            FormUtils.buildTextField(
              controller: widget.contactForm.postOfficeController,
              labelText: 'Post Office',
            ),
            const SizedBox(height: 16),
            
            FormUtils.buildTextField(
              controller: widget.contactForm.pinCodeController,
              labelText: 'Pin Code',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}