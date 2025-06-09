import 'package:flutter/material.dart';

class PersonalDetailsWidget extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController countryCodeController;
  final TextEditingController phoneController;
  final TextEditingController noteController;
  final bool showNotes;
  final bool showSectionTitle;
  final String sectionTitle;

  const PersonalDetailsWidget({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.countryCodeController,
    required this.phoneController,
    required this.noteController,
    this.showNotes = true,
    this.showSectionTitle = true,
    this.sectionTitle = 'Personal Details',
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Title (optional)
        if (showSectionTitle) ...[
          _buildSectionTitle(sectionTitle),
          const SizedBox(height: 16),
        ],
        
        // Name Fields
        Row(
          children: [
            // First Name with responsive width
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: screenWidth < 400 ? screenWidth * 0.4 : 175,
                maxWidth: 175,
              ),
              child: SizedBox(
                height: 49,
                child: _buildTextField(
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
            ),
            const SizedBox(width: 8),
            // Last Name expands to fill remaining space
            Expanded(
              child: SizedBox(
                height: 49,
                child: _buildTextField(
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
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Email Field - responsive width
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth < 400 ? screenWidth : 358,
          ),
          child: SizedBox(
            height: 49,
            child: _buildTextField(
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
          ),
        ),
        const SizedBox(height: 16),

        // Phone Number Fields
        Row(
          children: [
            // Country Code with responsive width
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: screenWidth < 400 ? 70 : 88,
                maxWidth: 88,
              ),
              child: SizedBox(
                height: 49,
                child: _buildTextField(
                  controller: countryCodeController,
                  labelText: '+91',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length > 5) {
                      return 'Max 5 chars';
                    }
                    return null;
                  },
                  maxLength: 5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Phone Number expands to fill remaining space
            Expanded(
              child: SizedBox(
                height: 49,
                child: _buildTextField(
                  controller: phoneController,
                  labelText: 'Phone Number*',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (value.length > 11) {
                      return 'Phone number must be 11 characters or less';
                    }
                    return null;
                  },
                  maxLength: 11,
                ),
              ),
            ),
          ],
        ),
        
        // Notes Field (optional) - responsive width
        if (showNotes) ...[
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth < 400 ? screenWidth : 358,
            ),
            child: SizedBox(
              height: 70,
              child: _buildTextField(
                controller: noteController,
                labelText: 'Notes',
                maxLines: 3,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
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
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.only(
          top: 10,
          right: 16,
          bottom: 10,
          left: 16,
        ),
        counterText: '',
      ),
    );
  }
}