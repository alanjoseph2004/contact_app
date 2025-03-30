import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Contact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? avatarUrl;
  final bool hasMessages;
  final ContactType type;
  final int? priority;       // Changed to int with range constraint for primary contacts
  final String? referredBy;  // Only for all contacts

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.avatarUrl,
    this.hasMessages = false,
    required this.type,
    this.priority,
    this.referredBy,
  }) {
    // Validate priority for primary contacts
    if (type == ContactType.primary && priority != null) {
      if (priority! < 1 || priority! > 5) {
        throw ArgumentError('Priority for primary contacts must be between 1 and 5');
      }
    }

    // Validate referredBy for all contacts
    if (type == ContactType.all && referredBy != null) {
      // This will be checked in the service layer to ensure the referring contact is a primary contact
    }
  }

  // Convert contact to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'avatarUrl': avatarUrl,
      'hasMessages': hasMessages,
      'type': type.index,
      'priority': type == ContactType.primary ? priority : null,
      'referredBy': type == ContactType.all ? referredBy : null,
    };
  }

  // Create contact from JSON
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      hasMessages: json['hasMessages'] ?? false,
      type: ContactType.values[json['type']],
      priority: json['type'] == ContactType.primary.index ? json['priority'] : null,
      referredBy: json['type'] == ContactType.all.index ? json['referredBy'] : null,
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
  
  // Save contacts to storage with additional validation
  static Future<bool> saveContacts(List<Contact> contacts) async {
    try {
      // Validate referredBy for all contacts
      for (var contact in contacts) {
        if (contact.type == ContactType.all && contact.referredBy != null) {
          // Check if the referring contact exists and is a primary contact
          final referringContact = contacts.firstWhere(
            (c) => c.id == contact.referredBy && c.type == ContactType.primary,
            orElse: () => throw ArgumentError('Referred contact must be a primary contact'),
          );
        }
      }

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

    // Validate referredBy for all contacts
    if (contact.type == ContactType.all && contact.referredBy != null) {
      final referringContact = contacts.firstWhere(
        (c) => c.id == contact.referredBy && c.type == ContactType.primary,
        orElse: () => throw ArgumentError('Referred contact must be a primary contact'),
      );
    }

    contacts.add(contact);
    
    // If it's a primary contact, also add it to the primary contacts storage
    if (contact.type == ContactType.primary) {
      final primaryContacts = await getPrimaryContactsFromStorage();
      primaryContacts.add(contact);
      await savePrimaryContacts(primaryContacts);
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

      // Validate referredBy for all contacts
      if (updatedContact.type == ContactType.all && updatedContact.referredBy != null) {
        final referringContact = contacts.firstWhere(
          (c) => c.id == updatedContact.referredBy && c.type == ContactType.primary,
          orElse: () => throw ArgumentError('Referred contact must be a primary contact'),
        );
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
      }
      
      return saveContacts(contacts);
    }
    return false;
  }
  
  // Delete a contact
  static Future<bool> deleteContact(String id) async {
    final contacts = await getContacts();
    final deletedContact = contacts.firstWhere((c) => c.id == id, orElse: () => null as Contact);
    
    contacts.removeWhere((c) => c.id == id);
    
    // Also remove from primary contacts if needed
    if (deletedContact != null && deletedContact.type == ContactType.primary) {
      final primaryContacts = await getPrimaryContactsFromStorage();
      primaryContacts.removeWhere((c) => c.id == id);
      await savePrimaryContacts(primaryContacts);
    }
    
    return saveContacts(contacts);
  }
  
  // Get contacts by type
  static Future<List<Contact>> getContactsByType(ContactType type) async {
    if (type == ContactType.primary) {
      // Return cached primary contacts
      return await getPrimaryContactsFromStorage();
    }
    
    final contacts = await getContacts();
    
    if (type == ContactType.both) {
      return contacts.where((c) => 
        c.type == ContactType.both || 
        c.type == ContactType.primary || 
        c.type == ContactType.all
      ).toList();
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
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}