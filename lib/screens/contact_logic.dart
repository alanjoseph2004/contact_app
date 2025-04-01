import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Contact {
  final String id;
  final String firstName;
  final String? lastName;
  final String countryCode;
  final String phone;
  final String? email;
  final String? note;
  final String? address;
  final String? city;
  final String? constituency;
  final String? avatarUrl;
  final bool hasMessages;
  final ContactType type;
  final int? priority;       // Range constraint for primary contacts
  final String? connection;  // For all contacts - ID of the referring primary contact
  final Map<String, dynamic>? referredBy; // Additional referral details for all contacts
  final List<String>? tags;
  final bool isPrimary;      // Flag to indicate if it's a primary contact

  Contact({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.countryCode,
    required this.phone,
    this.email,
    this.note,
    this.address,
    this.city,
    this.constituency,
    this.avatarUrl,
    this.hasMessages = false,
    required this.type,
    this.priority,
    this.connection,
    this.referredBy,
    this.tags,
    this.isPrimary = false,
  }) {
    // Validate priority for primary contacts
    if (type == ContactType.primary && priority != null) {
      if (priority! < 1 || priority! > 5) {
        throw ArgumentError('Priority for primary contacts must be between 1 and 5');
      }
    }
  }

  // Helper getter to return full name
  String get name => lastName != null ? '$firstName $lastName' : firstName;

  // Helper getter to return formatted phone number
  String get phoneNumber => '$countryCode$phone';

  // Convert contact to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'countryCode': countryCode,
      'phone': phone,
      'email': email,
      'note': note,
      'address': address,
      'city': city,
      'constituency': constituency,
      'avatarUrl': avatarUrl,
      'hasMessages': hasMessages,
      'type': type.index,
      'priority': type == ContactType.primary ? priority : null,
      'connection': type == ContactType.all ? connection : null,
      'referredBy': referredBy,
      'tags': tags,
      'isPrimary': isPrimary,
    };
  }

  // Create contact from JSON
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      countryCode: json['countryCode'],
      phone: json['phone'],
      email: json['email'],
      note: json['note'],
      address: json['address'],
      city: json['city'],
      constituency: json['constituency'],
      avatarUrl: json['avatarUrl'],
      hasMessages: json['hasMessages'] ?? false,
      type: ContactType.values[json['type']],
      priority: json['type'] == ContactType.primary.index ? json['priority'] : null,
      connection: json['type'] == ContactType.all.index ? json['connection'] : null,
      referredBy: json['referredBy'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}

enum ContactType {
  primary,
  all,
  both
}

// Service to handle contact operations
class ContactService {
  static const String _storageKey = 'contacts';
  static const String _primaryContactsKey = 'primary_contacts';
  static const String _allContactsKey = 'all_contacts';
  
  // Load contacts from storage
  static Future<List<Contact>> getContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList(_storageKey) ?? [];
      
      return contactsJson
          .map((json) => Contact.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      return [];
    }
  }
  
  // Load primary contacts from storage
  static Future<List<Contact>> getPrimaryContactsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList(_primaryContactsKey) ?? [];
      
      return contactsJson
          .map((json) => Contact.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      debugPrint('Error loading primary contacts: $e');
      return [];
    }
  }
  
  // Load all contacts from storage
  static Future<List<Contact>> getAllContactsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList(_allContactsKey) ?? [];
      
      return contactsJson
          .map((json) => Contact.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      debugPrint('Error loading all contacts: $e');
      return [];
    }
  }
  
  // Save primary contacts to storage
  static Future<bool> savePrimaryContacts(List<Contact> contacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = contacts
          .map((contact) => jsonEncode(contact.toJson()))
          .toList();
      
      return await prefs.setStringList(_primaryContactsKey, contactsJson);
    } catch (e) {
      debugPrint('Error saving primary contacts: $e');
      return false;
    }
  }
  
  // Save all contacts to storage
  static Future<bool> saveAllContacts(List<Contact> contacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = contacts
          .map((contact) => jsonEncode(contact.toJson()))
          .toList();
      
      return await prefs.setStringList(_allContactsKey, contactsJson);
    } catch (e) {
      debugPrint('Error saving all contacts: $e');
      return false;
    }
  }
  
  // Save API primary contacts to local storage
  static Future<bool> cacheApiPrimaryContacts(List<Contact> apiContacts) async {
    try {
      // First, get existing primary contacts to merge/update
      final existingContacts = await getPrimaryContactsFromStorage();
      
      // Create a map of existing contacts by ID for easy lookup
      final Map<String, Contact> contactMap = {
        for (var contact in existingContacts) contact.id: contact
      };
      
      // Update or add new contacts from API
      for (var contact in apiContacts) {
        contactMap[contact.id] = contact;
      }
      
      // Convert back to list and save
      final updatedContacts = contactMap.values.toList();
      return await savePrimaryContacts(updatedContacts);
    } catch (e) {
      debugPrint('Error caching primary contacts: $e');
      return false;
    }
  }
  
  // Save API all contacts to local storage
  static Future<bool> cacheApiAllContacts(List<Contact> apiContacts) async {
    try {
      // First, get existing all contacts to merge/update
      final existingContacts = await getAllContactsFromStorage();
      
      // Create a map of existing contacts by ID for easy lookup
      final Map<String, Contact> contactMap = {
        for (var contact in existingContacts) contact.id: contact
      };
      
      // Update or add new contacts from API
      for (var contact in apiContacts) {
        contactMap[contact.id] = contact;
      }
      
      // Convert back to list and save
      final updatedContacts = contactMap.values.toList();
      return await saveAllContacts(updatedContacts);
    } catch (e) {
      debugPrint('Error caching all contacts: $e');
      return false;
    }
  }
  
  // Save contacts to storage with additional validation
  static Future<bool> saveContacts(List<Contact> contacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = contacts
          .map((contact) => jsonEncode(contact.toJson()))
          .toList();
      
      return await prefs.setStringList(_storageKey, contactsJson);
    } catch (e) {
      debugPrint('Error saving contacts: $e');
      return false;
    }
  }
  
  // Add a new contact with validation
  static Future<bool> addContact(Contact contact) async {
    final contacts = await getContacts();
    
    // Validate priority for primary contacts
    if (contact.type == ContactType.primary && contact.priority != null) {
      if (contact.priority! < 1 || contact.priority! > 5) {
        throw ArgumentError('Priority for primary contacts must be between 1 and 5');
      }
    }

    contacts.add(contact);
    
    // If it's a primary contact, also add it to the primary contacts storage
    if (contact.type == ContactType.primary) {
      final primaryContacts = await getPrimaryContactsFromStorage();
      primaryContacts.add(contact);
      await savePrimaryContacts(primaryContacts);
    } else if (contact.type == ContactType.all) {
      final allContacts = await getAllContactsFromStorage();
      allContacts.add(contact);
      await saveAllContacts(allContacts);
    }
    
    return saveContacts(contacts);
  }
  
  // Update an existing contact with validation
  static Future<bool> updateContact(Contact updatedContact) async {
    final contacts = await getContacts();
    final index = contacts.indexWhere((c) => c.id == updatedContact.id);
    
    if (index != -1) {
      // Validate priority for primary contacts
      if (updatedContact.type == ContactType.primary && updatedContact.priority != null) {
        if (updatedContact.priority! < 1 || updatedContact.priority! > 5) {
          throw ArgumentError('Priority for primary contacts must be between 1 and 5');
        }
      }

      contacts[index] = updatedContact;
      
      // Update the primary contacts storage if needed
      if (updatedContact.type == ContactType.primary) {
        final primaryContacts = await getPrimaryContactsFromStorage();
        final primaryIndex = primaryContacts.indexWhere((c) => c.id == updatedContact.id);
        
        if (primaryIndex != -1) {
          primaryContacts[primaryIndex] = updatedContact;
        } else {
          primaryContacts.add(updatedContact);
        }
        
        await savePrimaryContacts(primaryContacts);
      } else if (updatedContact.type == ContactType.all) {
        final allContacts = await getAllContactsFromStorage();
        final allIndex = allContacts.indexWhere((c) => c.id == updatedContact.id);
        
        if (allIndex != -1) {
          allContacts[allIndex] = updatedContact;
        } else {
          allContacts.add(updatedContact);
        }
        
        await saveAllContacts(allContacts);
      }
      
      return saveContacts(contacts);
    }
    return false;
  }
  
  // Delete a contact
  static Future<bool> deleteContact(String id) async {
    final contacts = await getContacts();
    final deletedContact = contacts.firstWhere((c) => c.id == id, orElse: () => throw Exception('Contact not found'));
    
    contacts.removeWhere((c) => c.id == id);
    
    // Also remove from appropriate contacts storage
    if (deletedContact.type == ContactType.primary) {
      final primaryContacts = await getPrimaryContactsFromStorage();
      primaryContacts.removeWhere((c) => c.id == id);
      await savePrimaryContacts(primaryContacts);
    } else if (deletedContact.type == ContactType.all) {
      final allContacts = await getAllContactsFromStorage();
      allContacts.removeWhere((c) => c.id == id);
      await saveAllContacts(allContacts);
    }
    
    return saveContacts(contacts);
  }
  
  // Get contacts by type
  static Future<List<Contact>> getContactsByType(ContactType type) async {
    if (type == ContactType.primary) {
      // Return cached primary contacts
      return await getPrimaryContactsFromStorage();
    } else if (type == ContactType.all) {
      // Return cached all contacts
      return await getAllContactsFromStorage();
    }
    
    final contacts = await getContacts();
    
    if (type == ContactType.both) {
      return contacts;
    } else {
      return contacts.where((c) => 
        c.type == type || c.type == ContactType.both
      ).toList();
    }
  }
  
  // Get contacts with priority
  static Future<List<Contact>> getPriorityContacts() async {
    final contacts = await getPrimaryContactsFromStorage();
    return contacts.where((c) => 
      c.priority != null && 
      c.priority! >= 1 && 
      c.priority! <= 5
    ).toList();
  }
  
  // Get contacts by tag
  static Future<List<Contact>> getContactsByTag(String tag) async {
    final contacts = await getContacts();
    return contacts.where((c) => 
      c.tags != null && c.tags!.contains(tag)
    ).toList();
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}