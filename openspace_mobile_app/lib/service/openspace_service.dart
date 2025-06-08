import 'package:graphql_flutter/graphql_flutter.dart';
import '../api/graphql/graphql_service.dart';
import '../api/graphql/openspace_query.dart';

class OpenSpaceService {
  final GraphQLService _graphQLService = GraphQLService();

  Future<List<Map<String, dynamic>>> getAllOpenSpaces() async {
    try {
      final QueryResult result = await _graphQLService.query(getAllOpenSpacesQuery);

      if (result.hasException) {
        final exception = result.exception!;

        // Network errors
        if (exception.linkException != null) {
          final msg = exception.linkException.toString();
          if (msg.contains('SocketException')) {
            throw Exception("Connection error: Unable to reach server. Please check your internet.");
          } else if (msg.contains('TimeoutException')) {
            throw Exception("Timeout: The server took too long to respond.");
          } else {
            throw Exception("Unexpected network issue. Try again later.");
          }
        }

        // GraphQL errors
        if (exception.graphqlErrors.isNotEmpty) {
          throw Exception("GraphQL error: ${exception.graphqlErrors.first.message}");
        }

        throw Exception("An unknown error occurred while fetching open spaces.");
      }

      final spaces = result.data?['allOpenSpacesUser'] as List<dynamic>?;

      if (spaces == null || spaces.isEmpty) return [];

      return spaces.cast<Map<String, dynamic>>();
    } catch (e) {
      // Strip "Exception: " prefix if it exists
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      throw Exception(msg);
    }
  }
}
