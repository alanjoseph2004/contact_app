import 'package:flutter/material.dart';
import 'contact_logic.dart';

class EditContactUI extends StatelessWidget {
  final Color primaryColor;
  final bool isLoading;
  
  // Controllers
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController countryCodeController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController noteController;
  
  // Contact type
  final ContactType selectedType;
  final Function(ContactType?) onTypeChanged;
  
  // Priority (for primary contacts)
  final int? priority;
  final Function(int?) onPriorityChanged;
  
  // Connection (for all contacts)
  final String? connectionId;
  final Function(String?) onConnectionChanged;
  final List<Contact> primaryContacts;
  
  // Constituency and City
  final int? selectedConstituency;
  final Function(int?) onConstituencyChanged;
  final List<Map<String, dynamic>> constituencies;
  
  final int? selectedCity;
  final Function(int?) onCityChanged;
  final List<Map<String, dynamic>> availableCities;
  
  // Tags
  final int? selectedTagCategory;
  final Function(int?) onTagCategoryChanged;
  final List<Map<String, dynamic>> tagCategories;
  
  final int? selectedTagName;
  final Function(int?) onTagNameChanged;
  final List<Map<String, dynamic>> availableTagNames;
  
  final List<Map<String, dynamic>> selectedTags;
  final Function(int) onTagDeleted;
  final VoidCallback onAddTag;
  
  // Actions
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const EditContactUI({
    super.key,
    required this.primaryColor,
    required this.isLoading,
    required this.firstNameController,
    required this.lastNameController,
    required this.countryCodeController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.noteController,
    required this.selectedType,
    required this.onTypeChanged,
    required this.priority,
    required this.onPriorityChanged,
    required this.connectionId,
    required this.onConnectionChanged,
    required this.primaryContacts,
    required this.selectedConstituency,
    required this.onConstituencyChanged,
    required this.constituencies,
    required this.selectedCity,
    required this.onCityChanged,
    required this.availableCities,
    required this.selectedTagCategory,
    required this.onTagCategoryChanged,
    required this.tagCategories,
    required this.selectedTagName,
    required this.onTagNameChanged,
    required this.availableTagNames,
    required this.selectedTags,
    required this.onTagDeleted,
    required this.onAddTag,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Contact", style: TextStyle(color: primaryColor)),
      content: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Personal Information section
              _buildSectionHeader('Personal Information'),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name*'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: countryCodeController,
                      decoration: const InputDecoration(labelText: 'Country Code*'),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 3,
                    child: TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number*'),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),

              // Contact Type section
              const SizedBox(height: 16),
              _buildSectionHeader('Contact Classification'),
              DropdownButtonFormField<ContactType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Contact Type*'),
                items: ContactType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.Capitalize()),
                  );
                }).toList(),
                onChanged: onTypeChanged,
              ),
              
              // Priority field for primary contacts
              if (selectedType == ContactType.primary)
                DropdownButtonFormField<int>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Priority*'),
                  items: List.generate(5, (index) => index + 1)
                      .map((priorityValue) => DropdownMenuItem(
                            value: priorityValue,
                            child: Text('Priority $priorityValue'),
                          ))
                      .toList(),
                  onChanged: onPriorityChanged,
                ),
              
              // Connection field for all contacts
              if (selectedType == ContactType.all)
                DropdownButtonFormField<String>(
                  value: connectionId,
                  decoration: const InputDecoration(labelText: 'Connection'),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('None'),
                    ),
                    ...primaryContacts.map((primaryContact) => 
                      DropdownMenuItem(
                        value: primaryContact.id,
                        child: Text(primaryContact.name),
                      )
                    ),
                  ],
                  onChanged: onConnectionChanged,
                ),
                
              // Additional Information section with API data
              const SizedBox(height: 16),
              _buildSectionHeader('Additional Information'),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              
              // Constituency dropdown (from API)
              DropdownButtonFormField<int>(
                value: selectedConstituency,
                decoration: const InputDecoration(labelText: 'Constituency'),
                isExpanded: true,
                items: constituencies.map((constituency) {
                  return DropdownMenuItem<int>(
                    value: constituency['id'],
                    child: Text(constituency['name']),
                  );
                }).toList(),
                onChanged: onConstituencyChanged,
              ),
              
              // City dropdown (from API, filtered by constituency)
              DropdownButtonFormField<int>(
                value: selectedCity,
                decoration: const InputDecoration(labelText: 'City'),
                isExpanded: true,
                items: availableCities.map((city) {
                  return DropdownMenuItem<int>(
                    value: city['id'],
                    child: Text(city['name']),
                  );
                }).toList(),
                onChanged: onCityChanged,
              ),
              
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
                maxLines: 3,
              ),
              
              // Tags section
              const SizedBox(height: 16),
              _buildSectionHeader('Tags'),
              _buildTagsSelection(),
            ],
          ),
        ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text("CANCEL", style: TextStyle(color: primaryColor)),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            disabledBackgroundColor: Colors.grey,
          ),
          child: const Text("SAVE", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display selected tags as chips
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: [
            ...selectedTags.map((tag) => Chip(
              label: Text("${tag['categoryName']}: ${tag['name']}"),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => onTagDeleted(tag['id']),
            )),
          ],
        ),
        
        // Add tag section with category and tag dropdowns
        const SizedBox(height: 8),
        Row(
          children: [
            // Tag Category Dropdown
            Expanded(
              child: DropdownButtonFormField<int>(
                value: selectedTagCategory,
                decoration: const InputDecoration(
                  labelText: 'Tag Category',
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                items: tagCategories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category['id'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: onTagCategoryChanged,
              ),
            ),
            const SizedBox(width: 8),
            // Tag Name Dropdown
            Expanded(
              child: DropdownButtonFormField<int>(
                value: selectedTagName,
                decoration: const InputDecoration(
                  labelText: 'Tag Name',
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                items: availableTagNames.map((tag) {
                  return DropdownMenuItem<int>(
                    value: tag['id'],
                    child: Text(tag['name']),
                  );
                }).toList(),
                onChanged: onTagNameChanged,
              ),
            ),
          ],
        ),
        
        // Add Tag button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add Tag"),
            onPressed: selectedTagCategory != null && selectedTagName != null 
              ? onAddTag
              : null,
          ),
        ),
      ],
    );
  }
}

// Extension needed for capitalizing strings (used in contact type dropdown)
extension StringExtension on String {
  String Capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}