import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../api/graphql/graphql_service.dart';
import '../api/graphql/openspace_query.dart';
import '../model/Report.dart';

class OpenSpaceService {
  final GraphQLService _graphQLService = GraphQLService();

  Future<List<Map<String, dynamic>>> getAllOpenSpaces() async {
    try {
      final result = await _graphQLService.query(getAllOpenSpacesQuery);

      if (result.hasException) {
        final exception = result.exception!;
        if (exception.linkException != null) {
          final msg = exception.linkException.toString();
          if (msg.contains('SocketException')) {
            throw Exception(
              "Connection error: Unable to reach server. Please check your internet.",
            );
          } else if (msg.contains('TimeoutException')) {
            throw Exception("Timeout: The server took too long to respond.");
          } else {
            throw Exception("Unexpected network issue. Try again later.");
          }
        }
        if (exception.graphqlErrors.isNotEmpty) {
          throw Exception(
            "GraphQL error: ${exception.graphqlErrors.first.message}",
          );
        }
        throw Exception(
          "An unknown error occurred while fetching open spaces.",
        );
      }

      final spaces = result.data?['allOpenSpacesUser'] as List<dynamic>?;
      return spaces?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>?> createReport({
    required String description,
    String? email,
    String? filePath,
    String? spaceName,
    double? latitude,
    double? longitude,
    String? userId,
  }) async {
    const String createReportMutation = """
    mutation CreateReport(\$description: String!, \$email: String, \$filePath: String, \$spaceName: String, \$latitude: Float, \$longitude: Float, \$userId: ID) {
      createReport(description: \$description, email: \$email, filePath: \$filePath, spaceName: \$spaceName, latitude: \$latitude, longitude: \$longitude, userId: \$userId) {
        report {
          reportId
          description
          email
          file
          createdAt
          latitude
          longitude
        }
      }
    }
  """;

    try {
      final result = await _graphQLService.mutate(
        createReportMutation,
        variables: {
          'description': description,
          if (email != null) 'email': email,
          if (filePath != null) 'filePath': filePath,
          if (spaceName != null) 'spaceName': spaceName,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (userId != null) 'userId': userId,
        },
      );

      // 🚨 Log any GraphQL exception but continue if data is usable
      if (result.hasException) {
        final exception = result.exception!;
        if (exception.linkException != null) {
          throw Exception("Network error: ${exception.linkException}");
        }

        // Print all graphql errors for debugging
        for (final err in exception.graphqlErrors) {
          debugPrint("[GraphQL Error] ${err.message}");
        }

        // Still allow if data is available
        final data = result.data;
        if (data != null &&
            data['createReport'] != null &&
            data['createReport']['report'] != null &&
            data['createReport']['report']['reportId'] != null) {
          debugPrint("Report created despite GraphQL errors.");
          return data['createReport']['report'] as Map<String, dynamic>;
        }

        // If no data is returned, treat as failure
        throw Exception("GraphQL error: ${exception.graphqlErrors.firstOrNull?.message ?? 'Unknown error'}");
      }

      // ✅ Success path
      return result.data?['createReport']['report'] as Map<String, dynamic>?;
    } catch (e) {
      // Log unexpected client-side errors
      debugPrint("Exception in createReport: $e");
      throw Exception(
        e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
      );
    }
  }




  Future<List<Report>> getAllReports() async {
    const String getAllReportsQuery = """
      query MyQuery {
        allReports {
          id
          description
          createdAt
          latitude
          longitude
          reportId
          spaceName
          file
        
        }
      }
    """;
    final Duration _queryTimeout = const Duration(seconds: 30);

    try {
      final result = await _graphQLService
          .query(getAllReportsQuery)
          .timeout(_queryTimeout);

      if (result.hasException) {
        final exception = result.exception!;
        if (exception.linkException != null) {
          final linkExString = exception.linkException.toString().toLowerCase();
          if (linkExString.contains('timeout') ||
              linkExString.contains('timed out')) {
            throw Exception("Fetching reports timed out. Please try again.");
          } else if (linkExString.contains('socketexception') ||
              linkExString.contains('httpexception') ||
              linkExString.contains('failed host lookup')) {
            throw Exception(
              "Network issue fetching reports. Check your connection.",
            );
          }
          throw Exception("A network error occurred while fetching reports.");
        }
        if (exception.graphqlErrors.isNotEmpty) {
          throw Exception(
            "Error from server: ${exception.graphqlErrors.first.message}",
          );
        }
        throw Exception(
          "Failed to fetch reports due to an unexpected server error.",
        );
      }

      if (result.data == null || result.data!['allReports'] == null) {
        return [];
      }

      final List<dynamic> reportsData =
          result.data!['allReports'] as List<dynamic>;
      return reportsData
          .map((data) => Report.fromJson(data as Map<String, dynamic>))
          .toList();
    } on TimeoutException catch (_) {
      throw Exception("Fetching reports timed out. Please try again.");
    } catch (e) {
      String errorMessage = e.toString().replaceFirst(
        RegExp(r'^Exception:\s*'),
        '',
      );
      if (errorMessage.contains("timed out") ||
          errorMessage.contains("Network issue") ||
          errorMessage.contains("Error from server")) {
        throw Exception(errorMessage);
      }
      throw Exception(
        "An error occurred while fetching reports: $errorMessage",
      );
    }
  }

  Future<Report?> getReportById(String reportId) async {
    const String getReportByIdQuery = """
      query GetReportById(\$reportId: String!) {
        reportById(reportId: \$reportId) {
          id
          description
          createdAt
          latitude
          longitude
          reportId
          spaceName
          file
          type
          status
        }
      }
    """;
    final Duration _queryTimeout = const Duration(seconds: 30);

    try {
      final result = await _graphQLService
          .query(getReportByIdQuery, variables: {'reportId': reportId})
          .timeout(_queryTimeout);

      if (result.hasException) {
        final exception = result.exception!;
        if (exception.linkException != null) {
          final linkExString = exception.linkException.toString().toLowerCase();
          if (linkExString.contains('timeout') ||
              linkExString.contains('timed out')) {
            throw Exception("Fetching report timed out. Please try again.");
          } else if (linkExString.contains('socketexception') ||
              linkExString.contains('httpexception') ||
              linkExString.contains('failed host lookup')) {
            throw Exception(
              "Network issue fetching report. Check your connection.",
            );
          }
          throw Exception("A network error occurred while fetching report.");
        }
        if (exception.graphqlErrors.isNotEmpty) {
          throw Exception(
            "Error from server: ${exception.graphqlErrors.first.message}",
          );
        }
        throw Exception(
          "Failed to fetch report due to an unexpected server error.",
        );
      }

      if (result.data == null || result.data!['reportById'] == null) {
        return null;
      }

      return Report.fromJson(
        result.data!['reportById'] as Map<String, dynamic>,
      );
    } on TimeoutException catch (_) {
      throw Exception("Fetching report timed out. Please try again.");
    } catch (e) {
      String errorMessage = e.toString().replaceFirst(
        RegExp(r'^Exception:\s*'),
        '',
      );
      throw Exception(errorMessage);
    }
  }
}
