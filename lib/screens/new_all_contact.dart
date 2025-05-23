import 'package:flutter/material.dart';
import 'new_all_contact_ui.dart';
import '../services/new_all_contact_service.dart';

class NewAllContactPage extends StatefulWidget {
  const NewAllContactPage({super.key});

  @override
  State<NewAllContactPage> createState() => _NewAllContactPageState();
}

class _NewAllContactPageState extends State<NewAllContactPage> {
  final Color primaryColor = const Color(0xFF283593);
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // API data lists
  List<Map<String, dynamic>> _primaryContacts = [];
  List<Map<String, dynamic>> _constituencies = [];
  
  // Selected values
  int? _selectedReferredBy;
  int? _selectedCity;
  int? _selectedConstituency;

  // Available cities based on selected constituency
  List<Map<String, dynamic>> _availableCities = [];

  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  // Load all necessary data from APIs
  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
    });
    
    try {
      await Future.wait([
        _fetchPrimaryContacts(),
        _fetchConstituencies(),
      ]);
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

  // Fetch primary contacts using service
  Future<void> _fetchPrimaryContacts() async {
    try {
      final contacts = await NewAllContactService.fetchPrimaryContacts();
      setState(() {
        _primaryContacts = contacts;
      });
    } catch (e) {
      print('Exception in _fetchPrimaryContacts: $e');
      rethrow;
    }
  }

  // Fetch constituencies using service
  Future<void> _fetchConstituencies() async {
    try {
      final constituencies = await NewAllContactService.fetchConstituencies();
      setState(() {
        _constituencies = constituencies;
      });
    } catch (e) {
      print('Exception in _fetchConstituencies: $e');
      rethrow;
    }
  }

  // Update available cities when constituency is selected
  void _updateAvailableCities() {
    if (_selectedConstituency != null) {
      final constituency = _constituencies.firstWhere(
        (c) => c['id'] == _selectedConstituency,
        orElse: () => {'cities': []},
      );
      
      setState(() {
        _availableCities = List<Map<String, dynamic>>.from(constituency['cities'] ?? []);
        _selectedCity = null; // Reset selected city
      });
    } else {
      setState(() {
        _availableCities = [];
        _selectedCity = null;
      });
    }
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Call the service to create contact
        final result = await NewAllContactService.createContact(
          referredBy: _selectedReferredBy,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text.isEmpty ? null : _lastNameController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          countryCode: _countryCodeController.text,
          phone: _phoneController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          address: _addressController.text.isEmpty ? null : _addressController.text,
          city: _selectedCity,
        );

        if (result['success']) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Contact saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back or to a success page
          Navigator.of(context).pop();
        } else {
          // Error
          setState(() {
            _errorMessage = result['message'] ?? 'Failed to save contact. Please try again.';
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
    return NewAllContactUI(
      formKey: _formKey,
      primaryColor: primaryColor,
      isInitialLoading: _isInitialLoading,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      emailController: _emailController,
      countryCodeController: _countryCodeController,
      phoneController: _phoneController,
      noteController: _noteController,
      addressController: _addressController,
      selectedReferredBy: _selectedReferredBy,
      selectedCity: _selectedCity,
      selectedConstituency: _selectedConstituency,
      primaryContacts: _primaryContacts,
      constituencies: _constituencies,
      availableCities: _availableCities,
      onReferredByChanged: (value) => setState(() => _selectedReferredBy = value),
      onConstituencyChanged: (value) {
        setState(() {
          _selectedConstituency = value;
          _updateAvailableCities();
        });
      },
      onCityChanged: (value) => setState(() => _selectedCity = value),
      onSave: _saveContact,
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}