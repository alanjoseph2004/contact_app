import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ContactApiService {
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

  // Fetch all primary contacts
  Future<List<Map<String, dynamic>>> fetchPrimaryContacts() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/contact/all-primary-contacts/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['results'];
        
        return data.map((item) => {
          'id': item['id'],
          'name': '${item['contact']['first_name']} ${item['contact']['last_name'] ?? ''}',
          'phone': item['contact']['phone'],
        }).toList();
      } else {
        throw Exception('Failed to load primary contacts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching primary contacts: $e');
    }
  }

  // Fetch all constituencies with cities (reuse from PrimaryContactService if needed)
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

  // Save bulk contacts
  Future<Map<String, dynamic>> saveBulkContacts({
    required int referredBy,
    required List<Map<String, dynamic>> contacts,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Format the data according to the API schema
      final Map<String, dynamic> requestBody = {
        'referred_by': referredBy,
        'contacts': contacts,
      };

      // Make the API call
      final response = await http.post(
        Uri.parse('$baseUrl/contact/contacts/bulk-create/'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // Handle the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Contacts saved successfully!',
          'data': jsonDecode(response.body),
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to save contacts. Please try again.',
          'data': responseData,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
        'data': null,
      };
    }
  }

  // Get available cities for a specific constituency
  List<Map<String, dynamic>> getAvailableCities(
    List<Map<String, dynamic>> constituencies,
    int? constituencyId,
  ) {
    if (constituencyId != null) {
      final constituency = constituencies.firstWhere(
        (c) => c['id'] == constituencyId,
        orElse: () => {'cities': []},
      );
      
      return List<Map<String, dynamic>>.from(constituency['cities'] ?? []);
    }
    return [];
  }
}