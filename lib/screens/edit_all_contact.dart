// import 'package:flutter/material.dart';
// import 'contact_logic.dart';
// import '../services/edit_all_contact_service.dart';
// import '../widgets/personal_details_widget.dart';
// import '../utils/form_utils.dart';

// class EditAllContactScreen extends StatefulWidget {
//   final Contact contact;

//   const EditAllContactScreen({
//     super.key,
//     required this.contact,
//   });

//   @override
//   State<EditAllContactScreen> createState() => _EditAllContactScreenState();
// }

// class _EditAllContactScreenState extends State<EditAllContactScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _service = EditAllContactService();
  
//   // Personal Details Controllers
//   late TextEditingController _firstNameController;
//   late TextEditingController _lastNameController;
//   late TextEditingController _emailController;
//   late TextEditingController _countryCodeController;
//   late TextEditingController _phoneController;
//   late TextEditingController _noteController;
  
//   // Other Details Controllers
//   late TextEditingController _addressController;
//   late TextEditingController _houseNumberController;
//   late TextEditingController _cityController;
//   late TextEditingController _postOfficeController;
//   late TextEditingController _pinCodeController;
  
//   // API data lists
//   List<Map<String, dynamic>> _primaryContacts = [];
//   List<Map<String, dynamic>> _constituencies = [];
  
//   // Selected values
//   int? _selectedReferredBy;
//   int? _selectedCity;
//   int? _selectedConstituency;
//   int? _selectedPartyBlock;
//   int? _selectedPartyConstituency;
//   int? _selectedBooth;
//   int? _selectedParliamentaryConstituency;
//   int? _selectedLocalBody;
//   int? _selectedWard;
  
//   // Available cities based on selected constituency
//   List<Map<String, dynamic>> _availableCities = [];
  
//   bool _isLoading = false;
//   bool _isInitialLoading = true;
//   String? _errorMessage;
  
//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//     _setInitialValues();
//     _loadInitialData();
//   }

//   void _initializeControllers() {
//     _firstNameController = TextEditingController(text: widget.contact.firstName);
//     _lastNameController = TextEditingController(text: widget.contact.lastName ?? '');
//     _emailController = TextEditingController(text: widget.contact.email ?? '');
//     _countryCodeController = TextEditingController(text: widget.contact.countryCode);
//     _phoneController = TextEditingController(text: widget.contact.phone);
//     _noteController = TextEditingController(text: widget.contact.note ?? '');
//     _addressController = TextEditingController(text: widget.contact.address ?? '');
//     _houseNumberController = TextEditingController();
//     _cityController = TextEditingController();
//     _postOfficeController = TextEditingController();
//     _pinCodeController = TextEditingController();
//   }

//   void _setInitialValues() {
//     _selectedCity = widget.contact.city != null ? int.tryParse(widget.contact.city!) : null;
//     _selectedConstituency = widget.contact.constituency != null ? int.tryParse(widget.contact.constituency!) : null;
//     _selectedReferredBy = widget.contact.referredBy != null && widget.contact.referredBy!['id'] != null 
//       ? int.tryParse(widget.contact.referredBy!['id'].toString()) 
//       : null;
//   }

//   @override
//   void dispose() {
//     _disposeControllers();
//     super.dispose();
//   }

//   void _disposeControllers() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     _countryCodeController.dispose();
//     _phoneController.dispose();
//     _noteController.dispose();
//     _addressController.dispose();
//     _houseNumberController.dispose();
//     _cityController.dispose();
//     _postOfficeController.dispose();
//     _pinCodeController.dispose();
//   }
  
//   Future<void> _loadInitialData() async {
//     setState(() {
//       _isInitialLoading = true;
//       _errorMessage = null;
//     });
    
//     try {
//       final data = await _service.loadInitialData();
      
//       setState(() {
//         _primaryContacts = data['primaryContacts'];
//         _constituencies = data['constituencies'];
//       });
      
//       if (_selectedConstituency != null) {
//         _updateAvailableCities();
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load initial data: ${e.toString()}';
//       });
//     } finally {
//       setState(() {
//         _isInitialLoading = false;
//       });
//     }
//   }

//   void _updateAvailableCities() {
//     if (_selectedConstituency != null) {
//       final constituency = _constituencies.firstWhere(
//         (c) => c['id'] == _selectedConstituency,
//         orElse: () => {'cities': []},
//       );
      
//       setState(() {
//         _availableCities = List<Map<String, dynamic>>.from(constituency['cities'] ?? []);
//       });
//     } else {
//       setState(() {
//         _availableCities = [];
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<void> _updateContact() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
    
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
    
//     try {
//       final Map<String, dynamic> contactData = {
//         'referred_by': _selectedReferredBy,
//         'first_name': _firstNameController.text,
//         'last_name': _lastNameController.text.isEmpty ? null : _lastNameController.text,
//         'email': _emailController.text.isEmpty ? null : _emailController.text,
//         'country_code': _countryCodeController.text,
//         'phone': _phoneController.text,
//         'note': _noteController.text.isEmpty ? null : _noteController.text,
//         'address': _addressController.text.isEmpty ? null : _addressController.text,
//         'city': _selectedCity,
//       };
      
//       final updatedContact = await _service.updateContact(
//         contactId: widget.contact.id,
//         contactData: contactData,
//         primaryContacts: _primaryContacts,
//         originalContact: widget.contact,
//       );
      
//       _showSnackBar('Contact updated successfully!', Colors.green);
//       Navigator.pop(context, updatedContact);
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString().replaceFirst('Exception: ', '');
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showSnackBar(String message, Color backgroundColor) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: backgroundColor,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: _buildAppBar(),
//       body: _isInitialLoading ? _buildInitialLoadingWidget() : _buildMainContent(),
//     );
//   }

//   AppBar _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
//         onPressed: () => Navigator.pop(context),
//       ),
//       title: const Text(
//         'Edit Contact',
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   Widget _buildInitialLoadingWidget() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text('Loading data...'),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainContent() {
//     return Stack(
//       children: [
//         SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Error message
//                   FormUtils.buildErrorMessage(_errorMessage),
                  
//                   // Personal Details Section
//                   PersonalDetailsWidget(
//                     firstNameController: _firstNameController,
//                     lastNameController: _lastNameController,
//                     emailController: _emailController,
//                     countryCodeController: _countryCodeController,
//                     phoneController: _phoneController,
//                     noteController: _noteController,
//                     showNotes: true,
//                     showSectionTitle: true,
//                     sectionTitle: 'Personal Details',
//                   ),
//                   const SizedBox(height: 32),

//                   // Other Details Section
//                   _buildOtherDetailsSection(),
//                   const SizedBox(height: 32),

//                   // Residential Details Section
//                   _buildResidentialDetailsSection(),
//                   const SizedBox(height: 32),

//                   // Referred By Section
//                   _buildReferredBySection(),
//                   const SizedBox(height: 32),

//                   // Save Button
//                   _buildSaveButton(),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         // Loading overlay
//         FormUtils.buildLoadingOverlay(
//           message: 'Updating contact...',
//           isVisible: _isLoading,
//         ),
//       ],
//     );
//   }

//   Widget _buildOtherDetailsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         FormUtils.buildSectionTitle('Other Details'),
//         const SizedBox(height: 16),

//         // District Dropdown
//         FormUtils.buildDropdownField<int?>(
//           value: _selectedConstituency,
//           labelText: 'District',
//           items: _constituencies.map((constituency) {
//             return DropdownMenuItem<int?>(
//               value: constituency['id'],
//               child: Text(constituency['name']),
//             );
//           }).toList(),
//           onChanged: (value) {
//             setState(() {
//               _selectedConstituency = value;
//               _updateAvailableCities();
//             });
//           },
//         ),
//         const SizedBox(height: 16),

//         // Assembly Constituency
//         FormUtils.buildDropdownField<int?>(
//           value: _selectedCity,
//           labelText: 'Assembly Constituency',
//           items: _availableCities.map((city) {
//             return DropdownMenuItem<int?>(
//               value: city['id'],
//               child: Text(city['name']),
//             );
//           }).toList(),
//           onChanged: _availableCities.isEmpty ? (value) {} : (value) {
//             setState(() {
//               _selectedCity = value;
//             });
//           },
//         ),
//         const SizedBox(height: 16),

//         // Party Block
//         FormUtils.buildDropdownField<int?>(
//           value: _selectedPartyBlock,
//           labelText: 'Party Block',
//           items: const [],
//           onChanged: (value) {
//             setState(() {
//               _selectedPartyBlock = value;
//             });
//           },
//         ),
//         const SizedBox(height: 16),

//         // Party Constituency
//         FormUtils.buildDropdownField<int?>(
//           value: _selectedPartyConstituency,
//           labelText: 'Party Constituency',
//           items: const [],
//           onChanged: (value) {
//             setState(() {
//               _selectedPartyConstituency = value;
//             });
//           },
//         ),
//         const SizedBox(height: 16),

//         // Booth
//         FormUtils.buildDropdownField<int?>(
//           value: _selectedBooth,
//           labelText: 'Booth',
//           items: const [],
//           onChanged: (value) {
//             setState(() {
//               _selectedBooth = value;
//             });
//           },
//         ),
//         const SizedBox(height: 16),

//         // Parliamentary Constituency
//         FormUtils.buildDropdownField<int?>(
//           value: _selectedParliamentaryConstituency,
//           labelText: 'Parliamentary Constituency',
//           items: const [],
//           onChanged: (value) {
//             setState(() {
//               _selectedParliamentaryConstituency = value;
//             });
//           },
//         ),
//         const SizedBox(height: 16),

//         // Local Body
//         FormUtils.buildDropdownField<int?>(
//           value: _selectedLocalBody,
//           labelText: 'Local Body',
//           items: const [],
//           onChanged: (value) {
//             setState(() {
//               _selectedLocalBody = value;
//             });
//           },
//         ),
//         const SizedBox(height: 16),

//         // Ward
//         FormUtils.buildDropdownField<int?>(
//           value: _selectedWard,
//           labelText: 'Ward',
//           items: const [],
//           onChanged: (value) {
//             setState(() {
//               _selectedWard = value;
//             });
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildResidentialDetailsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         FormUtils.buildSectionTitle('Residential Details'),
//         const SizedBox(height: 16),

//         // House Name
//         FormUtils.buildTextField(
//           controller: _addressController,
//           labelText: 'House Name',
//         ),
//         const SizedBox(height: 16),

//         // House Number
//         FormUtils.buildTextField(
//           controller: _houseNumberController,
//           labelText: 'House Number',
//         ),
//         const SizedBox(height: 16),

//         // City
//         FormUtils.buildTextField(
//           controller: _cityController,
//           labelText: 'City',
//         ),
//         const SizedBox(height: 16),

//         // Post Office
//         FormUtils.buildTextField(
//           controller: _postOfficeController,
//           labelText: 'Post Office',
//         ),
//         const SizedBox(height: 16),

//         // Pin Code
//         FormUtils.buildTextField(
//           controller: _pinCodeController,
//           labelText: 'Pin Code',
//           keyboardType: TextInputType.number,
//         ),
//       ],
//     );
//   }

//   Widget _buildReferredBySection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         FormUtils.buildSectionTitle('Referred By'),
//         const SizedBox(height: 16),

//         // Referred By Dropdown
//         FormUtils.buildDropdownField<int?>(
//           value: _selectedReferredBy,
//           labelText: 'Referred By',
//           items: [
//             const DropdownMenuItem<int?>(
//               value: null,
//               child: Text('None'),
//             ),
//             ..._primaryContacts.map((contact) => DropdownMenuItem<int?>(
//               value: contact['id'],
//               child: Text('${contact['name']} (${contact['phone']})'),
//             )),
//           ],
//           onChanged: (value) {
//             setState(() {
//               _selectedReferredBy = value;
//             });
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildSaveButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _updateContact,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF4285F4),
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(25),
//           ),
//           elevation: 0,
//         ),
//         child: _isLoading 
//           ? const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 color: Colors.white,
//                 strokeWidth: 2,
//               ),
//             )
//           : const Text(
//               'Save Changes',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//       ),
//     );
//   }
// }