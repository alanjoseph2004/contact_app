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
        
        // Convert API response to Contact objects using the new Contact model
        final List<Contact> apiContacts = results.map((contactData) {
          final contactObj = contactData['contact'];
          
          // Handle city properly - extract city name if it's an object
          String? cityStr;
          if (contactObj['city'] != null) {
            if (contactObj['city'] is Map && contactObj['city']['city'] != null) {
              cityStr = contactObj['city']['city'].toString();
            } else if (contactObj['city'] is String) {
              cityStr = contactObj['city'];
            }
          }
          
          // Handle tags properly - extract tag IDs
          List<int>? tagList;
          if (contactData['tags'] != null && contactData['tags'] is List) {
            tagList = (contactData['tags'] as List)
                .map((tag) {
                  if (tag is Map && tag['id'] != null) {
                    return tag['id'] as int;
                  } else if (tag is int) {
                    return tag;
                  }
                  return 0;
                })
                .where((id) => id != 0)
                .toList();
          }
          
          // Handle connection properly - extract connection string
          String? connectionStr;
          if (contactData['connection'] != null) {
            if (contactData['connection'] is Map && contactData['connection']['connection'] != null) {
              connectionStr = contactData['connection']['connection'].toString();
            } else if (contactData['connection'] is String) {
              connectionStr = contactData['connection'];
            }
          }
          
          return Contact(
            id: contactObj['id'],
            firstName: contactObj['first_name'] ?? '',
            lastName: contactObj['last_name'],
            countryCode: contactObj['country_code'] ?? '',
            phone: contactObj['phone'] ?? '',
            email: contactObj['email'],
            type: ContactType.primary,
            priority: contactData['priority'],
            note: contactObj['note'],
            // New address fields
            houseName: contactObj['house_name'],
            houseNumber: contactObj['house_number'],
            city: cityStr,
            postOffice: contactObj['post_office'],
            pinCode: contactObj['pin_code'],
            // Geographic/political fields
            district: contactObj['district'],
            assemblyConstituency: contactObj['assembly_constituency'],
            partyBlock: contactObj['party_block'],
            partyConstituency: contactObj['party_constituency'],
            booth: contactObj['booth'],
            parliamentaryConstituency: contactObj['parliamentary_constituency'],
            localBody: contactObj['local_body'],
            ward: contactObj['ward'],
            referredBy: contactObj['referred_by'],
            // Backward compatibility fields
            address: contactObj['address'],
            constituency: contactObj['constituency'] ?? '',
            connection: connectionStr,
            tags: tagList,
            isPrimaryContact: true,
            primaryID: contactData['id']?.toString(),
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
      print('Error fetching primary contacts: $e');
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
        return fetchPrimaryContactsFromAPI(context, updateLoadingState, updateContactsState);
      }
      
      // Load cached contacts first
      final cachedContacts = await ContactService.getPrimaryContactsFromStorage();
      setContacts(cachedContacts, updateContactsState);
      
      // Encode the timestamp for URL safety
      final encodedTimestamp = Uri.encodeComponent(lastFetchTime);
      
      // Fetch only updates with GET request
      final response = await http.get(
        Uri.parse('$_timedPrimaryContactsEndpoint?datetime=$encodedTimestamp'),
      );
      
      print('Timed retrieval response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (!data.containsKey('results')) {
          print('Response is missing expected "results" key: $data');
          setLoading(false, updateLoadingState);
          return;
        }
        
        final List<dynamic> results = data['results'] ?? [];
        
        if (results.isEmpty) {
          print('No updated contacts found');
          setLoading(false, updateLoadingState);
          return;
        }
        
        print('Found ${results.length} updated contacts');
        
        // Convert API response to Contact objects
        final List<Contact> updatedContacts = [];
        
        for (var contactData in results) {
          try {
            final contactObj = contactData['contact'];
            if (contactObj == null) {
              print('Missing contact object in: $contactData');
              continue;
            }
            
            // Handle city properly
            String? cityStr;
            if (contactObj['city'] != null) {
              if (contactObj['city'] is Map && contactObj['city']['city'] != null) {
                cityStr = contactObj['city']['city'].toString();
              } else if (contactObj['city'] is String) {
                cityStr = contactObj['city'];
              }
            }
            
            // Handle tags properly
            List<int>? tagList;
            if (contactData['tags'] != null && contactData['tags'] is List) {
              tagList = (contactData['tags'] as List)
                  .map((tag) {
                    if (tag is Map && tag['id'] != null) {
                      return tag['id'] as int;
                    } else if (tag is int) {
                      return tag;
                    }
                    return 0;
                  })
                  .where((id) => id != 0)
                  .toList();
            }
            
            // Handle connection properly
            String? connectionStr;
            if (contactData['connection'] != null) {
              if (contactData['connection'] is Map && contactData['connection']['connection'] != null) {
                connectionStr = contactData['connection']['connection'].toString();
              } else if (contactData['connection'] is String) {
                connectionStr = contactData['connection'];
              }
            }
            
            final contact = Contact(
              id: contactObj['id'],
              firstName: contactObj['first_name'] ?? '',
              lastName: contactObj['last_name'],
              countryCode: contactObj['country_code'] ?? '',
              phone: contactObj['phone'] ?? '',
              email: contactObj['email'],
              type: ContactType.primary,
              priority: contactData['priority'],
              note: contactObj['note'],
              // New address fields
              houseName: contactObj['house_name'],
              houseNumber: contactObj['house_number'],
              city: cityStr,
              postOffice: contactObj['post_office'],
              pinCode: contactObj['pin_code'],
              // Geographic/political fields
              district: contactObj['district'],
              assemblyConstituency: contactObj['assembly_constituency'],
              partyBlock: contactObj['party_block'],
              partyConstituency: contactObj['party_constituency'],
              booth: contactObj['booth'],
              parliamentaryConstituency: contactObj['parliamentary_constituency'],
              localBody: contactObj['local_body'],
              ward: contactObj['ward'],
              referredBy: contactObj['referred_by'],
              // Backward compatibility fields
              address: contactObj['address'],
              constituency: contactObj['constituency'] ?? '',
              connection: connectionStr,
              tags: tagList,
              isPrimaryContact: true,
              primaryID: contactData['id']?.toString(),
            );
            
            updatedContacts.add(contact);
          } catch (e) {
            print('Error processing contact: $e for data: $contactData');
          }
        }
        
        // Create a map from cached contacts for easy lookup
        Map<int, Contact> contactMap = {
          for (var contact in cachedContacts) 
            if (contact.id != null) contact.id!: contact
        };
        
        // Update or add new contacts
        for (var contact in updatedContacts) {
          if (contact.id != null) {
            contactMap[contact.id!] = contact;
          }
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
        print('Failed to retrieve updates: ${response.statusCode}');
        setLoading(false, updateLoadingState);
        showErrorSnackBar(context, 'Failed to retrieve contact updates (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching updated primary contacts: $e');
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
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> contactsData = responseData['results'] ?? [];
        
        // Convert API response to Contact objects using the new Contact model
        final List<Contact> apiContacts = contactsData.map<Contact>((contactData) {
          // Handle city properly
          String? cityStr;
          if (contactData['city'] != null) {
            if (contactData['city'] is Map && contactData['city']['city'] != null) {
              cityStr = contactData['city']['city'].toString();
            } else if (contactData['city'] is String) {
              cityStr = contactData['city'];
            }
          }
          
          // Handle referred_by details
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
            id: contactData['id'],
            firstName: contactData['first_name'] ?? '',
            lastName: contactData['last_name'],
            countryCode: contactData['country_code'] ?? '',
            phone: contactData['phone'] ?? '',
            email: contactData['email'],
            type: ContactType.all,
            note: contactData['note'],
            // New address fields
            houseName: contactData['house_name'],
            houseNumber: contactData['house_number'],
            city: cityStr,
            postOffice: contactData['post_office'],
            pinCode: contactData['pin_code'],
            // Geographic/political fields
            district: contactData['district'],
            assemblyConstituency: contactData['assembly_constituency'],
            partyBlock: contactData['party_block'],
            partyConstituency: contactData['party_constituency'],
            booth: contactData['booth'],
            parliamentaryConstituency: contactData['parliamentary_constituency'],
            localBody: contactData['local_body'],
            ward: contactData['ward'],
            referredBy: contactData['referred_by'] is int ? contactData['referred_by'] : null,
            // Backward compatibility fields
            address: contactData['address'],
            constituency: contactData['constituency'] ?? '',
            referredByDetails: referredByMap,
            isPrimaryContact: contactData['is_primary_contact'] ?? false,
          );
        }).toList();
        
        // Filter out primary contacts from the display
        final nonPrimaryContacts = apiContacts.where((contact) => !contact.isPrimaryContact).toList();
        
        // Cache all contacts to local storage
        await ContactService.saveAllContacts(apiContacts);
        
        // Save current timestamp for future timed retrieval
        await _saveLastFetchTimestamp(ContactType.all);
        
        // Only show non-primary contacts in the UI
        setContacts(nonPrimaryContacts, updateContactsState);
        setLoading(false, updateLoadingState);
      } else {
        // Handle error - Try to load from cache if API fails
        final cachedContacts = await ContactService.getAllContactsFromStorage();
        final nonPrimaryContacts = cachedContacts.where((contact) => !contact.isPrimaryContact).toList();
        setContacts(nonPrimaryContacts, updateContactsState);
        setLoading(false, updateLoadingState);
        
        if (cachedContacts.isEmpty) {
          showErrorSnackBar(context, 'Failed to load all contacts');
        } else {
          showErrorSnackBar(context, 'Using cached contacts - API request failed');
        }
      }
    } catch (e) {
      print('Error fetching all contacts: $e');
      // Load from cache in case of error
      final cachedContacts = await ContactService.getAllContactsFromStorage();
      final nonPrimaryContacts = cachedContacts.where((contact) => !contact.isPrimaryContact).toList();
      setContacts(nonPrimaryContacts, updateContactsState);
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
        return fetchAllContactsFromAPI(context, updateLoadingState, updateContactsState);
      }
      
      // Load cached contacts first
      final cachedContacts = await ContactService.getAllContactsFromStorage();
      final nonPrimaryContacts = cachedContacts.where((contact) => !contact.isPrimaryContact).toList();
      setContacts(nonPrimaryContacts, updateContactsState);
      
      // Encode the timestamp for URL safety
      final encodedTimestamp = Uri.encodeComponent(lastFetchTime);
      
      // Fetch only updates with GET request
      final response = await http.get(
        Uri.parse('$_timedAllContactsEndpoint?datetime=$encodedTimestamp'),
      );
      
      print('Timed retrieval (all contacts) response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (!data.containsKey('results')) {
          print('Response is missing expected "results" key: $data');
          setLoading(false, updateLoadingState);
          return;
        }
        
        final List<dynamic> results = data['results'] ?? [];
        
        if (results.isEmpty) {
          print('No updated contacts found');
          setLoading(false, updateLoadingState);
          return;
        }
        
        print('Found ${results.length} updated contacts');
        
        // Convert API response to Contact objects
        final List<Contact> updatedContacts = [];
        
        for (var contactData in results) {
          try {
            // Handle city properly
            String? cityStr;
            if (contactData['city'] != null) {
              if (contactData['city'] is Map && contactData['city']['city'] != null) {
                cityStr = contactData['city']['city'].toString();
              } else if (contactData['city'] is String) {
                cityStr = contactData['city'];
              }
            }
            
            // Handle referred_by details
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
              id: contactData['id'],
              firstName: contactData['first_name'] ?? '',
              lastName: contactData['last_name'],
              countryCode: contactData['country_code'] ?? '',
              phone: contactData['phone'] ?? '',
              email: contactData['email'],
              type: ContactType.all,
              note: contactData['note'],
              // New address fields
              houseName: contactData['house_name'],
              houseNumber: contactData['house_number'],
              city: cityStr,
              postOffice: contactData['post_office'],
              pinCode: contactData['pin_code'],
              // Geographic/political fields
              district: contactData['district'],
              assemblyConstituency: contactData['assembly_constituency'],
              partyBlock: contactData['party_block'],
              partyConstituency: contactData['party_constituency'],
              booth: contactData['booth'],
              parliamentaryConstituency: contactData['parliamentary_constituency'],
              localBody: contactData['local_body'],
              ward: contactData['ward'],
              referredBy: contactData['referred_by'] is int ? contactData['referred_by'] : null,
              // Backward compatibility fields
              address: contactData['address'],
              constituency: contactData['constituency'] ?? '',
              referredByDetails: referredByMap,
              isPrimaryContact: contactData['is_primary_contact'] ?? false,
            );
            
            updatedContacts.add(contact);
          } catch (e) {
            print('Error processing contact: $e for data: $contactData');
          }
        }
        
        // Create a map from cached contacts for easy lookup
        Map<int, Contact> contactMap = {
          for (var contact in cachedContacts) 
            if (contact.id != null) contact.id!: contact
        };
        
        // Update or add new contacts
        for (var contact in updatedContacts) {
          if (contact.id != null) {
            contactMap[contact.id!] = contact;
          }
        }
        
        // Convert back to list
        final allMergedContacts = contactMap.values.toList();
        
        // Update cache with all contacts
        await ContactService.saveAllContacts(allMergedContacts);
        
        // Save new timestamp
        await _saveLastFetchTimestamp(ContactType.all);
        
        // Filter out primary contacts before updating UI
        final nonPrimaryContacts = allMergedContacts.where((contact) => !contact.isPrimaryContact).toList();
        setContacts(nonPrimaryContacts, updateContactsState);
        setLoading(false, updateLoadingState);
      } else {
        print('Failed to retrieve updates: ${response.statusCode}');
        setLoading(false, updateLoadingState);
        showErrorSnackBar(context, 'Failed to retrieve contact updates (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching updated all contacts: $e');
      setLoading(false, updateLoadingState);
      showErrorSnackBar(context, 'Error getting updates: ${e.toString()}');
    }
  }

  // Save the timestamp of the last successful API fetch
  Future<void> _saveLastFetchTimestamp(ContactType type) async {
    final prefs = await SharedPreferences.getInstance();
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

  // Helper methods for the new Contact model features
  
  // Get contacts by district
  Future<List<Contact>> getContactsByDistrict(int districtId) async {
    return ContactService.getContactsByDistrict(districtId);
  }
  
  // Get contacts by assembly constituency
  Future<List<Contact>> getContactsByConstituency(int constituencyId) async {
    return ContactService.getContactsByConstituency(constituencyId);
  }
  
  // Get contacts by booth
  Future<List<Contact>> getContactsByBooth(int boothId) async {
    return ContactService.getContactsByBooth(boothId);
  }
  
  // Get contacts by pin code
  Future<List<Contact>> getContactsByPinCode(String pinCode) async {
    return ContactService.getContactsByPinCode(pinCode);
  }
  
  // Get contacts by tag
  Future<List<Contact>> getContactsByTag(int tagId) async {
    return ContactService.getContactsByTag(tagId);
  }
  
  // Get priority contacts
  Future<List<Contact>> getPriorityContacts() async {
    return ContactService.getPriorityContacts();
  }
}