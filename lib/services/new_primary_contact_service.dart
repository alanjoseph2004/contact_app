import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrimaryContactService {
  static const String baseUrl = 'http://51.21.152.136:8000';
  
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

  // Fetch constituencies with cities
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

  // Create primary contact
  Future<bool> createPrimaryContact({
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
          'address': address,
          'city': cityId,
          'constituency': constituencyId,
        },
        'priority': priority,
        'connection': connectionId,
        'tags': tagIds,
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
}