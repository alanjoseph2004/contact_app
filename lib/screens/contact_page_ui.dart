import 'package:flutter/material.dart';
import 'contact_logic.dart';
import 'contact_page.dart';
import 'new_primary_contact.dart';
import 'new_all_contact.dart';
import 'detailed_contact.dart';
import 'new_bulk_contact.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  // Instance of the logic class
  final ContactsPageLogic _logic = ContactsPageLogic();
  
  // UI state variables
  late ContactType _selectedTab;
  late List<Contact> _contacts;
  late bool _isLoading;

  // Define consistent color scheme
  static const Color _primaryBlue = Color(0xFF4285F4);
  static const Color _textPrimary = Color(0xFF212121);
  static const Color _textSecondary = Color(0xFF757575);
  static const Color _textTertiary = Color(0xFF9E9E9E);
  static const Color _dividerColor = Color(0xFFE0E0E0);
  static const Color _backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _selectedTab = _logic.selectedTab;
    _contacts = _logic.contacts;
    _isLoading = _logic.isLoading;
    _loadContacts();
  }
  
  // Load contacts method in UI class that calls the logic class
  Future<void> _loadContacts() async {
    await _logic.loadContacts(
      context,
      (isLoading) => setState(() => _isLoading = isLoading),
      (contacts) => setState(() => _contacts = contacts)
    );
  }

  // Build individual contact list with proper structure
  Widget _buildContactsList(List<String> sortedKeys, Map<String, List<Contact>> groupedContacts) {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
          ),
        ),
      );
    }

    if (sortedKeys.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'No contacts found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: _textSecondary,
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          final key = sortedKeys[index];
          final contacts = groupedContacts[key]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  key,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ),
              ...contacts.map((contact) => _buildContactTile(contact)).toList(),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get grouped contacts and sorted keys from logic
    final groupedContacts = _logic.getGroupedContacts();
    final sortedKeys = _logic.getSortedKeys(groupedContacts);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabSelector(),
          _buildContactsList(sortedKeys, groupedContacts),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Build the app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryBlue,
      elevation: 0,
      title: const Text(
        'Contacts',
        style: TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Build the tab selector
  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _logic.setSelectedTab(
                  ContactType.primary,
                  (type) => setState(() => _selectedTab = type)
                );
                _loadContacts();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: _selectedTab == ContactType.primary
                      ? const Border(
                          bottom: BorderSide(
                            color: _primaryBlue,
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Primary',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: _selectedTab == ContactType.primary
                          ? _primaryBlue
                          : _textSecondary,
                      fontWeight: _selectedTab == ContactType.primary
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _logic.setSelectedTab(
                  ContactType.all,
                  (type) => setState(() => _selectedTab = type)
                );
                _loadContacts();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: _selectedTab == ContactType.all
                      ? const Border(
                          bottom: BorderSide(
                            color: _primaryBlue,
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    'All Contacts',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: _selectedTab == ContactType.all
                          ? _primaryBlue
                          : _textSecondary,
                      fontWeight: _selectedTab == ContactType.all
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build individual contact tile with responsive layout
  Widget _buildContactTile(Contact contact) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailedContactPage(contact: contact),
              ),
            ).then((_) {
              _loadContacts();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: _primaryBlue.withOpacity(0.1),
                  backgroundImage: contact.avatarUrl != null ? NetworkImage(contact.avatarUrl!) : null,
                  radius: 24,
                  child: contact.avatarUrl == null ? Text(
                    contact.name.isNotEmpty ? contact.name[0].toUpperCase() : "?",
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: _primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ) : null,
                ),
                
                const SizedBox(width: 16),
                
                // Contact details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: _textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.phoneNumber,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: _textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (_selectedTab == ContactType.all && contact.referredBy != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Referred by: ${contact.referredBy}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: _textTertiary,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          // Implement message functionality
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _primaryBlue, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.message,
                            color: _primaryBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Material(
                      color: _primaryBlue,
                      borderRadius: BorderRadius.circular(25),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          // Implement call functionality
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Divider line between contacts
        Container(
          margin: const EdgeInsets.only(left: 64),
          height: 1,
          decoration: const BoxDecoration(
            color: _dividerColor,
          ),
        ),
      ],
    );
  }

  // Build floating action button with improved dropdown
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        if (_selectedTab == ContactType.primary) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewPrimaryContactPage()),
          ).then((_) {
            _loadContacts();
          });
        } else {
          _showContactCreationOptions();
        }
      },
      backgroundColor: _primaryBlue,
      child: const Icon(Icons.person_add, color: Colors.white),
    );
  }

  void _showContactCreationOptions() {
    final RenderBox? overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    
    final position = RelativeRect.fromRect(
      Rect.fromLTRB(
        MediaQuery.of(context).size.width - 200,
        MediaQuery.of(context).size.height - 270,
        16,
        150,
      ),
      Offset.zero & (overlay?.size ?? Size.zero),
    );

    showMenu<String>(
      context: context,
      position: position,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.transparent,
      items: [
        PopupMenuItem<String>(
          padding: EdgeInsets.zero,
          value: 'single',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: _primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              title: Text(
                'Create Single Contact',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
            ),
          ),
        ),
        PopupMenuItem<String>(
          padding: EdgeInsets.zero,
          value: 'bulk',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: _primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 20),
              ),
              title: Text(
                'Create Bulk Contacts',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'single') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewAllContactPage()),
        ).then((_) {
          _loadContacts();
        });
      } else if (value == 'bulk') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BulkContactsUploadPage()),
        ).then((_) {
          _loadContacts();
        });
      }
    });
  }

  // Build a simplified bottom bar with only Contacts
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 61,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.contacts,
                    color: _primaryBlue,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Contacts',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: _primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}