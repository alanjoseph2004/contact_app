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
      backgroundColor: _logic.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {},
      ),
      title: const Text(
        'Contacts',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
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
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: const Border(
                    right: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                  color: _selectedTab == ContactType.primary 
                      ? _logic.primaryColor.withOpacity(0.1) 
                      : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    'Primary',
                    style: TextStyle(
                      color: _selectedTab == ContactType.primary 
                          ? _logic.primaryColor 
                          : Colors.grey,
                      fontWeight: FontWeight.w500,
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: _selectedTab == ContactType.all 
                    ? _logic.primaryColor.withOpacity(0.1) 
                    : Colors.transparent,
                child: Center(
                  child: Text(
                    'All Contacts',
                    style: TextStyle(
                      color: _selectedTab == ContactType.all
                          ? _logic.primaryColor 
                          : Colors.grey,
                      fontWeight: FontWeight.w500,
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

  // Build the contacts list
  Widget _buildContactsList(List<String> sortedKeys, Map<String, List<Contact>> groupedContacts) {
    return Expanded(
      child: _isLoading 
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_logic.primaryColor),
              ),
            )
          : sortedKeys.isEmpty 
              ? Center(
                  child: Text(
                    'No contacts in this category',
                    style: TextStyle(color: _logic.primaryColor.withOpacity(0.7)),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadContacts,
                  color: _logic.primaryColor,
                  child: ListView.builder(
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, index) {
                      final letter = sortedKeys[index];
                      final contactsInGroup = groupedContacts[letter] ?? [];
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                            child: Text(
                              letter,
                              style: TextStyle(
                                color: _logic.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ...contactsInGroup.map((contact) => _buildContactTile(contact)),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  // Build individual contact tile
  Widget _buildContactTile(Contact contact) {
    return Dismissible(
      key: Key(contact.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
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
        // Handle contact deletion based on type
        ContactService.deleteContact(contact.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${contact.name} deleted"))
        );
        // Refresh the list
        _loadContacts();
      },
      child: ListTile(
        leading: Hero(
          tag: 'contact_avatar_${contact.id}',
          child: CircleAvatar(
            backgroundColor: _logic.primaryColor.withOpacity(0.2),
            backgroundImage: contact.avatarUrl != null ? NetworkImage(contact.avatarUrl!) : null,
            radius: 24,
            child: contact.avatarUrl == null ? Text(
              contact.name.isNotEmpty ? contact.name[0].toUpperCase() : "?",
              style: TextStyle(color: _logic.primaryColor),
            ) : null,
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(contact.phoneNumber),
                if (_selectedTab == ContactType.primary && contact.priority != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _logic.getPriorityColor(contact.priority!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Priority ${contact.priority}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (_selectedTab == ContactType.all && contact.referredBy != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Referred by: ${contact.referredBy!['referred_first_name']} ${contact.referredBy!['referred_last_name'] ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.message,
                color: Colors.grey,
              ),
              onPressed: () {
                // Implement message functionality
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.phone,
                color: Colors.grey,
              ),
              onPressed: () {
                // Implement call functionality
              },
            ),
          ],
        ),
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
      ),
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
      backgroundColor: _logic.primaryColor,
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
  showMenu(
    context: context,
    position: position,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    color: Colors.transparent, // Transparent background
    items: [
      PopupMenuItem(
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
                color: _logic.primaryColor, // Use your blue theme color
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
      PopupMenuItem(
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
                color: _logic.primaryColor, // Use your blue theme color
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

  // Build bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: _logic.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Recents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
        ],
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}