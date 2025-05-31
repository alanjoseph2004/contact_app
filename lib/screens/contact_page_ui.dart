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
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (sortedKeys.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No contacts found',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF757575),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
      backgroundColor: Colors.white,
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
      backgroundColor: const Color(0xFF2196F3), // Material Blue to match tabs
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: const Text(
        'Contacts',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white, size: 22),
          onPressed: () {
            // Navigate to search page
            // Navigator.push(context, MaterialPageRoute(builder: (context) => ContactSearchPage()));
          },
        ),
      ],
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
                            color: Color(0xFF2196F3), // Blue color from screenshot
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Primary',
                    style: TextStyle(
                      color: _selectedTab == ContactType.primary
                          ? const Color(0xFF2196F3) // Blue for active tab
                          : const Color(0xFF757575), // Medium grey for inactive
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
                            color: Color(0xFF2196F3), // Blue color from screenshot
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    'All Contacts',
                    style: TextStyle(
                      color: _selectedTab == ContactType.all
                          ? const Color(0xFF2196F3) // Blue for active tab
                          : const Color(0xFF757575), // Medium grey for inactive
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
        Dismissible(
          key: Key(contact.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Delete Contact"),
                  content: Text("Are you sure you want to delete ${contact.name}?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("CANCEL"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("DELETE"),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            // Assuming ContactService is properly imported and available
            ContactService.deleteContact(contact.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${contact.name} deleted"))
            );
            _loadContacts();
          },
          child: InkWell(
            onTap: () {
              // Navigate to the detailed contact page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailedContactPage(contact: contact),
                ),
              ).then((_) {
                // Reload contacts when returning from the detailed contact page
                _loadContacts();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
                    backgroundImage: contact.avatarUrl != null ? NetworkImage(contact.avatarUrl!) : null,
                    radius: 24,
                    child: contact.avatarUrl == null ? Text(
                      contact.name.isNotEmpty ? contact.name[0].toUpperCase() : "?",
                      style: const TextStyle(
                        color: Color(0xFF2196F3),
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
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF212121),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contact.phoneNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        if (_selectedTab == ContactType.all && contact.referredBy != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Referred by: ${contact.referredBy!['referred_first_name']} ${contact.referredBy!['referred_last_name'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E),
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
                              border: Border.all(color: const Color(0xFF2196F3), width: 1.5),
                            ),
                            child: const Icon(
                              Icons.message,
                              color: Color(0xFF2196F3),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Material(
                        color: const Color(0xFF2196F3),
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
        ),
        // Divider line between contacts
        Container(
          margin: const EdgeInsets.only(left: 64),
          height: 1,
          decoration: const BoxDecoration(
            color: Color(0xFFE0E0E0),
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
          // For primary contacts tab, directly navigate to new primary contact page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewPrimaryContactPage()),
          ).then((_) {
            // Reload contacts when returning from the new contact page
            _loadContacts();
          });
        } else {
          // For all contacts tab, show a popup menu with Google Notes style
          _showContactCreationOptions();
        }
      },
      backgroundColor: Color(0xFF2196F3),
      child: const Icon(Icons.person_add, color: Colors.white),
    );
  }

  void _showContactCreationOptions() {
    // Calculate position to show menu above the FAB
    final RenderBox? overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    
    // Position the menu further above the FAB
    final position = RelativeRect.fromRect(
      Rect.fromLTRB(
        MediaQuery.of(context).size.width - 200, // Left position
        MediaQuery.of(context).size.height - 270, // Top position (moved higher above FAB)
        16, // Right padding
        150,  // Bottom padding (increased to move options up)
      ),
      Offset.zero & (overlay?.size ?? Size.zero),
    );

    // Show the popup menu with transparent background
    showMenu<String>(
      context: context,
      position: position,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.transparent, // Transparent background
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
                decoration: BoxDecoration(
                  color: Color(0xFF2196F3), // Use your blue theme color
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              title: const Text(
                'Create Single Contact',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
                decoration: BoxDecoration(
                  color: Color(0xFF2196F3), // Use your blue theme color
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 20),
              ),
              title: const Text(
                'Create Bulk Contacts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
      // Using a simple Container instead of BottomNavigationBar
      child: SafeArea(
        child: Container(
          height: 61, // Standard navigation bar height
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.contacts,
                    color: Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Contacts',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
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