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

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.avatarUrl,
    this.hasMessages = false,
    required this.type,
  });

  // Convert contact to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'avatarUrl': avatarUrl,
      'hasMessages': hasMessages,
      'type': type.index, // Store enum as integer
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
    );
  }
}

enum ContactType {
  office,
  personal,
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
  
  // Save contacts to storage
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
  
  // Add a new contact
  static Future<bool> addContact(Contact contact) async {
    final contacts = await getContacts();
    contacts.add(contact);
    return saveContacts(contacts);
  }
  
  // Update an existing contact
  static Future<bool> updateContact(Contact updatedContact) async {
    final contacts = await getContacts();
    final index = contacts.indexWhere((c) => c.id == updatedContact.id);
    
    if (index != -1) {
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
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}