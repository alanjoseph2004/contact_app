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
      return saveContacts(contacts);
    }
    return false;
  }
  
  // Delete a contact
  static Future<bool> deleteContact(String id) async {
    final contacts = await getContacts();
    contacts.removeWhere((c) => c.id == id);
    return saveContacts(contacts);
  }
  
  // Get contacts by type
  static Future<List<Contact>> getContactsByType(ContactType type) async {
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
    final contacts = await getContacts();
    return contacts.where((c) => 
      c.type == ContactType.primary && 
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