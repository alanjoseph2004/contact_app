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
    final contactObj = contactData['contact'];
    if (contactObj == null) {
      throw Exception('Missing contact object in response');
    }
    
    // Handle tags properly - convert to list of integers
    List<int>? tagList;
    if (contactData['tags'] != null && contactData['tags'] is List) {
      tagList = (contactData['tags'] as List)
          .map((tag) => tag['id'] as int? ?? 0)
          .where((id) => id > 0)
          .toList();
    }
    
    // Handle referral details properly
    Map<String, dynamic>? referralDetails;
    if (contactData['connection'] != null && contactData['connection'] is Map) {
      referralDetails = {
        'connection_id': contactData['connection']['id'],
        'connection': contactData['connection']['connection'],
      };
    }
    
    return Contact(
      id: contactObj['id'] as int,
      referredBy: contactObj['referred_by'] as int?,
      firstName: contactObj['first_name'] ?? '',
      lastName: contactObj['last_name'],
      email: contactObj['email'],
      countryCode: contactObj['country_code'] ?? '',
      phone: contactObj['phone'] ?? '',
      note: contactObj['note'],
      district: contactObj['district'] as int?,
      assemblyConstituency: contactObj['assembly_constituency'] as int?,
      partyBlock: contactObj['party_block'] as int?,
      partyConstituency: contactObj['party_constituency'] as int?,
      booth: contactObj['booth'] as int?,
      parliamentaryConstituency: contactObj['parliamentary_constituency'] as int?,
      localBody: contactObj['local_body'] as int?,
      ward: contactObj['ward'] as int?,
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
    );
  }

  /// Build all contact from JSON data
  static Contact _buildAllContactFromJson(Map<String, dynamic> contactData) {
    // Handle tags properly - convert to list of integers
    List<int>? tagList;
    if (contactData['tags'] != null && contactData['tags'] is List) {
      tagList = (contactData['tags'] as List)
          .map((tag) => tag['id'] as int? ?? 0)
          .where((id) => id > 0)
          .toList();
    }
    
    // Handle referral details properly
    Map<String, dynamic>? referralDetails;
    if (contactData['referred_by'] != null && contactData['referred_by'] is Map) {
      referralDetails = {
        'referred_id': contactData['referred_by']['id'],
        'referred_first_name': contactData['referred_by']['first_name'],
        'referred_last_name': contactData['referred_by']['last_name'],
        'referred_country_code': contactData['referred_by']['country_code'],
        'referred_phone': contactData['referred_by']['phone'],
      };
    }
    
    return Contact(
      id: contactData['id'] as int,
      referredBy: contactData['referred_by']?['id'] as int?,
      firstName: contactData['first_name'] ?? '',
      lastName: contactData['last_name'],
      email: contactData['email'],
      countryCode: contactData['country_code'] ?? '',
      phone: contactData['phone'] ?? '',
      note: contactData['note'],
      district: contactData['district'] as int?,
      assemblyConstituency: contactData['assembly_constituency'] as int?,
      partyBlock: contactData['party_block'] as int?,
      partyConstituency: contactData['party_constituency'] as int?,
      booth: contactData['booth'] as int?,
      parliamentaryConstituency: contactData['parliamentary_constituency'] as int?,
      localBody: contactData['local_body'] as int?,
      ward: contactData['ward'] as int?,
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
  }
}