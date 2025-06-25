import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Make sure this path is correct

class ProfileService {

  static const String _baseUrl = 'http://192.168.8.233:8000/';
  static const String _profileEndpoint = 'api/v1/profile';

  static Future<Map<String, dynamic>> fetchProfile() async {
    final token = await AuthService.getToken();
    if (token == null) {
      print('ProfileService: No authentication token found. User needs to log in.');
      throw Exception('No authentication token found. Please log in again.');
    }

    final Uri profileUri = Uri.parse('$_baseUrl$_profileEndpoint');
    print('ProfileService: Fetching profile from $profileUri with token: Bearer $token');

    try {
      final response = await http.get(
        profileUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // Good practice to include
        },
      ).timeout(const Duration(seconds: 15)); // Adding a timeout

      print('ProfileService: Response Status Code: ${response.statusCode}');
      print('ProfileService: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await AuthService.logout(); // Example: force logout on auth error
        throw Exception('Authentication error : Invalid or expired token. Please log in again.');
      }
      else {
        throw Exception('Failed to load profile. Status');
      }
    } on http.ClientException catch (e) {
      print('ProfileService: ClientException - $e');
      throw Exception('Network error or server unreachable');
    } catch (e) {
      print('ProfileService: Error fetching profile');
      throw Exception('An unexpected error occurred');
    }
  }
}