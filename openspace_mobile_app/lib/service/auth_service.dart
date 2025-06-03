import 'package:graphql_flutter/graphql_flutter.dart';
import '../api/graphql/auth_mutation.dart';
import '../api/graphql/graphql_service.dart';
import '../model/user_model.dart';

class AuthService {
  final GraphQLService _graphQLService = GraphQLService();

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
    print(output);
    return output;
  }

}

