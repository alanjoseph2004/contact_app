import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Contact {
  final int? id;  // Changed to int? to match API (readOnly)
  final int? referredBy;  // New field
  final String firstName;
  final String? lastName;
  final String? email;
  final String countryCode;
  final String phone;
  final String? note;
  
  // New geographic/political fields
  final int? district;
  final int? assemblyConstituency;
  final int? partyBlock;
  final int? partyConstituency;
  final int? booth;
  final int? parliamentaryConstituency;
  final int? localBody;
  final int? ward;
  
  // Updated address fields
  final String? houseName;
  final int? houseNumber;
  final String? city;
  final String? postOffice;
  final String? pinCode;  // Changed from general address field
  
  // Existing fields (kept for backward compatibility)
  final String? constituency;  // Keeping this for backward compatibility
  final String? address;       // Keeping this for backward compatibility
  final String? avatarUrl;
  final bool hasMessages;
  final ContactType type;
  final int? priority;
  final String? connection;
  final Map<String, dynamic>? referredByDetails; // Renamed from referredBy
  final List<int>? tags;  // Changed to List<int> to match API
  final bool isPrimaryContact;  // Renamed to match API field name
  final String? primaryID;

  Contact({
    this.id,
    this.referredBy,
    required this.firstName,
    this.lastName,
    this.email,
    required this.countryCode,
    required this.phone,
    this.note,
    this.district,
    this.assemblyConstituency,
    this.partyBlock,
    this.partyConstituency,
    this.booth,
    this.parliamentaryConstituency,
    this.localBody,
    this.ward,
    this.houseName,
    this.houseNumber,
    this.city,
    this.postOffice,
    this.pinCode,
    // Backward compatibility fields
    this.constituency,
    this.address,
    this.avatarUrl,
    this.hasMessages = false,
    required this.type,
    this.priority,
    this.connection,
    this.referredByDetails,
    this.tags,
    this.isPrimaryContact = false,
    this.primaryID,
  }) {
    // Validate priority for primary contacts
    if (type == ContactType.primary && priority != null) {
      if (priority! < 1 || priority! > 5) {
        throw ArgumentError('Priority for primary contacts must be between 1 and 5');
      }
    }
    
    // Validate primaryID is only used for primary contacts
    if (primaryID != null && type != ContactType.primary) {
      throw ArgumentError('primaryID can only be set for primary contacts');
    }
    
    // Validate pin code format (up to 6 digits)
    if (pinCode != null && pinCode!.isNotEmpty) {
      if (!RegExp(r'^\d{0,6}$').hasMatch(pinCode!)) {
        throw ArgumentError('Pin code must contain only digits and be up to 6 characters long');
      }
    }
    
    // Validate house number range
    if (houseNumber != null) {
      if (houseNumber! < 0 || houseNumber! > 9223372036854775807) {
        throw ArgumentError('House number must be between 0 and 9223372036854775807');
      }
    }
    
    // Validate string length constraints
    if (firstName.length > 63) {
      throw ArgumentError('First name must be 63 characters or less');
    }
    if (lastName != null && lastName!.length > 63) {
      throw ArgumentError('Last name must be 63 characters or less');
    }
    if (email != null && email!.length > 255) {
      throw ArgumentError('Email must be 255 characters or less');
    }
    if (countryCode.length > 5) {
      throw ArgumentError('Country code must be 5 characters or less');
    }
    if (phone.length > 11) {
      throw ArgumentError('Phone number must be 11 characters or less');
    }
    if (houseName != null && houseName!.length > 255) {
      throw ArgumentError('House name must be 255 characters or less');
    }
    if (city != null && city!.length > 255) {
      throw ArgumentError('City must be 255 characters or less');
    }
    if (postOffice != null && postOffice!.length > 255) {
      throw ArgumentError('Post office must be 255 characters or less');
    }
    if (pinCode != null && pinCode!.length > 6) {
      throw ArgumentError('Pin code must be 6 characters or less');
    }
  }

  // Helper getter to return full name
  String get name => lastName != null ? '$firstName $lastName' : firstName;

  // Helper getter to return formatted phone number
  String get phoneNumber => '$countryCode$phone';

  // Helper getter to return full address
  String get fullAddress {
    List<String> addressParts = [];
    
    if (houseName != null && houseName!.isNotEmpty) {
      addressParts.add(houseName!);
    }
    if (houseNumber != null) {
      addressParts.add(houseNumber.toString());
    }
    if (city != null && city!.isNotEmpty) {
      addressParts.add(city!);
    }
    if (postOffice != null && postOffice!.isNotEmpty) {
      addressParts.add(postOffice!);
    }
    if (pinCode != null && pinCode!.isNotEmpty) {
      addressParts.add(pinCode!);
    }
    
    // Fallback to legacy address field if new fields are empty
    if (addressParts.isEmpty && address != null && address!.isNotEmpty) {
      return address!;
    }
    
    return addressParts.join(', ');
  }

  // Convert contact to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referred_by': referredBy,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'country_code': countryCode,
      'phone': phone,
      'note': note,
      'district': district,
      'assembly_constituency': assemblyConstituency,
      'party_block': partyBlock,
      'party_constituency': partyConstituency,
      'booth': booth,
      'parliamentary_constituency': parliamentaryConstituency,
      'local_body': localBody,
      'ward': ward,
      'house_name': houseName,
      'house_number': houseNumber,
      'city': city,
      'post_office': postOffice,
      'pin_code': pinCode,
      // Backward compatibility fields
      'constituency': constituency,
      'address': address,
      'avatarUrl': avatarUrl,
      'hasMessages': hasMessages,
      'type': type.index,
      'priority': type == ContactType.primary ? priority : null,
      'connection': type == ContactType.all ? connection : null,
      'referredByDetails': referredByDetails,
      'tags': tags,
      'is_primary_contact': isPrimaryContact,
      'primaryID': type == ContactType.primary ? primaryID : null,
    };
  }

  // Create contact from JSON (API response)
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      referredBy: json['referred_by'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'],
      email: json['email'],
      countryCode: json['country_code'] ?? '',
      phone: json['phone'] ?? '',
      note: json['note'],
      district: json['district'],
      assemblyConstituency: json['assembly_constituency'],
      partyBlock: json['party_block'],
      partyConstituency: json['party_constituency'],
      booth: json['booth'],
      parliamentaryConstituency: json['parliamentary_constituency'],
      localBody: json['local_body'],
      ward: json['ward'],
      houseName: json['house_name'],
      houseNumber: json['house_number'],
      city: json['city'],
      postOffice: json['post_office'],
      pinCode: json['pin_code'],
      // Backward compatibility fields
      constituency: json['constituency'],
      address: json['address'],
      avatarUrl: json['avatarUrl'],
      hasMessages: json['hasMessages'] ?? false,
      type: json['type'] != null ? ContactType.values[json['type']] : ContactType.all,
      priority: json['priority'],
      connection: json['connection'],
      referredByDetails: json['referredByDetails'],
      tags: json['tags'] != null ? List<int>.from(json['tags']) : null,
      isPrimaryContact: json['is_primary_contact'] ?? false,
      primaryID: json['primaryID'],
    );
  }

  // Create contact from local storage JSON (backward compatibility)
  factory Contact.fromLocalJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      referredBy: json['referred_by'] ?? json['referredBy'],
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'],
      email: json['email'],
      countryCode: json['country_code'] ?? json['countryCode'] ?? '',
      phone: json['phone'] ?? '',
      note: json['note'],
      district: json['district'],
      assemblyConstituency: json['assembly_constituency'],
      partyBlock: json['party_block'],
      partyConstituency: json['party_constituency'],
      booth: json['booth'],
      parliamentaryConstituency: json['parliamentary_constituency'],
      localBody: json['local_body'],
      ward: json['ward'],
      houseName: json['house_name'],
      houseNumber: json['house_number'],
      city: json['city'],
      postOffice: json['post_office'],
      pinCode: json['pin_code'],
      constituency: json['constituency'],
      address: json['address'],
      avatarUrl: json['avatarUrl'],
      hasMessages: json['hasMessages'] ?? false,
      type: json['type'] != null ? ContactType.values[json['type']] : ContactType.all,
      priority: json['priority'],
      connection: json['connection'],
      referredByDetails: json['referredByDetails'],
      tags: json['tags'] != null ? 
        (json['tags'] is List<String> ? 
          (json['tags'] as List<String>).map((e) => int.tryParse(e) ?? 0).toList() :
          List<int>.from(json['tags'])) : null,
      isPrimaryContact: json['is_primary_contact'] ?? json['isPrimary'] ?? false,
      primaryID: json['primaryID'],
    );
  }

  // Copy with method for easy updates
  Contact copyWith({
    int? id,
    int? referredBy,
    String? firstName,
    String? lastName,
    String? email,
    String? countryCode,
    String? phone,
    String? note,
    int? district,
    int? assemblyConstituency,
    int? partyBlock,
    int? partyConstituency,
    int? booth,
    int? parliamentaryConstituency,
    int? localBody,
    int? ward,
    String? houseName,
    int? houseNumber,
    String? city,
    String? postOffice,
    String? pinCode,
    String? constituency,
    String? address,
    String? avatarUrl,
    bool? hasMessages,
    ContactType? type,
    int? priority,
    String? connection,
    Map<String, dynamic>? referredByDetails,
    List<int>? tags,
    bool? isPrimaryContact,
    String? primaryID,
  }) {
    return Contact(
      id: id ?? this.id,
      referredBy: referredBy ?? this.referredBy,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      note: note ?? this.note,
      district: district ?? this.district,
      assemblyConstituency: assemblyConstituency ?? this.assemblyConstituency,
      partyBlock: partyBlock ?? this.partyBlock,
      partyConstituency: partyConstituency ?? this.partyConstituency,
      booth: booth ?? this.booth,
      parliamentaryConstituency: parliamentaryConstituency ?? this.parliamentaryConstituency,
      localBody: localBody ?? this.localBody,
      ward: ward ?? this.ward,
      houseName: houseName ?? this.houseName,
      houseNumber: houseNumber ?? this.houseNumber,
      city: city ?? this.city,
      postOffice: postOffice ?? this.postOffice,
      pinCode: pinCode ?? this.pinCode,
      constituency: constituency ?? this.constituency,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasMessages: hasMessages ?? this.hasMessages,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      connection: connection ?? this.connection,
      referredByDetails: referredByDetails ?? this.referredByDetails,
      tags: tags ?? this.tags,
      isPrimaryContact: isPrimaryContact ?? this.isPrimaryContact,
      primaryID: primaryID ?? this.primaryID,
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
  
  // Load contacts from storage with backward compatibility
  static Future<List<Contact>> getContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getStringList(_storageKey) ?? [];
      
      return contactsJson
          .map((json) => Contact.fromLocalJson(jsonDecode(json)))
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
          .map((json) => Contact.fromLocalJson(jsonDecode(json)))
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
          .map((json) => Contact.fromLocalJson(jsonDecode(json)))
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
      final existingContacts = await getPrimaryContactsFromStorage();
      
      final Map<int, Contact> contactMap = {
        for (var contact in existingContacts) 
          if (contact.id != null) contact.id!: contact
      };
      
      for (var contact in apiContacts) {
        if (contact.id != null) {
          contactMap[contact.id!] = contact;
        }
      }
      
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
      final existingContacts = await getAllContactsFromStorage();
      
      final Map<int, Contact> contactMap = {
        for (var contact in existingContacts) 
          if (contact.id != null) contact.id!: contact
      };
      
      for (var contact in apiContacts) {
        if (contact.id != null) {
          contactMap[contact.id!] = contact;
        }
      }
      
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
    
    // Validate primaryID is only used for primary contacts
    if (contact.primaryID != null && contact.type != ContactType.primary) {
      throw ArgumentError('primaryID can only be set for primary contacts');
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
    int index = -1;
    
    // Find contact by ID or other unique identifier
    if (updatedContact.id != null) {
      index = contacts.indexWhere((c) => c.id == updatedContact.id);
    } else {
      // Fallback to phone number for backward compatibility
      index = contacts.indexWhere((c) => c.phoneNumber == updatedContact.phoneNumber);
    }
    
    if (index != -1) {
      // Validate priority for primary contacts
      if (updatedContact.type == ContactType.primary && updatedContact.priority != null) {
        if (updatedContact.priority! < 1 || updatedContact.priority! > 5) {
          throw ArgumentError('Priority for primary contacts must be between 1 and 5');
        }
      }
      
      // Validate primaryID is only used for primary contacts
      if (updatedContact.primaryID != null && updatedContact.type != ContactType.primary) {
        throw ArgumentError('primaryID can only be set for primary contacts');
      }

      contacts[index] = updatedContact;
      
      // Update the appropriate storage
      if (updatedContact.type == ContactType.primary) {
        final primaryContacts = await getPrimaryContactsFromStorage();
        final primaryIndex = updatedContact.id != null 
            ? primaryContacts.indexWhere((c) => c.id == updatedContact.id)
            : primaryContacts.indexWhere((c) => c.phoneNumber == updatedContact.phoneNumber);
        
        if (primaryIndex != -1) {
          primaryContacts[primaryIndex] = updatedContact;
        } else {
          primaryContacts.add(updatedContact);
        }
        
        await savePrimaryContacts(primaryContacts);
      } else if (updatedContact.type == ContactType.all) {
        final allContacts = await getAllContactsFromStorage();
        final allIndex = updatedContact.id != null 
            ? allContacts.indexWhere((c) => c.id == updatedContact.id)
            : allContacts.indexWhere((c) => c.phoneNumber == updatedContact.phoneNumber);
        
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
  
  // Delete a contact by ID or phone number
  static Future<bool> deleteContact(dynamic identifier) async {
    final contacts = await getContacts();
    Contact? deletedContact;
    
    if (identifier is int) {
      deletedContact = contacts.firstWhere((c) => c.id == identifier, orElse: () => throw Exception('Contact not found'));
      contacts.removeWhere((c) => c.id == identifier);
    } else if (identifier is String) {
      deletedContact = contacts.firstWhere((c) => c.phoneNumber == identifier, orElse: () => throw Exception('Contact not found'));
      contacts.removeWhere((c) => c.phoneNumber == identifier);
    }
    
    if (deletedContact == null) return false;
    
    // Also remove from appropriate contacts storage
    if (deletedContact.type == ContactType.primary) {
      final primaryContacts = await getPrimaryContactsFromStorage();
      if (identifier is int) {
        primaryContacts.removeWhere((c) => c.id == identifier);
      } else {
        primaryContacts.removeWhere((c) => c.phoneNumber == identifier);
      }
      await savePrimaryContacts(primaryContacts);
    } else if (deletedContact.type == ContactType.all) {
      final allContacts = await getAllContactsFromStorage();
      if (identifier is int) {
        allContacts.removeWhere((c) => c.id == identifier);
      } else {
        allContacts.removeWhere((c) => c.phoneNumber == identifier);
      }
      await saveAllContacts(allContacts);
    }
    
    return saveContacts(contacts);
  }
  
  // Get contacts by type
  static Future<List<Contact>> getContactsByType(ContactType type) async {
    if (type == ContactType.primary) {
      return await getPrimaryContactsFromStorage();
    } else if (type == ContactType.all) {
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
  static Future<List<Contact>> getContactsByTag(int tagId) async {
    final contacts = await getContacts();
    return contacts.where((c) => 
      c.tags != null && c.tags!.contains(tagId)
    ).toList();
  }
  
  // Get contacts by primaryID
  static Future<List<Contact>> getContactsByPrimaryID(String primaryID) async {
    final contacts = await getPrimaryContactsFromStorage();
    return contacts.where((c) => 
      c.primaryID == primaryID
    ).toList();
  }

  // New methods for geographic/political filtering
  static Future<List<Contact>> getContactsByDistrict(int districtId) async {
    final contacts = await getContacts();
    return contacts.where((c) => c.district == districtId).toList();
  }

  static Future<List<Contact>> getContactsByConstituency(int constituencyId) async {
    final contacts = await getContacts();
    return contacts.where((c) => c.assemblyConstituency == constituencyId).toList();
  }

  static Future<List<Contact>> getContactsByBooth(int boothId) async {
    final contacts = await getContacts();
    return contacts.where((c) => c.booth == boothId).toList();
  }

  static Future<List<Contact>> getContactsByPinCode(String pinCode) async {
    final contacts = await getContacts();
    return contacts.where((c) => c.pinCode == pinCode).toList();
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}