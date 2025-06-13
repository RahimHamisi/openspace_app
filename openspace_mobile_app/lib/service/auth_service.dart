import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/graphql/auth_mutation.dart';
import '../api/graphql/graphql_service.dart';
import '../model/user_model.dart';

class AuthService {
  final GraphQLService _graphQLService = GraphQLService();

  static const String _tokenKey = 'auth_token';

  Future<User> register({
    required String username,
    required String password,
    required String confirmPassword,
    String? email,
    String? ward,
  }) async {
    final result = await _graphQLService.mutate(
      registerMutation,
      variables: {
        "input": {
          "username": username,
          "email": email ?? "",
          "password": password,
          "passwordConfirm": confirmPassword,
          "role": "user",
          "sessionId": "",
          "ward": ward ?? "",
        }
      },
    );

    if (result.hasException) {
      throw Exception("Registration failed: ${result.exception.toString()}");
    }

    final data = result.data!["registerUser"];
    final output = data["output"];

    if (output == null || output["success"] == false) {
      print(output);
      throw Exception(
          output != null ? output["message"] : "Registration failed.");
    }

    final user = output["user"] ?? data["user"];
    print(user);

    if (user == null) {
      throw Exception("Registration succeeded but no user data returned.");
    }

    return User.fromRegisterJson(user);
  }

  /// Logs in a user, stores the authentication token, and returns the output map.
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final result = await _graphQLService.mutate(
      loginMutation,
      variables: {
        "input": {
          "username": username,
          "password": password,
        },
      },
    );

    if (result.hasException) {
      throw Exception("Login failed: ${result.exception.toString()}");
    }

    final output = result.data?['loginUser']?['output'];
    print('Login response: $output'); // Debug log to verify response structure

    if (output == null || output['success'] != true) {
      throw Exception(output?['message'] ?? "Login failed, no success response.");
    }

    // Extract and store the token if present
    final token = output['token'] as String?; // Adjust 'token' key based on API response
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } else {
      print('Warning: No token found in login response');
    }

    return output; // Return the original output map for compatibility
  }

  /// Retrieves the stored authentication token.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Removes the stored authentication token (logout).
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}



