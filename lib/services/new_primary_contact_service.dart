import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrimaryContactService {
  static const String baseUrl = 'https://contact.krisko.in';
  
  // Get JWT token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Common headers with authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception("JWT token is missing");
    }
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Fetch all connections
  Future<List<Map<String, dynamic>>> fetchConnections() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/contact/all-connections/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => {
          'id': item['id'],
          'name': item['connection'],
        }).toList();
      } else {
        throw Exception('Failed to load connections: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching connections: $e');
    }
  }

  // Fetch all districts
  Future<List<Map<String, dynamic>>> fetchDistricts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/contact/all-districts/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => {
          'id': item['id'],
          'name': item['district'] ?? item['name'], // Handle both possible field names
        }).toList();
      } else {
        throw Exception('Failed to load districts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching districts: $e');
    }
  }

  // Fetch assembly constituencies for a specific district
Future<List<Map<String, dynamic>>> fetchAssemblyConstituencies(int districtId) async {
  try {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/contact/all-assembly-constituencies/$districtId/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      // Extract the assembly_constituencies array from the response
      final List<dynamic> assemblyConstituencies = responseData['assembly_constituencies'] ?? [];
      
      return assemblyConstituencies.map((item) => {
        'id': item['id'],
        'name': item['assembly_constituency'] ?? item['name'], // Handle both possible field names
      }).toList();
    } else {
      throw Exception('Failed to load assembly constituencies: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching assembly constituencies: $e');
  }
}

  // Fetch all parliamentary constituencies
  Future<List<Map<String, dynamic>>> fetchParliamentaryConstituencies() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/contact/all-parliamentary-constituencies/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => {
          'id': item['id'],
          'name': item['parliamentary_constituency'] ?? item['name'], // Handle both possible field names
        }).toList();
      } else {
        throw Exception('Failed to load parliamentary constituencies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching parliamentary constituencies: $e');
    }
  }

  // Fetch constituencies with cities (keeping for backward compatibility)
  @deprecated
  Future<List<Map<String, dynamic>>> fetchConstituencies() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/contact/all-cities/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => {
          'id': item['id'],
          'name': item['constituency'],
          'cities': List<Map<String, dynamic>>.from(
            item['cities'].map((city) => {
              'id': city['id'],
              'name': city['city'],
            })
          ),
        }).toList();
      } else {
        throw Exception('Failed to load constituencies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching constituencies: $e');
    }
  }

  // Fetch tag categories with tags
  Future<List<Map<String, dynamic>>> fetchTagData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/contact/all-tags/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((category) => {
          'id': category['id'],
          'name': category['tag_category'],
          'tags': List<Map<String, dynamic>>.from(
            category['tags'].map((tag) => {
              'id': tag['id'],
              'name': tag['tag_name'],
            })
          ),
        }).toList();
      } else {
        throw Exception('Failed to load tag data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tag data: $e');
    }
  }

  // Create primary contact with updated API structure
  Future<bool> createPrimaryContact({
    required String firstName,
    String? lastName,
    String? email,
    required String countryCode,
    required String phone,
    String? note,
    required int districtId,
    required int assemblyConstituencyId,
    int? partyBlockId,
    int? partyConstituencyId,
    int? boothId,
    int? parliamentaryConstituencyId,
    int? localBodyId,
    int? wardId,
    String? houseName,
    int? houseNumber,
    String? city,
    String? postOffice,
    String? pinCode,
    required int priority,
    required int connectionId,
    required List<int> tagIds,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final Map<String, dynamic> requestBody = {
        'contact': {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'country_code': countryCode,
          'phone': phone,
          'note': note,
          'district': districtId,
          'assembly_constituency': assemblyConstituencyId,
          'party_block': partyBlockId,
          'party_constituency': partyConstituencyId,
          'booth': boothId,
          'parliamentary_constituency': parliamentaryConstituencyId,
          'local_body': localBodyId,
          'ward': wardId,
          'house_name': houseName,
          'house_number': houseNumber,
          'city': city,
          'post_office': postOffice,
          'pin_code': pinCode,
          'tags': tagIds,
        },
        'priority': priority,
        'connection': connectionId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/contact/primary-contact/create/'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to save contact');
      }
    } catch (e) {
      throw Exception('Error creating contact: $e');
    }
  }

  // Legacy method for backward compatibility
  @deprecated
  Future<bool> createPrimaryContactLegacy({
    required String firstName,
    String? lastName,
    String? email,
    required String countryCode,
    required String phone,
    String? note,
    String? address,
    required int cityId,
    required int constituencyId,
    required int priority,
    required int connectionId,
    required List<int> tagIds,
  }) async {
    // This method is kept for backward compatibility
    // It maps the old structure to the new one
    return await createPrimaryContact(
      firstName: firstName,
      lastName: lastName,
      email: email,
      countryCode: countryCode,
      phone: phone,
      note: note,
      districtId: constituencyId, // Mapping old constituency to district
      assemblyConstituencyId: cityId, // Mapping old city to assembly constituency
      houseName: address,
      priority: priority,
      connectionId: connectionId,
      tagIds: tagIds,
    );
  }
}