import 'package:flutter/material.dart';
import 'contact_logic.dart';
// import 'edit_contact_primary.dart';
// import 'edit_all_contact.dart';
// import 'edit_primary_contact.dart';

class DetailedContactPage extends StatefulWidget {
  final Contact contact;

  const DetailedContactPage({
    super.key,
    required this.contact,
  });

  @override
  State<DetailedContactPage> createState() => _DetailedContactPageState();
}

class _DetailedContactPageState extends State<DetailedContactPage> {
  late Contact _contact;
  
  // Updated to match contacts page color scheme
  static const Color _primaryBlue = Color(0xFF4285F4);
  static const Color _textPrimary = Color(0xFF212121);
  static const Color _textSecondary = Color(0xFF757575);
  static const Color _textTertiary = Color(0xFF9E9E9E);
  static const Color _dividerColor = Color(0xFFE0E0E0);
  static const Color _backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textPrimary, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _contact.name,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
        // actions: [
        //   Container(
        //     margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
        //     child: Material(
        //       color: _primaryBlue,
        //       borderRadius: BorderRadius.circular(16),
        //       child: InkWell(
        //         borderRadius: BorderRadius.circular(16),
        //         onTap: () => _navigateToEditContact(),
        //         child: Container(
        //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //           child: Row(
        //             mainAxisSize: MainAxisSize.min,
        //             children: [
        //               const Icon(
        //                 Icons.edit,
        //                 color: Colors.white,
        //                 size: 16,
        //               ),
        //               const SizedBox(width: 4),
        //               const Text(
        //                 'Edit',
        //                 style: TextStyle(
        //                   color: Colors.white,
        //                   fontSize: 14,
        //                   fontWeight: FontWeight.w500,
        //                   fontFamily: 'Inter',
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Merged profile header with quick actions
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile section
                  Row(
                    children: [
                      // Avatar - updated to match contacts page style
                      CircleAvatar(
                        backgroundColor: _primaryBlue.withOpacity(0.1),
                        backgroundImage: _contact.avatarUrl != null ? NetworkImage(_contact.avatarUrl!) : null,
                        radius: 32,
                        child: _contact.avatarUrl == null ? Text(
                          _contact.name.isNotEmpty ? _contact.name[0].toUpperCase() : "?",
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: _primaryBlue,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ) : null,
                      ),
                      const SizedBox(width: 16),
                      // Contact info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _contact.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 16, color: _textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  _contact.phoneNumber,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: _textSecondary,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (_contact.email != null && _contact.email!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.email, size: 16, color: _textSecondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    _contact.email!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: _textSecondary,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      // Priority number (replacing star) - Fixed property name
                      if (_contact.isPrimaryContact && _contact.priority != null)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: _primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${_contact.priority}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Divider - updated color
                  Container(
                    height: 1,
                    color: _dividerColor,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quick action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(Icons.phone, 'Call', () {
                        // Implement call functionality
                      }, isOutlined: false),
                      _buildActionButton(Icons.message, 'Message', () {
                        // Implement message functionality
                      }, isOutlined: true),
                      _buildActionButton(Icons.share, 'Share', () {
                        // Implement share functionality
                      }, isOutlined: true),
                    ],
                  ),
                ],
              ),
            ),

            // Contact Details Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Address information - Using fullAddress property
                  if (_contact.fullAddress.isNotEmpty)
                    _buildDetailRow('Address', _contact.fullAddress),
                  
                  // City information
                  if (_contact.city != null && _contact.city!.isNotEmpty)
                    _buildDetailRow('City', _contact.city!),
                  
                  // District information - Using correct property name
                  if (_contact.district != null)
                    _buildDetailRow('District', 'District ID: ${_contact.district}'),
                  
                  // Assembly Constituency information - Using correct property name
                  if (_contact.assemblyConstituency != null)
                    _buildDetailRow('Assembly Constituency', 'AC ID: ${_contact.assemblyConstituency}'),
                  
                  // Parliamentary Constituency information
                  if (_contact.parliamentaryConstituency != null)
                    _buildDetailRow('Parliamentary Constituency', 'PC ID: ${_contact.parliamentaryConstituency}'),
                  
                  // Local Body information
                  if (_contact.localBody != null)
                    _buildDetailRow('Local Body', 'LB ID: ${_contact.localBody}'),
                  
                  // Ward information
                  if (_contact.ward != null)
                    _buildDetailRow('Ward', 'Ward: ${_contact.ward}'),
                  
                  // Booth information
                  if (_contact.booth != null)
                    _buildDetailRow('Booth', 'Booth: ${_contact.booth}'),
                  
                  // Post Office information
                  if (_contact.postOffice != null && _contact.postOffice!.isNotEmpty)
                    _buildDetailRow('Post Office', _contact.postOffice!),
                  
                  // PIN Code information
                  if (_contact.pinCode != null && _contact.pinCode!.isNotEmpty)
                    _buildDetailRow('PIN Code', _contact.pinCode!),
                ],
              ),
            ),

            // Additional Information
            if (_contact.type == ContactType.primary) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Primary Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Party information
                    if (_contact.partyBlock != null)
                      _buildDetailRow('Party Block', 'PB ID: ${_contact.partyBlock}'),
                    
                    if (_contact.partyConstituency != null)
                      _buildDetailRow('Party Constituency', 'PC ID: ${_contact.partyConstituency}'),
                    
                    // Connection information
                    if (_contact.connection != null && _contact.connection!.isNotEmpty)
                      _buildDetailRow('Connection', _contact.connection!),
                    
                    // Tags as chips - Using List<int> instead of List<String>
                    if (_contact.tags != null && _contact.tags!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Tags:',
                        style: TextStyle(
                          fontSize: 15,
                          color: _textSecondary,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _contact.tags!.map((tagId) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _primaryBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Tag $tagId', // Since tags are IDs, display as "Tag ID"
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Referral Information (for All Contacts) - Fixed property access
            if (_contact.type == ContactType.all && _contact.referredBy != null) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Referral Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Updated to use correct property - referredBy is an int, not a Map
                    _buildDetailRow('Referred by ID', _contact.referredBy.toString()),
                    
                    // If you have referralDetails, use that instead
                    if (_contact.referralDetails != null) ...[
                      if (_contact.referralDetails!['referred_first_name'] != null)
                        _buildDetailRow('Referred by Name', 
                          '${_contact.referralDetails!['referred_first_name']} ${_contact.referralDetails!['referred_last_name'] ?? ''}'),
                      if (_contact.referralDetails!['referred_phone'] != null)
                        _buildDetailRow('Referral Phone', 
                          '${_contact.referralDetails!['referred_country_code'] ?? ''} ${_contact.referralDetails!['referred_phone'] ?? ''}'),
                    ],
                  ],
                ),
              ),
            ],

            // Notes Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _contact.note ?? 'No notes available.',
                    style: TextStyle(
                      fontSize: 15,
                      color: _contact.note == null ? _textTertiary : _textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {bool isOutlined = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : _primaryBlue,
          borderRadius: BorderRadius.circular(24),
          border: isOutlined ? Border.all(color: _primaryBlue, width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isOutlined ? _primaryBlue : Colors.white, 
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isOutlined ? _primaryBlue : Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: _textSecondary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: _textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

//   void _navigateToEditContact() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => _contact.type == ContactType.primary 
//             ? EditPrimaryContactScreen(contact: _contact)
//             : EditAllContactScreen(contact: _contact),
//       ),
//     );

//     // If contact was edited successfully, update the UI
//     if (result != null && result is Contact) {
//       setState(() {
//         _contact = result;
//       });
//     }
//   }
// }

// // Create a separate EditContactScreen for full screen editing
// class EditContactScreen extends StatelessWidget {
//   final Contact contact;

//   const EditContactScreen({
//     super.key,
//     required this.contact,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF4285F4), // Updated to match primary blue
//         title: const Text(
//           'Edit Contact',
//           style: TextStyle(
//             color: Colors.white,
//             fontFamily: 'Inter',
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: EditContactDialog(
//         contact: contact,
//         primaryColor: const Color(0xFF4285F4), // Updated to match primary blue
//         isFullScreen: true,
//       ),
//     );
//   }
// }
}