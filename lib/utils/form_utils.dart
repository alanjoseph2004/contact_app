import 'package:flutter/material.dart';

class FormUtils {
  // Common text field styling - Updated to match PersonalDetailsWidget
  static Widget buildTextField({
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
        fillColor: const Color(0xFFF5F5F5), // Updated to match PersonalDetailsWidget
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13), // Updated to match PersonalDetailsWidget
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5), // Reduced thickness
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5), // Reduced thickness
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFF4285F4), width: 1.5), // Reduced thickness
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Colors.red, width: 0.5), // Reduced thickness
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Colors.red, width: 1.5), // Reduced thickness
        ),
        contentPadding: const EdgeInsets.only( // Updated to match PersonalDetailsWidget
          top: 10,
          right: 16,
          bottom: 10,
          left: 16,
        ),
        counterText: '',
      ),
    );
  }

  // Common dropdown field styling - Updated to match PersonalDetailsWidget
  static Widget buildDropdownField<T>({
    required T? value,
    required String labelText,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5), // Updated to match PersonalDetailsWidget
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13), // Updated to match PersonalDetailsWidget
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5), // Reduced thickness
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5), // Reduced thickness
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFF4285F4), width: 1.5), // Reduced thickness
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Colors.red, width: 0.5), // Reduced thickness
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Colors.red, width: 1.5), // Reduced thickness
        ),
        contentPadding: const EdgeInsets.only( // Updated to match PersonalDetailsWidget
          top: 10,
          right: 16,
          bottom: 10,
          left: 16,
        ),
        suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      items: items,
      onChanged: onChanged,
      dropdownColor: Colors.white,
    );
  }

  // Common section title styling
  static Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // Common validators
  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter first name';
    }
    if (value.length > 63) {
      return 'First name must be 63 characters or less';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value != null && value.length > 63) {
      return 'Last name must be 63 characters or less';
    }
    return null;
  }

  static String? validateEmail(String? value) {
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
  }

  static String? validateCountryCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    if (value.length > 5) {
      return 'Max 5 chars';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    if (value.length > 11) {
      return 'Phone number must be 11 characters or less';
    }
    return null;
  }

  // Common loading overlay
  static Widget buildLoadingOverlay({
    required String message,
    required bool isVisible,
  }) {
    if (!isVisible) return const SizedBox.shrink();
    
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Common error message display
  static Widget buildErrorMessage(String? errorMessage) {
    if (errorMessage == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.red.shade900),
            ),
          ),
        ],
      ),
    );
  }
}