import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'contact_logic.dart';
import 'edit_contact.dart';
import 'new_primary_contact.dart';
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
  ContactType _selectedTab = ContactType.primary;
  
  // List to store contacts
  List<Contact> _contacts = [];
  
  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }
  
  // Load contacts based on selected tab
  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });
    
    if (_selectedTab == ContactType.primary) {
      await _fetchPrimaryContactsFromAPI();
    } else if (_selectedTab == ContactType.all) {
      await _fetchAllContactsFromAPI();
    } else {
      final contacts = await ContactService.getContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    }
  }
  
  // Fetch primary contacts from API
  Future<void> _fetchPrimaryContactsFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('http://51.21.152.136:8000/contact/all-primary-contacts/'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        // Convert API response to Contact objects
        final List<Contact> apiContacts = results.map((contactData) {
          final contactObj = contactData['contact'];
          
          // Handle city properly - it's an object not a string
          String cityStr = '';
          if (contactObj['city'] != null && contactObj['city'] is Map) {
            cityStr = contactObj['city']['city'] ?? '';
          }
          
          // Handle tags properly - they're objects with tag_name property
          List<String> tagList = [];
          if (contactData['tags'] != null && contactData['tags'] is List) {
            tagList = (contactData['tags'] as List)
                .map((tag) => tag['tag_name']?.toString() ?? '')
                .toList();
          }
          
          // Handle connection properly - it's an object with connection property
          String connectionStr = '';
          if (contactData['connection'] != null && contactData['connection'] is Map) {
            connectionStr = contactData['connection']['connection'] ?? '';
          }
          
          return Contact(
            id: contactObj['id']?.toString() ?? '',
            firstName: contactObj['first_name'] ?? '',
            lastName: contactObj['last_name'],
            countryCode: contactObj['country_code'] ?? '',
            phone: contactObj['phone'] ?? '',
            email: contactObj['email'],
            type: ContactType.primary,
            priority: contactData['priority'],  // Already an integer in the JSON
            note: contactObj['note'],
            address: contactObj['address'],
            city: cityStr,  // Use the extracted city string
            constituency: contactObj['constituency'] ?? '',
            hasMessages: false,  // This field is not in your API response
            connection: connectionStr,  // Use the extracted connection string
            tags: tagList,  // Use the extracted tag list
            isPrimary: true, // It's a primary contact
          );
        }).toList();
        
        // Cache the API contacts to local storage
        await ContactService.cacheApiPrimaryContacts(apiContacts);
        
        setState(() {
          _contacts = apiContacts;
          _isLoading = false;
        });
      } else {
        // Handle error - Try to load from cache if API fails
        final cachedContacts = await ContactService.getPrimaryContactsFromStorage();
        setState(() {
          _contacts = cachedContacts;
          _isLoading = false;
        });
        
        if (cachedContacts.isEmpty) {
          _showErrorSnackBar('Failed to load primary contacts');
        } else {
          _showErrorSnackBar('Using cached contacts - API request failed');
        }
      }
    } catch (e) {
      print('Error fetching primary contacts: $e'); // Add detailed logging
      // Load from cache in case of error
      final cachedContacts = await ContactService.getPrimaryContactsFromStorage();
      setState(() {
        _contacts = cachedContacts;
        _isLoading = false;
      });
      
      if (cachedContacts.isEmpty) {
        _showErrorSnackBar('Error: ${e.toString()}');
      } else {
        _showErrorSnackBar('Using cached contacts - ${e.toString()}');
      }
    }
  }
  
  // Fetch all contacts from API
  Future<void> _fetchAllContactsFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('http://51.21.152.136:8000/contact/all-contacts/'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> contactsData = json.decode(response.body);
        
        // Convert API response to Contact objects
        final List<Contact> apiContacts = contactsData.map((contactData) {
          // Handle city properly - it's an object not a string
          String cityStr = '';
          if (contactData['city'] != null && contactData['city'] is Map) {
            cityStr = contactData['city']['city'] ?? '';
          }
          
          // Handle referred_by properly - it's an object with referred details
          Map<String, dynamic>? referredByMap;
          if (contactData['referred_by'] != null && contactData['referred_by'] is Map) {
            referredByMap = {
              'referred_id': contactData['referred_by']['referred_id']?.toString() ?? '',
              'referred_first_name': contactData['referred_by']['referred_first_name'] ?? '',
              'referred_last_name': contactData['referred_by']['referred_last_name'] ?? '',
              'referred_country_code': contactData['referred_by']['referred_country_code'] ?? '',
              'referred_phone': contactData['referred_by']['referred_phone'] ?? '',
            };
          }
          
          return Contact(
            id: contactData['id']?.toString() ?? '',
            firstName: contactData['first_name'] ?? '',
            lastName: contactData['last_name'],
            countryCode: contactData['country_code'] ?? '',
            phone: contactData['phone'] ?? '',
            email: contactData['email'],
            type: ContactType.all,
            note: contactData['note'],
            address: contactData['address'],
            city: cityStr,
            constituency: contactData['constituency'] ?? '',
            hasMessages: false, // This field is not in your API response
            referredBy: referredByMap,
            isPrimary: contactData['is_primary_contact'] ?? false,
          );
        }).toList();
        
        // Cache the API contacts to local storage
        await ContactService.cacheApiAllContacts(apiContacts);
        
        setState(() {
          _contacts = apiContacts;
          _isLoading = false;
        });
      } else {
        // Handle error - Try to load from cache if API fails
        final cachedContacts = await ContactService.getAllContactsFromStorage();
        setState(() {
          _contacts = cachedContacts;
          _isLoading = false;
        });
        
        if (cachedContacts.isEmpty) {
          _showErrorSnackBar('Failed to load all contacts');
        } else {
          _showErrorSnackBar('Using cached contacts - API request failed');
        }
      }
    } catch (e) {
      print('Error fetching all contacts: $e'); // Add detailed logging
      // Load from cache in case of error
      final cachedContacts = await ContactService.getAllContactsFromStorage();
      setState(() {
        _contacts = cachedContacts;
        _isLoading = false;
      });
      
      if (cachedContacts.isEmpty) {
        _showErrorSnackBar('Error: ${e.toString()}');
      } else {
        _showErrorSnackBar('Using cached contacts - ${e.toString()}');
      }
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group contacts by first letter
    Map<String, List<Contact>> groupedContacts = {};
    for (var contact in _contacts) {
      if (contact.name.isEmpty) continue;
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
          // Segmented control for Primary/All Contacts
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
                        _loadContacts(); // Reload contacts when tab changes
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
                        _loadContacts(); // Reload contacts when tab changes
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
        // Handle contact deletion based on type
        ContactService.deleteContact(contact.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${contact.name} deleted"))
        );
        // Refresh the list
        _loadContacts();
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
                        color: _getPriorityColor(contact.priority!),
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
          _showEditContactDialog(context, contact);
        },
      ),
    );
  }

  // Get color based on priority
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.green;
      case 5:
        return Colors.blue;
      default:
        return Colors.grey;
    }
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