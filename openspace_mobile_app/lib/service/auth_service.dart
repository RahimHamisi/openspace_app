import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/graphql/auth_mutation.dart';
import '../api/graphql/graphql_service.dart';
import '../model/user_model.dart';

class AuthService {
  final GraphQLService _graphQLService = GraphQLService();

  static const String _tokenKey = 'auth_access_token';

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


  Future<Map<String, dynamic>?> login(String username, String password, {int retryCount = 3}) async {
    int attempts = 0;
    while (attempts < retryCount) {
      attempts++;
      try {
        print('AuthService: Login attempt $attempts/$retryCount for username: $username');
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
          print('AuthService Login Exception: ${result.exception}');
          if (result.exception.toString().contains('TimeoutException') && attempts < retryCount) {
            print('AuthService: Timeout detected, retrying after 2s...');
            await Future.delayed(Duration(seconds: 2));
            continue;
          }
          throw Exception("Login failed: ${result.exception.toString()}");
        }

        final output = result.data?['loginUser']?['output'];
        print('AuthService Login response output: $output');

        if (output == null || output['success'] != true) {
          throw Exception(output?['message'] ?? "Login failed, no success response.");
        }

        final accessToken = output['user']?['accessToken'] as String?;
        final refreshToken = output['user']?['refreshToken'] as String?;
        if (accessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, accessToken);
          print('AuthService: AccessToken stored successfully: $accessToken');
        } else {
          print('AuthService Warning: No accessToken found in login response');
          throw Exception('Login successful, no accessToken found.');
        }

        return output;
      } catch (e) {
        print('AuthService Login Error (Attempt $attempts/$retryCount): $e');
        if (e.toString().contains('TimeoutException') && attempts < retryCount) {
          await Future.delayed(Duration(seconds: 2));
          continue;
        }
        if (e.toString().contains('SocketException')) {
          throw Exception('Network error: Please check your internet connection.');
        }
        throw Exception('Login failed: $e');
      }
    }
    throw Exception('Login failed after $retryCount attempts due to timeout.');
  }

  /// Retrieves the stored authentication token.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    print('AuthService: Retrieving token from SharedPreferences');
    print('AuthService: Token: ${prefs.getString(_tokenKey)}');
    return prefs.getString(_tokenKey);
  }

  /// Removes the stored authentication token (logout).
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('AuthService: Token removed (logged out).');
  }
}

// Mock GraphQLService and QueryResult for compilation
class _MockGraphQLService {
  Future<_MockQueryResult> mutate(String query, {Map<String, dynamic>? variables}) async {
    print("MockGraphQLService: mutate called with query: $query, variables: $variables");
    // Simulate a successful login response structure
    if (query.contains("loginUser")) {
      return _MockQueryResult(
        data: {
          "loginUser": {
            "output": {
              "message": "Login successful (mock)",
              "success": true,
              "user": {
                "id": "mockUserId",
                "isStaff": false,
                "isWardExecutive": false,
                "refreshToken": "mockRefreshTokenValue",
                "username": variables?["input"]?["username"] ?? "mockUser",
                "accessToken": "mockAccessTokenValueFromGraphQL" // This is what we need
              }
            }
          }
        },
      );
    }
    return _MockQueryResult(data: null, exception: Exception("Unknown mock mutation"));
  }
}

class _MockQueryResult {
  final Map<String, dynamic>? data;
  final Exception? exception;
  bool get hasException => exception != null;

  _MockQueryResult({this.data, this.exception});
}



