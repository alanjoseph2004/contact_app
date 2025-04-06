import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'contact_logic.dart';

class ContactsPageLogic {
  // Primary theme color
  final Color primaryColor = const Color(0xFF283593);
  
  // List to store contacts
  List<Contact> contacts = [];
  
  // Loading state
  bool isLoading = true;
  
  // Current selected tab
  ContactType selectedTab = ContactType.primary;

  // Function to update loading state with a callback to update UI
  void setLoading(bool loading, Function(bool) updateState) {
    isLoading = loading;
    updateState(loading);
  }
  
  // Set selected tab with a callback to update UI
  void setSelectedTab(ContactType type, Function(ContactType) updateState) {
    selectedTab = type;
    updateState(type);
  }
  
  // Set contact list with a callback to update UI
  void setContacts(List<Contact> newContacts, Function(List<Contact>) updateState) {
    contacts = newContacts;
    updateState(newContacts);
  }
  
  // Load contacts based on selected tab
  Future<void> loadContacts(BuildContext context, Function(bool) updateLoadingState, Function(List<Contact>) updateContactsState) async {
    setLoading(true, updateLoadingState);
    
    if (selectedTab == ContactType.primary) {
      await fetchPrimaryContactsFromAPI(context, updateLoadingState, updateContactsState);
    } else if (selectedTab == ContactType.all) {
      await fetchAllContactsFromAPI(context, updateLoadingState, updateContactsState);
    } else {
      final contactsList = await ContactService.getContacts();
      setContacts(contactsList, updateContactsState);
      setLoading(false, updateLoadingState);
    }
  }
  
  // Fetch primary contacts from API
  Future<void> fetchPrimaryContactsFromAPI(BuildContext context, Function(bool) updateLoadingState, Function(List<Contact>) updateContactsState) async {
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
        
        setContacts(apiContacts, updateContactsState);
        setLoading(false, updateLoadingState);
      } else {
        // Handle error - Try to load from cache if API fails
        final cachedContacts = await ContactService.getPrimaryContactsFromStorage();
        setContacts(cachedContacts, updateContactsState);
        setLoading(false, updateLoadingState);
        
        if (cachedContacts.isEmpty) {
          showErrorSnackBar(context, 'Failed to load primary contacts');
        } else {
          showErrorSnackBar(context, 'Using cached contacts - API request failed');
        }
      }
    } catch (e) {
      print('Error fetching primary contacts: $e'); // Add detailed logging
      // Load from cache in case of error
      final cachedContacts = await ContactService.getPrimaryContactsFromStorage();
      setContacts(cachedContacts, updateContactsState);
      setLoading(false, updateLoadingState);
      
      if (cachedContacts.isEmpty) {
        showErrorSnackBar(context, 'Error: ${e.toString()}');
      } else {
        showErrorSnackBar(context, 'Using cached contacts - ${e.toString()}');
      }
    }
  }
  
  // Fetch all contacts from API
  Future<void> fetchAllContactsFromAPI(BuildContext context, Function(bool) updateLoadingState, Function(List<Contact>) updateContactsState) async {
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
        
        setContacts(apiContacts, updateContactsState);
        setLoading(false, updateLoadingState);
      } else {
        // Handle error - Try to load from cache if API fails
        final cachedContacts = await ContactService.getAllContactsFromStorage();
        setContacts(cachedContacts, updateContactsState);
        setLoading(false, updateLoadingState);
        
        if (cachedContacts.isEmpty) {
          showErrorSnackBar(context, 'Failed to load all contacts');
        } else {
          showErrorSnackBar(context, 'Using cached contacts - API request failed');
        }
      }
    } catch (e) {
      print('Error fetching all contacts: $e'); // Add detailed logging
      // Load from cache in case of error
      final cachedContacts = await ContactService.getAllContactsFromStorage();
      setContacts(cachedContacts, updateContactsState);
      setLoading(false, updateLoadingState);
      
      if (cachedContacts.isEmpty) {
        showErrorSnackBar(context, 'Error: ${e.toString()}');
      } else {
        showErrorSnackBar(context, 'Using cached contacts - ${e.toString()}');
      }
    }
  }
  
  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }
  
  // Get color based on priority
  Color getPriorityColor(int priority) {
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
  
  // Group contacts by first letter
  Map<String, List<Contact>> getGroupedContacts() {
    Map<String, List<Contact>> groupedContacts = {};
    for (var contact in contacts) {
      if (contact.name.isEmpty) continue;
      final firstLetter = contact.name[0].toUpperCase();
      if (!groupedContacts.containsKey(firstLetter)) {
        groupedContacts[firstLetter] = [];
      }
      groupedContacts[firstLetter]?.add(contact);
    }
    return groupedContacts;
  }
  
  // Get sorted keys for grouped contacts
  List<String> getSortedKeys(Map<String, List<Contact>> groupedContacts) {
    final sortedKeys = groupedContacts.keys.toList()..sort();
    return sortedKeys;
  }
}