// services/contact_api_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../screens/contact_logic.dart';

class ContactApiService {
  // API endpoints
  static const String _apiBaseUrl = 'https://contact.krisko.in';
  static const String _allContactsEndpoint = '$_apiBaseUrl/contact/all-contacts/';
  static const String _primaryContactsEndpoint = '$_apiBaseUrl/contact/all-primary-contacts/';
  static const String _timedAllContactsEndpoint = '$_apiBaseUrl/contact/contacts/timed-retrieval/';
  static const String _timedPrimaryContactsEndpoint = '$_apiBaseUrl/contact/primary-contacts/timed-retrieval/';

  /// Fetch all primary contacts from API
  static Future<List<Contact>> fetchPrimaryContacts() async {
    try {
      final response = await http.get(Uri.parse(_primaryContactsEndpoint));
      
      print('Primary contacts response status: ${response.statusCode}');
      print('Primary contacts response body: ${response.body.substring(0, min(500, response.body.length))}...');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch primary contacts: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'] ?? [];
      
      return results.map((contactData) => _buildPrimaryContactFromJson(contactData)).toList();
    } catch (e) {
      print('Error in fetchPrimaryContacts: $e');
      rethrow;
    }
  }

  /// Fetch updated primary contacts using timed retrieval
  static Future<List<Contact>> fetchUpdatedPrimaryContacts(String lastFetchTime) async {
    final encodedTimestamp = Uri.encodeComponent(lastFetchTime);
    final response = await http.get(
      Uri.parse('$_timedPrimaryContactsEndpoint?datetime=$encodedTimestamp'),
    );
    
    print('Timed retrieval response status: ${response.statusCode}');
    print('Timed retrieval response body: ${response.body.substring(0, min(200, response.body.length))}...');
    
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch updated primary contacts: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    
    if (!data.containsKey('results')) {
      throw Exception('Response is missing expected "results" key');
    }
    
    final List<dynamic> results = data['results'] ?? [];
    
    return results.map((contactData) {
      try {
        return _buildPrimaryContactFromJson(contactData);
      } catch (e) {
        print('Error processing contact: $e for data: $contactData');
        rethrow;
      }
    }).toList();
  }

  /// Fetch all contacts from API
  static Future<List<Contact>> fetchAllContacts() async {
    final response = await http.get(Uri.parse(_allContactsEndpoint));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch all contacts: ${response.statusCode}');
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    final List<dynamic> contactsData = responseData['results'] ?? [];
    
    return contactsData.map((contactData) => _buildAllContactFromJson(contactData)).toList();
  }

  /// Fetch updated all contacts using timed retrieval
  static Future<List<Contact>> fetchUpdatedAllContacts(String lastFetchTime) async {
    final encodedTimestamp = Uri.encodeComponent(lastFetchTime);
    final response = await http.get(
      Uri.parse('$_timedAllContactsEndpoint?datetime=$encodedTimestamp'),
    );
    
    print('Timed retrieval (all contacts) response status: ${response.statusCode}');
    print('Timed retrieval (all contacts) response body: ${response.body.substring(0, min(200, response.body.length))}...');
    
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch updated all contacts: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    
    if (!data.containsKey('results')) {
      throw Exception('Response is missing expected "results" key');
    }
    
    final List<dynamic> results = data['results'] ?? [];
    
    return results.map((contactData) {
      try {
        return _buildAllContactFromJson(contactData);
      } catch (e) {
        print('Error processing contact: $e for data: $contactData');
        rethrow;
      }
    }).toList();
  }

  /// Build primary contact from JSON data
  static Contact _buildPrimaryContactFromJson(Map<String, dynamic> contactData) {
    try {
      final contactObj = contactData['contact'];
      if (contactObj == null) {
        throw Exception('Missing contact object in response');
      }
      
      // Handle tags properly - extract tag names or IDs
      List<int>? tagList;
      if (contactObj['tags'] != null && contactObj['tags'] is List) {
        tagList = (contactObj['tags'] as List)
            .where((tag) => tag is Map<String, dynamic>)
            .map((tag) {
              // Since the API returns tag objects with names, we'll use a hash of the name as ID
              // or you can create a mapping system
              final tagName = tag['tag_name'] as String?;
              return tagName?.hashCode ?? 0;
            })
            .where((id) => id != 0)
            .toList();
      }
      
      // Handle referral details properly
      Map<String, dynamic>? referralDetails;
      if (contactData['connection'] != null && contactData['connection'] is Map) {
        referralDetails = {
          'connection_id': contactData['connection']['id'] ?? contactData['id'],
          'connection': contactData['connection']['connection'],
        };
      }
      
      // Helper function to safely extract ID from nested objects
      int? _extractIdFromNestedObject(dynamic obj) {
        if (obj == null) return null;
        if (obj is int) return obj;
        if (obj is Map<String, dynamic>) {
          return obj['id'] as int?;
        }
        return null;
      }
      
      return Contact(
        id: contactObj['id'] as int,
        referredBy: _extractIdFromNestedObject(contactObj['referred_by']),
        firstName: contactObj['first_name'] ?? '',
        lastName: contactObj['last_name'],
        email: contactObj['email'],
        countryCode: contactObj['country_code'] ?? '',
        phone: contactObj['phone'] ?? '',
        note: contactObj['note'],
        district: _extractIdFromNestedObject(contactObj['district']),
        assemblyConstituency: _extractIdFromNestedObject(contactObj['assembly_constituency']),
        partyBlock: _extractIdFromNestedObject(contactObj['party_block']),
        partyConstituency: _extractIdFromNestedObject(contactObj['party_constituency']),
        booth: _extractIdFromNestedObject(contactObj['booth']),
        parliamentaryConstituency: _extractIdFromNestedObject(contactObj['parliamentary_constituency']),
        localBody: _extractIdFromNestedObject(contactObj['local_body']),
        ward: _extractIdFromNestedObject(contactObj['ward']),
        houseName: contactObj['house_name'],
        houseNumber: contactObj['house_number'] as int?,
        city: contactObj['city'],
        postOffice: contactObj['post_office'],
        pinCode: contactObj['pin_code'],
        tags: tagList,
        isPrimaryContact: true,
        avatarUrl: contactObj['avatar_url'],
        hasMessages: false,
        type: ContactType.primary,
        priority: contactData['priority'] as int?,
        connection: contactData['connection']?['connection'],
        referralDetails: referralDetails,
        primaryContactId: contactData['id'] as int?, // Use the primary contact ID from the root level
      );
    } catch (e) {
      print('Error in _buildPrimaryContactFromJson: $e');
      print('ContactData: $contactData');
      rethrow;
    }
  }

  /// Build all contact from JSON data
  static Contact _buildAllContactFromJson(Map<String, dynamic> contactData) {
    try {
      // Helper function to safely extract ID from nested objects
      int? _extractIdFromNestedObject(dynamic obj) {
        if (obj == null) return null;
        if (obj is int) return obj;
        if (obj is Map<String, dynamic>) {
          return obj['id'] as int?;
        }
        return null;
      }
      
      // Handle tags properly - extract tag names or IDs
      List<int>? tagList;
      if (contactData['tags'] != null && contactData['tags'] is List) {
        tagList = (contactData['tags'] as List)
            .where((tag) => tag is Map<String, dynamic>)
            .map((tag) {
              // Since the API returns tag objects with names, we'll use a hash of the name as ID
              final tagName = tag['tag_name'] as String?;
              return tagName?.hashCode ?? 0;
            })
            .where((id) => id != 0)
            .toList();
      }
      
      // Handle referral details properly
      Map<String, dynamic>? referralDetails;
      if (contactData['referred_by'] != null && contactData['referred_by'] is Map) {
        final referredBy = contactData['referred_by'] as Map<String, dynamic>;
        referralDetails = {
          'referred_id': referredBy['id'],
          'referred_first_name': referredBy['first_name'],
          'referred_last_name': referredBy['last_name'],
          'referred_country_code': referredBy['country_code'],
          'referred_phone': referredBy['phone'],
        };
      }
      
      return Contact(
        id: contactData['id'] as int,
        referredBy: _extractIdFromNestedObject(contactData['referred_by']),
        firstName: contactData['first_name'] ?? '',
        lastName: contactData['last_name'],
        email: contactData['email'],
        countryCode: contactData['country_code'] ?? '',
        phone: contactData['phone'] ?? '',
        note: contactData['note'],
        district: _extractIdFromNestedObject(contactData['district']),
        assemblyConstituency: _extractIdFromNestedObject(contactData['assembly_constituency']),
        partyBlock: _extractIdFromNestedObject(contactData['party_block']),
        partyConstituency: _extractIdFromNestedObject(contactData['party_constituency']),
        booth: _extractIdFromNestedObject(contactData['booth']),
        parliamentaryConstituency: _extractIdFromNestedObject(contactData['parliamentary_constituency']),
        localBody: _extractIdFromNestedObject(contactData['local_body']),
        ward: _extractIdFromNestedObject(contactData['ward']),
        houseName: contactData['house_name'],
        houseNumber: contactData['house_number'] as int?,
        city: contactData['city'],
        postOffice: contactData['post_office'],
        pinCode: contactData['pin_code'],
        tags: tagList,
        isPrimaryContact: contactData['is_primary_contact'] ?? false,
        avatarUrl: contactData['avatar_url'],
        hasMessages: false,
        type: ContactType.all,
        priority: null,
        connection: null,
        referralDetails: referralDetails,
      );
    } catch (e) {
      print('Error in _buildAllContactFromJson: $e');
      print('ContactData: $contactData');
      rethrow;
    }
  }
}