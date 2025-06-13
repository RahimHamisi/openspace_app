import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth_service.dart';


class ProfileService {
  static const String _baseUrl = 'https://your-api-endpoint.com'; // Replace with your REST API URL
  static const String _profileEndpoint = '/api/profile';

  static Future<Map<String, dynamic>> fetchProfile() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl$_profileEndpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load profile: ${response.statusCode} - ${response.body}');
    }
  }
}