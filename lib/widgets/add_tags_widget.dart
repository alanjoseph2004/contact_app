import 'package:flutter/material.dart';

class AddTagsWidget extends StatelessWidget {
  final int? selectedTagCategory;
  final int? selectedTagName;
  final List<Map<String, dynamic>> tagCategories;
  final List<Map<String, dynamic>> availableTagNames;
  final List<Map<String, dynamic>> tags;
  final Function(int?) onTagCategoryChanged;
  final Function(int?) onTagNameChanged;
  final Function() onAddTag;
  final Function(Map<String, dynamic>) onRemoveTag;
  final String? sectionTitle;
  final bool showSectionTitle;

  const AddTagsWidget({
    super.key,
    required this.selectedTagCategory,
    required this.selectedTagName,
    required this.tagCategories,
    required this.availableTagNames,
    required this.tags,
    required this.onTagCategoryChanged,
    required this.onTagNameChanged,
    required this.onAddTag,
    required this.onRemoveTag,
    this.sectionTitle,
    this.showSectionTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title (optional)
        if (showSectionTitle) ...[
          Text(
            sectionTitle ?? 'Add Tags',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Tag Category Dropdown
        _buildDropdownField<int?>(
          value: selectedTagCategory,
          labelText: 'Tag Category',
          items: tagCategories.map((category) {
            return DropdownMenuItem<int?>(
              value: category['id'],
              child: Text(category['name']),
            );
          }).toList(),
          onChanged: onTagCategoryChanged,
        ),
        const SizedBox(height: 16),
        
        // Tag Name Dropdown with Add button
        Row(
          children: [
            Expanded(
              child: _buildDropdownField<int?>(
                value: selectedTagName,
                labelText: 'Tag Name',
                items: availableTagNames.map((tag) {
                  return DropdownMenuItem<int?>(
                    value: tag['id'],
                    child: Text(tag['name']),
                  );
                }).toList(),
                onChanged: availableTagNames.isEmpty ? (value) {} : onTagNameChanged,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF4285F4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
                onPressed: selectedTagName != null ? onAddTag : null,
              ),
            ),
          ],
        ),
        
        // Display Added Tags
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Chip(
                label: Text(
                  tag['name'],
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                deleteIcon: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.grey,
                ),
                onDeleted: () => onRemoveTag(tag),
                backgroundColor: const Color(0xFFF0F0F0),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownField<T>({
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
        fillColor: const Color(0xFFF5F5F5), // Changed from Colors.white to match PersonalDetailsWidget
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13), // Changed from 12 to 13
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5), // Reduced thickness
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13), // Changed from 12 to 13
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5), // Reduced thickness
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13), // Changed from 12 to 13
          borderSide: const BorderSide(color: Color(0xFF4285F4), width: 1.5), // Reduced thickness
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13), // Changed from 12 to 13
          borderSide: const BorderSide(color: Colors.red, width: 0.5), // Reduced thickness
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13), // Changed from 12 to 13
          borderSide: const BorderSide(color: Colors.red, width: 1.5), // Reduced thickness
        ),
        contentPadding: const EdgeInsets.only(
          top: 10,
          right: 16,
          bottom: 10,
          left: 16,
        ), // Changed to match PersonalDetailsWidget padding
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
}