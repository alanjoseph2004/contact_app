// services/contact_api_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../screens/contact_logic.dart';

class ContactApiService {
  // API endpoints
  static const String _apiBaseUrl = 'http://51.21.152.136:8000';
  static const String _allContactsEndpoint = '$_apiBaseUrl/contact/all-contacts/';
  static const String _primaryContactsEndpoint = '$_apiBaseUrl/contact/all-primary-contacts/';
  static const String _timedAllContactsEndpoint = '$_apiBaseUrl/contact/contacts/timed-retrieval/';
  static const String _timedPrimaryContactsEndpoint = '$_apiBaseUrl/contact/primary-contacts/timed-retrieval/';

  /// Fetch all primary contacts from API
  static Future<List<Contact>> fetchPrimaryContacts() async {
    final response = await http.get(Uri.parse(_primaryContactsEndpoint));
    
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch primary contacts: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> results = data['results'];
    
    return results.map((contactData) => _buildPrimaryContactFromJson(contactData)).toList();
  }

  // /// Fetch updated primary contacts using timed retrieval
  // static Future<List<Contact>> fetchUpdatedPrimaryContacts(String lastFetchTime) async {
  //   final encodedTimestamp = Uri.encodeComponent(lastFetchTime);
  //   final response = await http.get(
  //     Uri.parse('$_timedPrimaryContactsEndpoint?datetime=$encodedTimestamp'),
  //   );
    
  //   print('Timed retrieval response status: ${response.statusCode}');
  //   print('Timed retrieval response body: ${response.body.substring(0, min(200, response.body.length))}...');
    
  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to fetch updated primary contacts: ${response.statusCode}');
  //   }

  //   final Map<String, dynamic> data = json.decode(response.body);
    
  //   if (!data.containsKey('results')) {
  //     throw Exception('Response is missing expected "results" key');
  //   }
    
  //   final List<dynamic> results = data['results'] ?? [];
    
  //   return results.map((contactData) {
  //     try {
  //       return _buildPrimaryContactFromJson(contactData);
  //     } catch (e) {
  //       print('Error processing contact: $e for data: $contactData');
  //       rethrow;
  //     }
  //   }).toList();
  // }

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

  // /// Fetch updated all contacts using timed retrieval
  // static Future<List<Contact>> fetchUpdatedAllContacts(String lastFetchTime) async {
  //   final encodedTimestamp = Uri.encodeComponent(lastFetchTime);
  //   final response = await http.get(
  //     Uri.parse('$_timedAllContactsEndpoint?datetime=$encodedTimestamp'),
  //   );
    
  //   print('Timed retrieval (all contacts) response status: ${response.statusCode}');
  //   print('Timed retrieval (all contacts) response body: ${response.body.substring(0, min(200, response.body.length))}...');
    
  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to fetch updated all contacts: ${response.statusCode}');
  //   }

  //   final Map<String, dynamic> data = json.decode(response.body);
    
  //   if (!data.containsKey('results')) {
  //     throw Exception('Response is missing expected "results" key');
  //   }
    
  //   final List<dynamic> results = data['results'] ?? [];
    
  //   return results.map((contactData) {
  //     try {
  //       return _buildAllContactFromJson(contactData);
  //     } catch (e) {
  //       print('Error processing contact: $e for data: $contactData');
  //       rethrow;
  //     }
  //   }).toList();
  // }

  /// Build primary contact from JSON data
  static Contact _buildPrimaryContactFromJson(Map<String, dynamic> contactData) {
    final contactObj = contactData['contact'];
    if (contactObj == null) {
      throw Exception('Missing contact object in response');
    }
    
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
      priority: contactData['priority'],
      note: contactObj['note'],
      address: contactObj['address'],
      city: cityStr,
      constituency: contactObj['constituency'] ?? '',
      hasMessages: false,
      connection: connectionStr,
      tags: tagList,
      isPrimary: true,
      primaryID: contactData['id']?.toString() ?? '',
    );
  }

  /// Build all contact from JSON data
  static Contact _buildAllContactFromJson(Map<String, dynamic> contactData) {
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
      hasMessages: false,
      referredBy: referredByMap,
      isPrimary: contactData['is_primary_contact'] ?? false,
      primaryID: null,
    );
  }
}