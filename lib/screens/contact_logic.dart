import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Contact {
  final int id;
  final int? referredBy;
  final String firstName;
  final String? lastName;
  final String? email;
  final String countryCode;
  final String phone;
  final String? note;
  final int? district;
  final int? assemblyConstituency;
  final int? partyBlock;
  final int? partyConstituency;
  final int? booth;
  final int? parliamentaryConstituency;
  final int? localBody;
  final int? ward;
  final String? houseName;
  final int? houseNumber;
  final String? city;
  final String? postOffice;
  final String? pinCode;
  final List<int>? tags;
  final bool isPrimaryContact;
  final String? avatarUrl;
  final bool hasMessages;
  final ContactType type;
  final int? priority;
  final String? connection;
  final Map<String, dynamic>? referralDetails;

  Contact({
    required this.id,
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
    this.tags,
    this.isPrimaryContact = false,
    this.avatarUrl,
    this.hasMessages = false,
    required this.type,
    this.priority,
    this.connection,
    this.referralDetails,
  }) {
    // Validate priority for primary contacts
    if (isPrimaryContact && priority != null) {
      if (priority! < 1 || priority! > 5) {
        throw ArgumentError('Priority for primary contacts must be between 1 and 5');
      }
    }
    
    // Validate email format if provided
    if (email != null && email!.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email!)) {
        throw ArgumentError('Invalid email format');
      }
    }
    
    // Validate phone number
    if (phone.length > 11) {
      throw ArgumentError('Phone number cannot exceed 11 digits');
    }
    
    // Validate PIN code format
    if (pinCode != null && pinCode!.isNotEmpty) {
      final pinRegex = RegExp(r'^[0-9]{6}$');
      if (!pinRegex.hasMatch(pinCode!)) {
        throw ArgumentError('PIN code must be exactly 6 digits');
      }
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
      'tags': tags,
      'is_primary_contact': isPrimaryContact,
      'avatarUrl': avatarUrl,
      'hasMessages': hasMessages,
      'type': type.index,
      'priority': isPrimaryContact ? priority : null,
      'connection': connection,
      'referralDetails': referralDetails,
    };
  }

  // Create contact from JSON
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      referredBy: json['referred_by'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      countryCode: json['country_code'],
      phone: json['phone'],
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
      tags: json['tags'] != null ? List<int>.from(json['tags']) : null,
      isPrimaryContact: json['is_primary_contact'] ?? false,
      avatarUrl: json['avatarUrl'],
      hasMessages: json['hasMessages'] ?? false,
      type: ContactType.values[json['type'] ?? 0],
      priority: json['priority'],
      connection: json['connection'],
      referralDetails: json['referralDetails'],
    );
  }

  // Create contact from API response
  factory Contact.fromApiResponse(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      referredBy: json['referred_by'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      countryCode: json['country_code'],
      phone: json['phone'],
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
      tags: json['tags'] != null ? List<int>.from(json['tags']) : null,
      isPrimaryContact: json['is_primary_contact'] ?? false,
      type: ContactType.primary, // Default from API
      hasMessages: false,
    );
  }

  // Create contact for API request
  Map<String, dynamic> toApiRequest() {
    return {
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
      'tags': tags,
      'is_primary_contact': isPrimaryContact,
    };
  }

  // Copy with method for updates
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
    List<int>? tags,
    bool? isPrimaryContact,
    String? avatarUrl,
    bool? hasMessages,
    ContactType? type,
    int? priority,
    String? connection,
    Map<String, dynamic>? referralDetails,
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
      tags: tags ?? this.tags,
      isPrimaryContact: isPrimaryContact ?? this.isPrimaryContact,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasMessages: hasMessages ?? this.hasMessages,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      connection: connection ?? this.connection,
      referralDetails: referralDetails ?? this.referralDetails,
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
  static const String _lastSyncKey = 'last_sync_timestamp';
  
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
      final Map<int, Contact> contactMap = {
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
      final Map<int, Contact> contactMap = {
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
      
      // Update last sync timestamp
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      
      return await prefs.setStringList(_storageKey, contactsJson);
    } catch (e) {
      debugPrint('Error saving contacts: $e');
      return false;
    }
  }
  
  // Add a new contact with validation
  static Future<bool> addContact(Contact contact) async {
    try {
      final contacts = await getContacts();
      
      // Validate contact data
      _validateContact(contact);

      contacts.add(contact);
      
      // If it's a primary contact, also add it to the primary contacts storage
      if (contact.isPrimaryContact || contact.type == ContactType.primary) {
        final primaryContacts = await getPrimaryContactsFromStorage();
        primaryContacts.add(contact);
        await savePrimaryContacts(primaryContacts);
      } else if (contact.type == ContactType.all) {
        final allContacts = await getAllContactsFromStorage();
        allContacts.add(contact);
        await saveAllContacts(allContacts);
      }
      
      return saveContacts(contacts);
    } catch (e) {
      debugPrint('Error adding contact: $e');
      return false;
    }
  }
  
  // Update an existing contact with validation
  static Future<bool> updateContact(Contact updatedContact) async {
    try {
      final contacts = await getContacts();
      final index = contacts.indexWhere((c) => c.id == updatedContact.id);
      
      if (index != -1) {
        // Validate contact data
        _validateContact(updatedContact);

        contacts[index] = updatedContact;
        
        // Update the primary contacts storage if needed
        if (updatedContact.isPrimaryContact || updatedContact.type == ContactType.primary) {
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
    } catch (e) {
      debugPrint('Error updating contact: $e');
      return false;
    }
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
    ).toList()..sort((a, b) => a.priority!.compareTo(b.priority!));
  }
  
  // Get contacts by tag
  static Future<List<Contact>> getContactsByTag(int tagId) async {
    final contacts = await getContacts();
    return contacts.where((c) => 
      c.tags != null && c.tags!.contains(tagId)
    ).toList();
  }
  
  // Get contacts by referral
  static Future<List<Contact>> getContactsByReferral(int referredBy) async {
    final contacts = await getContacts();
    return contacts.where((c) => 
      c.referredBy == referredBy
    ).toList();
  }
  
  // Get contacts by district
  static Future<List<Contact>> getContactsByDistrict(int districtId) async {
    final contacts = await getContacts();
    return contacts.where((c) => 
      c.district == districtId
    ).toList();
  }
  
  // Get contacts by assembly constituency
  static Future<List<Contact>> getContactsByAssemblyConstituency(int constituencyId) async {
    final contacts = await getContacts();
    return contacts.where((c) => 
      c.assemblyConstituency == constituencyId
    ).toList();
  }
  
  // Get contacts by booth
  static Future<List<Contact>> getContactsByBooth(int boothId) async {
    final contacts = await getContacts();
    return contacts.where((c) => 
      c.booth == boothId
    ).toList();
  }
  
  // Search contacts by name, phone, or email
  static Future<List<Contact>> searchContacts(String query) async {
    final contacts = await getContacts();
    final lowercaseQuery = query.toLowerCase();
    
    return contacts.where((c) => 
      c.name.toLowerCase().contains(lowercaseQuery) ||
      c.phone.contains(query) ||
      (c.email?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }
  
  // Get last sync timestamp
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
  
  // Clear all contacts
  static Future<bool> clearAllContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove(_primaryContactsKey);
      await prefs.remove(_allContactsKey);
      await prefs.remove(_lastSyncKey);
      return true;
    } catch (e) {
      debugPrint('Error clearing contacts: $e');
      return false;
    }
  }
  
  // Validate contact data
  static void _validateContact(Contact contact) {
    // Validate priority for primary contacts
    if (contact.isPrimaryContact && contact.priority != null) {
      if (contact.priority! < 1 || contact.priority! > 5) {
        throw ArgumentError('Priority for primary contacts must be between 1 and 5');
      }
    }
    
    // Validate required fields
    if (contact.firstName.trim().isEmpty) {
      throw ArgumentError('First name is required');
    }
    
    if (contact.phone.trim().isEmpty) {
      throw ArgumentError('Phone number is required');
    }
    
    if (contact.countryCode.trim().isEmpty) {
      throw ArgumentError('Country code is required');
    }
  }
  
  // Get contact statistics
  static Future<Map<String, int>> getContactStatistics() async {
    final contacts = await getContacts();
    final primaryContacts = contacts.where((c) => c.isPrimaryContact).length;
    final allContacts = contacts.length;
    final contactsWithEmail = contacts.where((c) => c.email != null && c.email!.isNotEmpty).length;
    final contactsWithAddress = contacts.where((c) => c.fullAddress.isNotEmpty).length;
    
    return {
      'total': allContacts,
      'primary': primaryContacts,
      'withEmail': contactsWithEmail,
      'withAddress': contactsWithAddress,
    };
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
  
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}