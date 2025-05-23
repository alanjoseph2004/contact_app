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
  
  // Fetch primary contacts
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
  
  // Fetch constituencies with cities
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
  
  // Create/Save a new contact
  static Future<Map<String, dynamic>> createContact({
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
    try {
      final headers = await _getHeaders(includeContentType: true);
      
      // Format the data according to the API schema
      final Map<String, dynamic> requestBody = {
        'referred_by': referredBy,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'country_code': countryCode,
        'phone': phone,
        'note': note,
        'address': address,
        'city': city,
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
}