// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../screens/contact_logic.dart';

// class ContactApiService {
//   static const String baseUrl = 'https://contact.krisko.in';
  
//   // Private method to get JWT token
//   Future<String> _getJwtToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? token = prefs.getString('jwt_token');
    
//     if (token == null || token.isEmpty) {
//       throw Exception("JWT token is missing");
//     }
    
//     return token;
//   }
  
//   // Private method to get headers with authorization
//   Future<Map<String, String>> _getHeaders() async {
//     final token = await _getJwtToken();
//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }
  
//   // Fetch all connections
//   Future<List<Map<String, dynamic>>> fetchConnections() async {
//     try {
//       final headers = await _getHeaders();
      
//       final response = await http.get(
//         Uri.parse('$baseUrl/contact/all-connections/'),
//         headers: headers,
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.map((item) => {
//           'id': item['id'],
//           'name': item['connection'],
//         }).toList();
//       } else {
//         throw Exception('Failed to load connections. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching connections: $e');
//     }
//   }

//   // Fetch constituencies with cities
//   Future<List<Map<String, dynamic>>> fetchConstituencies() async {
//     try {
//       final headers = await _getHeaders();
      
//       final response = await http.get(
//         Uri.parse('$baseUrl/contact/all-cities/'),
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
//       throw Exception('Error fetching constituencies: $e');
//     }
//   }

//   // Fetch tag data (categories and tags)
//   Future<List<Map<String, dynamic>>> fetchTagCategories() async {
//     try {
//       final headers = await _getHeaders();
      
//       final response = await http.get(
//         Uri.parse('$baseUrl/contact/all-tags/'),
//         headers: headers,
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.map((category) => {
//           'id': category['id'],
//           'name': category['tag_category'],
//           'tags': List<Map<String, dynamic>>.from(
//             category['tags'].map((tag) => {
//               'id': tag['id'],
//               'name': tag['tag_name'],
//             })
//           ),
//         }).toList();
//       } else {
//         throw Exception('Failed to load tag categories. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching tag categories: $e');
//     }
//   }
  
//   // Update primary contact
//   Future<Contact> updatePrimaryContact({
//     required String contactId,
//     required String firstName,
//     String? lastName,
//     String? email,
//     required String countryCode,
//     required String phone,
//     String? note,
//     String? address,
//     int? city,
//     int priority = 5,
//     int? connection,
//     required List<int> tagIds,
//     required Contact originalContact,
//   }) async {
//     try {
//       final headers = await _getHeaders();
      
//       // Format the data according to the API schema
//       final Map<String, dynamic> requestBody = {
//         'contact': {
//           'first_name': firstName,
//           'last_name': lastName,
//           'email': email,
//           'country_code': countryCode,
//           'phone': phone,
//           'note': note,
//           'address': address,
//           'city': city,
//         },
//         'priority': priority,
//         'connection': connection,
//         'tags': tagIds,
//       };
      
//       final primaryID = originalContact.primaryID ?? originalContact.id;
//       final url = '$baseUrl/contact/primary-contact/update/${int.parse(primaryID)}/';
      
//       print('Request URL: $url');
//       print('Request body: ${jsonEncode(requestBody)}');

//       final response = await http.put(
//         Uri.parse(url),
//         headers: headers,
//         body: jsonEncode(requestBody),
//       );
      
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
      
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
        
//         // Create updated contact object based on the Contact class definition
//         return Contact(
//           id: responseData['contact']['id'].toString(),
//           firstName: responseData['contact']['first_name'],
//           lastName: responseData['contact']['last_name'],
//           countryCode: responseData['contact']['country_code'],
//           phone: responseData['contact']['phone'],
//           email: responseData['contact']['email'],
//           note: responseData['contact']['note'],
//           address: responseData['contact']['address'],
//           city: responseData['contact']['city']?.toString(),
//           constituency: responseData['contact']['constituency']?.toString(),
//           avatarUrl: originalContact.avatarUrl, // Keep existing avatar
//           hasMessages: originalContact.hasMessages, // Maintain existing value
//           type: ContactType.primary,
//           priority: responseData['priority'],
//           connection: responseData['connection']?.toString(),
//           tags: responseData['tags']?.map<String>((tag) => tag.toString()).toList(),
//           isPrimary: true,
//           referredBy: null,
//           primaryID: primaryID,
//         );
//       } else {
//         String errorMessage = 'Failed to update contact. Status code: ${response.statusCode}';
//         try {
//           final responseData = jsonDecode(response.body);
//           if (responseData['message'] != null) {
//             errorMessage = '$errorMessage: ${responseData['message']}';
//           }
//         } catch (e) {
//           // If response body can't be parsed, use the existing error message
//         }
//         throw Exception(errorMessage);
//       }
//     } catch (e) {
//       throw Exception('Error updating contact: $e');
//     }
//   }
  
//   // Load all initial data at once
//   Future<Map<String, dynamic>> loadInitialData() async {
//     try {
//       final results = await Future.wait([
//         fetchConnections(),
//         fetchConstituencies(),
//         fetchTagCategories(),
//       ]);
      
//       return {
//         'connections': results[0],
//         'constituencies': results[1],
//         'tagCategories': results[2],
//       };
//     } catch (e) {
//       throw Exception('Failed to load initial data: $e');
//     }
//   }
// }