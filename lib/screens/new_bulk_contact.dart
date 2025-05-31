import 'package:flutter/material.dart';
import '../services/bulk_contact_service.dart';
import 'new_bulk_contacts_ui.dart';

class BulkContactsUploadPage extends StatefulWidget {
  const BulkContactsUploadPage({super.key});

  @override
  State<BulkContactsUploadPage> createState() => _BulkContactsUploadPageState();
}

class _BulkContactsUploadPageState extends State<BulkContactsUploadPage> {
  final Color primaryColor = const Color(0xFF007AFF);
  final Color backgroundColor = const Color(0xFFF2F2F7);
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // API data lists
  List<Map<String, dynamic>> _primaryContacts = [];
  List<Map<String, dynamic>> _constituencies = [];
  
  // Selected values
  int? _selectedReferredBy;
  
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _errorMessage;

  // List of contact forms
  final List<ContactFormData> _contactForms = [];
  
  // API service instance
  final ContactApiService _apiService = ContactApiService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    // Add first empty contact form
    _addNewContactForm();
  }
  
  // Add a new contact form
  void _addNewContactForm() {
    setState(() {
      _contactForms.add(ContactFormData());
    });
  }

  // Remove a contact form at specific index
  void _removeContactForm(int index) {
    if (_contactForms.length > 1) {
      setState(() {
        _contactForms.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least one contact'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Load all necessary data from APIs
  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
    });
    
    try {
      // Using API service instance instead of static calls
      final primaryContacts = await _apiService.fetchPrimaryContacts();
      final constituencies = await _apiService.fetchConstituencies();
      
      setState(() {
        _primaryContacts = primaryContacts;
        _constituencies = constituencies;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load initial data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  // Update available cities when constituency is selected
  List<Map<String, dynamic>> _getAvailableCities(int? constituencyId) {
    return _apiService.getAvailableCities(_constituencies, constituencyId);
  }

  Future<void> _saveBulkContacts() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Prepare the contacts data
        List<Map<String, dynamic>> contactsData = _contactForms.map((form) {
          return {
            'first_name': form.firstNameController.text,
            'last_name': form.lastNameController.text.isEmpty ? null : form.lastNameController.text,
            'email': form.emailController.text.isEmpty ? null : form.emailController.text,
            'country_code': form.countryCodeController.text,
            'phone': form.phoneController.text,
            'note': form.noteController.text.isEmpty ? null : form.noteController.text,
            'address': form.addressController.text.isEmpty ? null : form.addressController.text,
            'city': form.selectedCity,
          };
        }).toList();

        // Use API service instance to save contacts
        final result = await _apiService.saveBulkContacts(
          referredBy: _selectedReferredBy!,
          contacts: contactsData,
        );

        if (result['success']) {
          // Success
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navigate back or to a success page
            Navigator.of(context).pop();
          }
        } else {
          // Error
          setState(() {
            _errorMessage = result['message'];
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BulkContactsUI(
      formKey: _formKey,
      backgroundColor: backgroundColor,
      primaryColor: primaryColor,
      isInitialLoading: _isInitialLoading,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      primaryContacts: _primaryContacts,
      selectedReferredBy: _selectedReferredBy,
      contactForms: _contactForms,
      constituencies: _constituencies,
      onReferredByChanged: (value) {
        setState(() => _selectedReferredBy = value);
      },
      onRemoveContactForm: _removeContactForm,
      getAvailableCities: _getAvailableCities,
      onAddNewContactForm: _addNewContactForm,
      onSaveBulkContacts: _saveBulkContacts,
    );
  }

  @override
  void dispose() {
    // Dispose controllers for all contact forms
    for (var form in _contactForms) {
      form.dispose();
    }
    super.dispose();
  }
}

// Class to hold form data for each contact
class ContactFormData {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController(text: '+91');
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  
  // Additional residential details controllers
  final TextEditingController houseNameController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController postOfficeController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  
  int? selectedConstituency;
  int? selectedCity;
  int? selectedPartyBlock;
  int? selectedPartyConstituency;
  int? selectedBooth;
  int? selectedParliamentaryConstituency;
  int? selectedLocalBody;
  int? selectedWard;

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    countryCodeController.dispose();
    phoneController.dispose();
    noteController.dispose();
    addressController.dispose();
    houseNameController.dispose();
    houseNumberController.dispose();
    postOfficeController.dispose();
    pinCodeController.dispose();
  }
}