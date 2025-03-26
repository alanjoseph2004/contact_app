import 'package:flutter/material.dart';
import 'contact_logic.dart';
import 'new_contact.dart';
import 'edit_contact.dart';
import 'new_primary_contact.dart';  // New import for primary contacts
import 'new_all_contact.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  // Primary theme color
  final Color primaryColor = const Color(0xFF283593);
  
  // Selected tab
  ContactType _selectedTab = ContactType.all;
  
  // List to store contacts
  List<Contact> _contacts = [];
  
  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }
  
  // Load contacts from service
  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });
    
    final contacts = await ContactService.getContacts();
    
    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter contacts based on selected tab
    List<Contact> filteredContacts = _contacts.where((contact) {
      return contact.type == _selectedTab || contact.type == ContactType.both;
    }).toList();

    // Group contacts by first letter
    Map<String, List<Contact>> groupedContacts = {};
    for (var contact in filteredContacts) {
      final firstLetter = contact.name[0].toUpperCase();
      if (!groupedContacts.containsKey(firstLetter)) {
        groupedContacts[firstLetter] = [];
      }
      groupedContacts[firstLetter]?.add(contact);
    }

    // Sort the keys alphabetically
    final sortedKeys = groupedContacts.keys.toList()..sort();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
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
      ),
      body: Column(
        children: [
          // Segmented control for Office/Personal
          Container(
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
                      setState(() {
                        _selectedTab = ContactType.primary;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: const Border(
                          right: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        color: _selectedTab == ContactType.primary 
                            ? primaryColor.withOpacity(0.1) 
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          'Primary',
                          style: TextStyle(
                            color: _selectedTab == ContactType.primary 
                                ? primaryColor 
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
                      setState(() {
                        _selectedTab = ContactType.all;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: _selectedTab == ContactType.all 
                          ? primaryColor.withOpacity(0.1) 
                          : Colors.transparent,
                      child: Center(
                        child: Text(
                          'All Contacts',
                          style: TextStyle(
                            color: _selectedTab == ContactType.all
                                ? primaryColor 
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
          ),
          
          // Contact list
          Expanded(
            child: _isLoading 
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                : sortedKeys.isEmpty 
                    ? Center(
                        child: Text(
                          'No contacts in this category',
                          style: TextStyle(color: primaryColor.withOpacity(0.7)),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadContacts,
                        color: primaryColor,
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
                                      color: primaryColor,
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: () {
        // Route to different new contact pages based on selected tab
        Widget newContactPage;
        if (_selectedTab == ContactType.primary) {
          newContactPage = const NewPrimaryContactPage();
        } else {
          newContactPage = const NewAllContactPage();
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => newContactPage),
        ).then((_) {
          // Reload contacts when returning from the new contact page
          _loadContacts();
        });
      },
      backgroundColor: primaryColor,
      child: const Icon(Icons.person_add, color: Colors.white),
    ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
        currentIndex: 2,
      ),
    );
  }

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
        ContactService.deleteContact(contact.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${contact.name} deleted"))
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.2),
          backgroundImage: contact.avatarUrl != null ? NetworkImage(contact.avatarUrl!) : null,
          radius: 24,
          child: contact.avatarUrl == null ? Text(
            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : "?",
            style: TextStyle(color: primaryColor),
          ) : null,
        ),
        title: Text(
          contact.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(contact.phoneNumber),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.message,
                color: Colors.grey,
              ),
              onPressed: () {
                // Implement message functionality
                // For example, navigate to a message screen or open messaging app
                // _openMessageScreen(contact);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.phone,
                color: Colors.grey,
              ),
              onPressed: () {
                // Implement call functionality
                // launchUrl(Uri.parse('tel:${contact.phoneNumber}'));
              },
            ),
          ],
        ),
        onTap: () {
          _showEditContactDialog(context, contact);
        },
      ),
    );
  }

  void _showEditContactDialog(BuildContext context, Contact contact) async {
    final result = await showDialog(
      context: context,
      builder: (context) => EditContactDialog(
        contact: contact, 
        primaryColor: primaryColor
      ),
    );

    // If a contact was updated, reload the contacts
    if (result != null) {
      await _loadContacts();
    }
  }
}