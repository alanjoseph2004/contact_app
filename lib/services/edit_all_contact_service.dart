// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../screens/contact_logic.dart';

// class EditAllContactService {
//   static const String baseUrl = 'https://contact.krisko.in';
  
//   // Get JWT token from SharedPreferences
//   Future<String> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('jwt_token');
    
//     if (token == null || token.isEmpty) {
//       throw Exception("JWT token is missing");
//     }
    
//     return token;
//   }
  
//   // Get common headers with authorization
//   Future<Map<String, String>> _getHeaders() async {
//     final token = await _getToken();
//     return {
//       'Authorization': 'Bearer $token',
//       'Content-Type': 'application/json',
//     };
//   }
  
//   // Fetch all primary contacts
//   Future<List<Map<String, dynamic>>> fetchPrimaryContacts() async {
//     try {
//       final headers = await _getHeaders();
      
//       final response = await http.get(
//         Uri.parse('$baseUrl/all-primary-contacts/'),
//         headers: headers,
//       );
      
//       if (response.statusCode == 200) {
//         final dynamic responseData = jsonDecode(response.body);
//         final List<dynamic> data = responseData['results'];
        
//         return data.map((item) => {
//           'id': item['id'],
//           'name': '${item['contact']['first_name']} ${item['contact']['last_name'] ?? ''}',
//           'phone': item['contact']['phone'],
//         }).toList();
//       } else {
//         throw Exception('Failed to load primary contacts. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Exception in fetchPrimaryContacts: $e');
//       rethrow;
//     }
//   }
  
//   // Fetch constituencies with cities
//   Future<List<Map<String, dynamic>>> fetchConstituencies() async {
//     try {
//       final headers = await _getHeaders();
      
//       final response = await http.get(
//         Uri.parse('$baseUrl/all-cities/'),
//         headers: headers,
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
        
//         return data.map((item) => {
//           'id': item['id'],
//           'name': item['constituency'],
//           'cities': List<Map<String, dynamic>>.from(
//             item['cities'].map((city) => {
//               'id': city['id'],
//               'name': city['city'],
//             })
//           ),
//         }).toList();
//       } else {
//         throw Exception('Failed to load constituencies. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Exception in fetchConstituencies: $e');
//       rethrow;
//     }
//   }
  
//   // Update contact
//   Future<Contact> updateContact({
//     required String contactId,
//     required Map<String, dynamic> contactData,
//     required List<Map<String, dynamic>> primaryContacts,
//     required Contact originalContact,
//   }) async {
//     try {
//       final headers = await _getHeaders();
      
//       final response = await http.put(
//         Uri.parse('$baseUrl/contact/update/$contactId/'),
//         headers: headers,
//         body: jsonEncode(contactData),
//       );
      
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
        
//         // Create updated contact object based on the Contact class definition
//         return Contact(
//           id: responseData['id'].toString(),
//           firstName: responseData['first_name'],
//           lastName: responseData['last_name'],
//           countryCode: responseData['country_code'],
//           phone: responseData['phone'],
//           email: responseData['email'],
//           note: responseData['note'],
//           address: responseData['address'],
//           city: responseData['city']?.toString(),
//           constituency: responseData['constituency']?.toString(),
//           avatarUrl: originalContact.avatarUrl, // Keep existing avatar
//           hasMessages: originalContact.hasMessages, // Maintain existing value
//           type: responseData['is_primary_contact'] == true ? ContactType.primary : ContactType.all,
//           priority: null, // Only set for primary contacts via a different endpoint
//           connection: null, // Only set for primary contacts via a different endpoint
//           tags: null, // Only set for primary contacts via a different endpoint
//           isPrimary: responseData['is_primary_contact'] == true,
//           referredBy: responseData['referred_by'] != null ? {
//             'id': responseData['referred_by'],
//             // Get name from the primary contacts list
//             'name': primaryContacts.firstWhere(
//               (contact) => contact['id'] == responseData['referred_by'], 
//               orElse: () => {'name': 'Unknown'}
//             )['name'],
//           } : null,
//         );
//       } else {
//         // Try to parse error message from response
//         String errorMessage = 'Failed to update contact. Status code: ${response.statusCode}';
        
//         try {
//           final responseData = jsonDecode(response.body);
//           if (responseData['message'] != null) {
//             errorMessage = responseData['message'];
//           }
//         } catch (e) {
//           // If response body can't be parsed, use the existing error message
//         }
        
//         throw Exception(errorMessage);
//       }
//     } catch (e) {
//       print('Exception in updateContact: $e');
//       rethrow;
//     }
//   }
  
//   // Load all initial data (primary contacts and constituencies)
//   Future<Map<String, dynamic>> loadInitialData() async {
//     try {
//       final results = await Future.wait([
//         fetchPrimaryContacts(),
//         fetchConstituencies(),
//       ]);
      
//       return {
//         'primaryContacts': results[0],
//         'constituencies': results[1],
//       };
//     } catch (e) {
//       print('Exception in loadInitialData: $e');
//       rethrow;
//     }
//   }
// }