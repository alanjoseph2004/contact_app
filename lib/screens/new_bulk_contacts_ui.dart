import 'package:flutter/material.dart';
import 'new_bulk_contact.dart';

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
  final Function(int?) getAvailableCities;
  final VoidCallback onAddNewContactForm;
  final VoidCallback onSaveBulkContacts;

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Bulk Contacts Upload',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Error message if any
                      if (errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                          ),
                        ),
                      
                      // Referred By Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: DropdownButtonFormField<int?>(
                            value: selectedReferredBy,
                            decoration: const InputDecoration(
                              labelText: 'Referred By',
                              labelStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
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
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
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
                              side: BorderSide(color: primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: primaryColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Add Contact',
                                  style: TextStyle(
                                    color: primaryColor,
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
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
    int? maxLength,
    bool hasSpacing = true,
  }) {
    return Container(
      margin: hasSpacing ? const EdgeInsets.only(bottom: 12) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5E7), width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        maxLength: maxLength,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          counterText: '',
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required dynamic value,
    required List<DropdownMenuItem> items,
    required Function(dynamic) onChanged,
    String? Function(dynamic)? validator,
    String? hintText,
    bool hasSpacing = true,
  }) {
    return Container(
      margin: hasSpacing ? const EdgeInsets.only(bottom: 12) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E5E7), width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: DropdownButtonFormField(
        value: value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        items: items,
        onChanged: onChanged,
        validator: validator,
        hint: hintText != null ? Text(hintText) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get cities based on selected constituency
    final availableCities = widget.getAvailableCities(widget.contactForm.selectedConstituency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact Header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contact #${widget.index + 1}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (widget.showRemoveButton)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                  onPressed: widget.onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),

        // Personal Details Section
        _buildSectionTitle('Personal Details'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildTextField(
                controller: widget.contactForm.firstNameController,
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
              _buildTextField(
                controller: widget.contactForm.lastNameController,
                labelText: 'Last Name',
                validator: (value) {
                  if (value != null && value.length > 63) {
                    return 'Last name must be 63 characters or less';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: widget.contactForm.emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  if (value.length > 255) {
                    return 'Email must be 255 characters or less';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Container(
                      margin: const EdgeInsets.only(right: 12, bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E5E7), width: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: TextFormField(
                        controller: widget.contactForm.countryCodeController,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Code',
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          counterText: '',
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
                  ),
                  Expanded(
                    child: _buildTextField(
                      controller: widget.contactForm.phoneController,
                      labelText: 'Phone Number*',
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        if(value.length > 11){
                          return 'Phone number must be 11 characters or less';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: widget.contactForm.noteController,
                labelText: 'Notes',
                maxLines: 3,
                hasSpacing: false,
              ),
            ],
          ),
        ),

        // Other Details Section
        _buildSectionTitle('Other Details'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildDropdownField(
                labelText: 'District',
                value: widget.contactForm.selectedConstituency,
                items: widget.constituencies.map<DropdownMenuItem<int?>>((constituency) {
                  return DropdownMenuItem<int?>(
                    value: constituency['id'],
                    child: Text(constituency['name'].toString()),
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
              _buildDropdownField(
                labelText: 'Assembly Constituency',
                value: widget.contactForm.selectedCity,
                items: availableCities.map<DropdownMenuItem<int?>>((city) {
                  return DropdownMenuItem<int?>(
                    value: city['id'],
                    child: Text(city['name'].toString()),
                  );
                }).toList(),
                onChanged: availableCities.isEmpty 
                  ? (value) {} 
                  : (value) {
                      setState(() {
                        widget.contactForm.selectedCity = value;
                      });
                    },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a city';
                  }
                  return null;
                },
                hintText: availableCities.isEmpty ? 'Select constituency first' : 'Select city',
              ),
              _buildDropdownField(
                labelText: 'Party Block',
                value: widget.contactForm.selectedPartyBlock,
                items: const <DropdownMenuItem<int?>>[],
                onChanged: (value) {
                  setState(() {
                    widget.contactForm.selectedPartyBlock = value;
                  });
                },
              ),
              _buildDropdownField(
                labelText: 'Party Constituency',
                value: widget.contactForm.selectedPartyConstituency,
                items: const <DropdownMenuItem<int?>>[],
                onChanged: (value) {
                  setState(() {
                    widget.contactForm.selectedPartyConstituency = value;
                  });
                },
              ),
              _buildDropdownField(
                labelText: 'Booth',
                value: widget.contactForm.selectedBooth,
                items: const <DropdownMenuItem<int?>>[],
                onChanged: (value) {
                  setState(() {
                    widget.contactForm.selectedBooth = value;
                  });
                },
              ),
              _buildDropdownField(
                labelText: 'Parliamentary Constituency',
                value: widget.contactForm.selectedParliamentaryConstituency,
                items: const <DropdownMenuItem<int?>>[],
                onChanged: (value) {
                  setState(() {
                    widget.contactForm.selectedParliamentaryConstituency = value;
                  });
                },
              ),
              _buildDropdownField(
                labelText: 'Local Body',
                value: widget.contactForm.selectedLocalBody,
                items: const <DropdownMenuItem<int?>>[],
                onChanged: (value) {
                  setState(() {
                    widget.contactForm.selectedLocalBody = value;
                  });
                },
              ),
              _buildDropdownField(
                labelText: 'Ward',
                value: widget.contactForm.selectedWard,
                items: const <DropdownMenuItem<int?>>[],
                onChanged: (value) {
                  setState(() {
                    widget.contactForm.selectedWard = value;
                  });
                },
                hasSpacing: false,
              ),
            ],
          ),
        ),

        // Residential Details Section
        _buildSectionTitle('Residential Details'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildTextField(
                controller: widget.contactForm.houseNameController,
                labelText: 'House Name',
              ),
              _buildTextField(
                controller: widget.contactForm.houseNumberController,
                labelText: 'House Number',
              ),
              _buildTextField(
                controller: widget.contactForm.addressController,
                labelText: 'City',
              ),
              _buildTextField(
                controller: widget.contactForm.postOfficeController,
                labelText: 'Post Office',
              ),
              _buildTextField(
                controller: widget.contactForm.pinCodeController,
                labelText: 'Pin Code',
                keyboardType: TextInputType.number,
                hasSpacing: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}