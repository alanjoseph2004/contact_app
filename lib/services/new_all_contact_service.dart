import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewAllContactService {
  static const String baseUrl = 'http://51.21.152.136:8000';
  
  // Get JWT token from SharedPreferences
  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');
    
    if (token == null || token.isEmpty) {
      throw Exception("JWT token is missing");
    }
    
    return token;
  }
  
  // Get authorization headers
  static Future<Map<String, String>> _getHeaders({bool includeContentType = false}) async {
    final token = await _getToken();
    final headers = {
      'Authorization': 'Bearer $token',
    };
    
    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }
    
    return headers;
  }
  
  // Fetch all connections
  static Future<List<Map<String, dynamic>>> fetchConnections() async {
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
  static Future<List<Map<String, dynamic>>> fetchDistricts() async {
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
  static Future<List<Map<String, dynamic>>> fetchAssemblyConstituencies(int districtId) async {
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
  static Future<List<Map<String, dynamic>>> fetchParliamentaryConstituencies() async {
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

  // Fetch tag categories with tags
  static Future<List<Map<String, dynamic>>> fetchTagData() async {
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
  
  // Fetch constituencies with cities (keeping for backward compatibility)
  @deprecated
  static Future<List<Map<String, dynamic>>> fetchConstituencies() async {
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
        }).toList().cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load constituencies. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchConstituencies: $e');
      rethrow;
    }
  }
  
  // Fetch primary contacts (keeping existing method)
  static Future<List<Map<String, dynamic>>> fetchPrimaryContacts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/contact/all-primary-contacts/'),
        headers: headers,
      );

      print('Primary contacts API status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['results'];
        
        return data.map((item) => {
          'id': item['id'],
          'name': '${item['contact']['first_name']} ${item['contact']['last_name'] ?? ''}',
          'phone': item['contact']['phone'],
        }).toList().cast<Map<String, dynamic>>();
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to load primary contacts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchPrimaryContacts: $e');
      rethrow;
    }
  }
  
  // Create/Save a new contact with all fields from primary contact service (except connection and priority)
  static Future<Map<String, dynamic>> createContact({
    required int? referredBy,
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
    required List<int> tagIds,
    
    // Deprecated fields for backward compatibility
    @deprecated String? address,
    @deprecated int? cityDeprecated,
  }) async {
    try {
      final headers = await _getHeaders(includeContentType: true);
      
      // Format the data according to the updated API schema
      final Map<String, dynamic> requestBody = {
        'referred_by': referredBy,
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
        'house_name': houseName ?? address, // Use address as fallback for house_name
        'house_number': houseNumber,
        'city': city,
        'post_office': postOffice,
        'pin_code': pinCode,
        'tags': tagIds,
      };

      // Make the API call
      final response = await http.post(
        Uri.parse('$baseUrl/contact/contact/create/'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // Handle the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'Contact saved successfully!',
        };
      } else {
        // Error
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to save contact. Please try again.',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Exception in createContact: $e');
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Legacy method for backward compatibility
  @deprecated
  static Future<Map<String, dynamic>> createContactLegacy({
    required int? referredBy,
    required String firstName,
    String? lastName,
    String? email,
    required String countryCode,
    required String phone,
    String? note,
    String? address,
    required int? city,
  }) async {
    // This method is kept for backward compatibility
    // It maps the old structure to the new one with default values
    return await createContact(
      referredBy: referredBy,
      firstName: firstName,
      lastName: lastName,
      email: email,
      countryCode: countryCode,
      phone: phone,
      note: note,
      districtId: 1, // Default district ID - you should update this based on your requirements
      assemblyConstituencyId: city ?? 1, // Use the old city field as assembly constituency
      houseName: address,
      tagIds: [], // Empty tags array for legacy compatibility
      address: address,
      cityDeprecated: city,
    );
  }
}