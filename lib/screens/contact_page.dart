import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'contact_logic.dart';
import 'dart:math';

class ContactsPageLogic {
  // Primary theme color
  final Color primaryColor = const Color(0xFF283593);
  
  // List to store contacts
  List<Contact> contacts = [];
  
  // Loading state
  bool isLoading = true;
  
  // Current selected tab
  ContactType selectedTab = ContactType.primary;

  // Timestamp keys for last successful API calls
  static const String _lastPrimaryFetchKey = 'last_primary_fetch_timestamp';
  static const String _lastAllFetchKey = 'last_all_fetch_timestamp';
  static const String _hasInitialDataKey = 'has_initial_contact_data';

  // API endpoints
  static const String _apiBaseUrl = 'http://51.21.152.136:8000';
  static const String _allContactsEndpoint = '$_apiBaseUrl/contact/all-contacts/';
  static const String _primaryContactsEndpoint = '$_apiBaseUrl/contact/all-primary-contacts/';
  static const String _timedAllContactsEndpoint = '$_apiBaseUrl/contact/contacts/timed-retrieval/';
  static const String _timedPrimaryContactsEndpoint = '$_apiBaseUrl/contact/primary-contacts/timed-retrieval/';

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
    
    // Check if we already have initial data
    bool hasInitialData = await _hasInitialData();
    
    if (selectedTab == ContactType.primary) {
      if (!hasInitialData) {
        // First time fetch all primary contacts
        await fetchPrimaryContactsFromAPI(context, updateLoadingState, updateContactsState);
        await _setHasInitialData(true);
      } else {
        // Subsequent calls use timed retrieval
        await fetchUpdatedPrimaryContacts(context, updateLoadingState, updateContactsState);
      }
    } else if (selectedTab == ContactType.all) {
      if (!hasInitialData) {
        // First time fetch all contacts
        await fetchAllContactsFromAPI(context, updateLoadingState, updateContactsState);
        await _setHasInitialData(true);
      } else {
        // Subsequent calls use timed retrieval
        await fetchUpdatedAllContacts(context, updateLoadingState, updateContactsState);
      }
    } else {
      final contactsList = await ContactService.getContacts();
      setContacts(contactsList, updateContactsState);
      setLoading(false, updateLoadingState);
    }
  }

  // Check if we've already loaded initial data
  Future<bool> _hasInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasInitialDataKey) ?? false;
  }

  // Set initial data flag
  Future<void> _setHasInitialData(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasInitialDataKey, value);
  }
  
  // Fetch primary contacts from API - called only once initially
  Future<void> fetchPrimaryContactsFromAPI(BuildContext context, Function(bool) updateLoadingState, Function(List<Contact>) updateContactsState) async {
    try {
      final response = await http.get(
        Uri.parse(_primaryContactsEndpoint),
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
        await ContactService.savePrimaryContacts(apiContacts);
        
        // Save current timestamp for future timed retrieval
        await _saveLastFetchTimestamp(ContactType.primary);
        
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
  
  // Fetch updated primary contacts using timed retrieval
  Future<void> fetchUpdatedPrimaryContacts(BuildContext context, Function(bool) updateLoadingState, 
    Function(List<Contact>) updateContactsState) async {
  try {
    // Get last fetch timestamp
    String? lastFetchTime = await _getLastFetchTimestamp(ContactType.primary);
    
    if (lastFetchTime == null) {
      // If no timestamp, fetch all primary contacts instead
      return fetchPrimaryContactsFromAPI(context, updateLoadingState, updateContactsState);
    }
    
    // Load cached contacts first
    final cachedContacts = await ContactService.getPrimaryContactsFromStorage();
    setContacts(cachedContacts, updateContactsState);
    
    // Encode the timestamp for URL safety
    final encodedTimestamp = Uri.encodeComponent(lastFetchTime);
    
    // Fetch only updates with GET request using the correct parameter name 'datetime'
    final response = await http.get(
      Uri.parse('$_timedPrimaryContactsEndpoint?datetime=$encodedTimestamp'),
    );
    
    print('Timed retrieval response status: ${response.statusCode}');
    print('Timed retrieval response body: ${response.body.substring(0, min(200, response.body.length))}...');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Check if results is actually in the response
      if (!data.containsKey('results')) {
        print('Response is missing expected "results" key: $data');
        setLoading(false, updateLoadingState);
        return;
      }
      
      final List<dynamic> results = data['results'] ?? [];
      
      if (results.isEmpty) {
        // No updates, just use cached data
        print('No updated contacts found');
        setLoading(false, updateLoadingState);
        return;
      }
      
      print('Found ${results.length} updated contacts');
      
      // Convert API response to Contact objects - with extra error checking
      final List<Contact> updatedContacts = [];
      
      for (var contactData in results) {
        try {
          final contactObj = contactData['contact'];
          if (contactObj == null) {
            print('Missing contact object in: $contactData');
            continue;
          }
          
          // Handle city properly
          String cityStr = '';
          if (contactObj['city'] != null && contactObj['city'] is Map) {
            cityStr = contactObj['city']['city'] ?? '';
          }
          
          // Handle tags properly
          List<String> tagList = [];
          if (contactData['tags'] != null && contactData['tags'] is List) {
            tagList = (contactData['tags'] as List)
                .map((tag) => tag['tag_name']?.toString() ?? '')
                .toList();
          }
          
          // Handle connection properly
          String connectionStr = '';
          if (contactData['connection'] != null && contactData['connection'] is Map) {
            connectionStr = contactData['connection']['connection'] ?? '';
          }
          
          final contact = Contact(
            id: contactObj['id']?.toString() ?? '',
            firstName: contactObj['first_name'] ?? '',
            lastName: contactObj['last_name'],
            countryCode: contactObj['country_code'] ?? '',
            phone: contactObj['phone'] ?? '',
            email: contactObj['email'],
            type: ContactType.primary,
            priority: contactData['priority'],
            note: contactObj['note'],
            address: contactObj['address'],
            city: cityStr,
            constituency: contactObj['constituency'] ?? '',
            hasMessages: false,
            connection: connectionStr,
            tags: tagList,
            isPrimary: true,
          );
          
          updatedContacts.add(contact);
        } catch (e) {
          print('Error processing contact: $e for data: $contactData');
          // Continue processing other contacts
        }
      }
      
      // Create a map from cached contacts for easy lookup
      Map<String, Contact> contactMap = {
        for (var contact in cachedContacts) contact.id: contact
      };
      
      // Update or add new contacts
      for (var contact in updatedContacts) {
        contactMap[contact.id] = contact;
      }
      
      // Convert back to list
      final mergedContacts = contactMap.values.toList();
      
      // Update cache and state
      await ContactService.savePrimaryContacts(mergedContacts);
      
      // Save new timestamp
      await _saveLastFetchTimestamp(ContactType.primary);
      
      setContacts(mergedContacts, updateContactsState);
      setLoading(false, updateLoadingState);
    } else {
      print('Failed to retrieve updates: ${response.statusCode} - ${response.body.substring(0, min(100, response.body.length))}');
      // Already showing cached contacts, just update loading state
      setLoading(false, updateLoadingState);
      showErrorSnackBar(context, 'Failed to retrieve contact updates (Status: ${response.statusCode})');
    }
  } catch (e) {
    print('Error fetching updated primary contacts: $e');
    // Already showing cached contacts, just update loading state
    setLoading(false, updateLoadingState);
    showErrorSnackBar(context, 'Error getting updates: ${e.toString()}');
  }
}
  
  // Fetch all contacts from API - called only once initially
  Future<void> fetchAllContactsFromAPI(BuildContext context, Function(bool) updateLoadingState, Function(List<Contact>) updateContactsState) async {
    try {
      final response = await http.get(
        Uri.parse(_allContactsEndpoint),
      );
      
      if (response.statusCode == 200) {
        // Parse the response as a Map first
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Extract the contacts array from the 'results' field
        final List<dynamic> contactsData = responseData['results'] ?? [];
        
        // Convert API response to Contact objects
        final List<Contact> apiContacts = contactsData.map<Contact>((contactData) {
          // Handle city properly - it's an object not a string
          String cityStr = '';
          if (contactData['city'] != null && contactData['city'] is Map) {
            cityStr = contactData['city']['city'] ?? '';
          }
          
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
        await ContactService.saveAllContacts(apiContacts);
        
        // Save current timestamp for future timed retrieval
        await _saveLastFetchTimestamp(ContactType.all);
        
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

  // Fetch updated all contacts using timed retrieval
  Future<void> fetchUpdatedAllContacts(BuildContext context, Function(bool) updateLoadingState, 
    Function(List<Contact>) updateContactsState) async {
  try {
    // Get last fetch timestamp
    String? lastFetchTime = await _getLastFetchTimestamp(ContactType.all);
    
    if (lastFetchTime == null) {
      // If no timestamp, fetch all contacts instead
      return fetchAllContactsFromAPI(context, updateLoadingState, updateContactsState);
    }
    
    // Load cached contacts first
    final cachedContacts = await ContactService.getAllContactsFromStorage();
    setContacts(cachedContacts, updateContactsState);
    
    // Encode the timestamp for URL safety
    final encodedTimestamp = Uri.encodeComponent(lastFetchTime);
    
    // Fetch only updates with GET request using the correct parameter name 'datetime'
    final response = await http.get(
      Uri.parse('$_timedAllContactsEndpoint?datetime=$encodedTimestamp'),
    );
    
    print('Timed retrieval (all contacts) response status: ${response.statusCode}');
    print('Timed retrieval (all contacts) response body: ${response.body.substring(0, min(200, response.body.length))}...');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Check if results is actually in the response
      if (!data.containsKey('results')) {
        print('Response is missing expected "results" key: $data');
        setLoading(false, updateLoadingState);
        return;
      }
      
      final List<dynamic> results = data['results'] ?? [];
      
      if (results.isEmpty) {
        // No updates, just use cached data
        print('No updated contacts found');
        setLoading(false, updateLoadingState);
        return;
      }
      
      print('Found ${results.length} updated contacts');
      
      // Convert API response to Contact objects - with extra error checking
      final List<Contact> updatedContacts = [];
      
      for (var contactData in results) {
        try {
          // Handle city properly
          String cityStr = '';
          if (contactData['city'] != null && contactData['city'] is Map) {
            cityStr = contactData['city']['city'] ?? '';
          }
          
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
          
          final contact = Contact(
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
            hasMessages: false,
            referredBy: referredByMap,
            isPrimary: contactData['is_primary_contact'] ?? false,
          );
          
          updatedContacts.add(contact);
        } catch (e) {
          print('Error processing contact: $e for data: $contactData');
          // Continue processing other contacts
        }
      }
      
      // Create a map from cached contacts for easy lookup
      Map<String, Contact> contactMap = {
        for (var contact in cachedContacts) contact.id: contact
      };
      
      // Update or add new contacts
      for (var contact in updatedContacts) {
        contactMap[contact.id] = contact;
      }
      
      // Convert back to list
      final mergedContacts = contactMap.values.toList();
      
      // Update cache and state
      await ContactService.saveAllContacts(mergedContacts);
      
      // Save new timestamp
      await _saveLastFetchTimestamp(ContactType.all);
      
      setContacts(mergedContacts, updateContactsState);
      setLoading(false, updateLoadingState);
    } else {
      print('Failed to retrieve updates: ${response.statusCode} - ${response.body.substring(0, min(100, response.body.length))}');
      // Already showing cached contacts, just update loading state
      setLoading(false, updateLoadingState);
      showErrorSnackBar(context, 'Failed to retrieve contact updates (Status: ${response.statusCode})');
    }
  } catch (e) {
    print('Error fetching updated all contacts: $e');
    // Already showing cached contacts, just update loading state
    setLoading(false, updateLoadingState);
    showErrorSnackBar(context, 'Error getting updates: ${e.toString()}');
  }
}

  
  // Save the timestamp of the last successful API fetch
  Future<void> _saveLastFetchTimestamp(ContactType type) async {
  final prefs = await SharedPreferences.getInstance();
  // Ensure correct ISO 8601 format with 'Z' for UTC
  final now = DateTime.now().toUtc().toIso8601String();
  final key = type == ContactType.primary ? _lastPrimaryFetchKey : _lastAllFetchKey;
  await prefs.setString(key, now);
  print('Saved timestamp: $now for $key');
}

  
  // Get the timestamp of the last successful API fetch
  Future<String?> _getLastFetchTimestamp(ContactType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = type == ContactType.primary ? _lastPrimaryFetchKey : _lastAllFetchKey;
    return prefs.getString(key);
  }
  
  // Force a full refresh (for pull-to-refresh functionality)
  Future<void> refreshContacts(BuildContext context, Function(bool) updateLoadingState, 
      Function(List<Contact>) updateContactsState) async {
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