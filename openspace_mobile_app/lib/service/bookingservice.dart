// service/bookingservice.dart
import 'dart:convert';
import 'dart:io'; // For File
import 'package:http/http.dart' as http;
import 'package:openspace_mobile_app/model/Booking.dart';

import 'auth_service.dart';


class BookingService {
  // static const String _baseUrl = "http://192.168.1.169:8000"; // Android Emulator to local Django
  static const String _baseUrl = "http://127.0.0.1:8000"; // iOS Sim / Desktop to local Django
  // static const String _baseUrl = "http://YOUR_DEPLOYED_API_DOMAIN.COM"; // For deployed API

  static const String _createBookingEndpoint = "/api/v1/book-open-space/";
  static const String _myBookingsEndpoint = "/api/v1/my-bookings/";

  String? _lastError;
  String? get getLastError => _lastError;

  Future<String?> _getAuthToken() async {
    _lastError = null;
    final String? token = await AuthService.getToken();
    if (token == null) {
      _lastError = 'Authentication token not found. Please log in.';
      print('BookingService: $_lastError');
    }
    return token;
  }

  Future<bool> createBooking({
    required int spaceId,         // Corresponds to 'space' ForeignKey (ID)
    required String username,      // Corresponds to 'username' CharField
    required String contact,       // Corresponds to 'contact' CharField
    required String startDate,     // Corresponds to 'startdate' DateField (format "YYYY-MM-DD")
    String? endDate,              // Corresponds to 'enddate' DateField (format "YYYY-MM-DD"), nullable
    required String purpose,       // Corresponds to 'purpose' TextField
    required String district,      // Corresponds to 'district' CharField
    File? file,                   // Corresponds to 'file' FileField, nullable
  }) async {
    _lastError = null;
    final String? token = await _getAuthToken();
    if (token == null) {
      throw Exception(_lastError ?? 'Authentication required.');
    }

    final Uri url = Uri.parse('$_baseUrl$_createBookingEndpoint');
    print('BookingService: Creating booking at $url');

    try {
      http.Response response;
      final Map<String, String> commonHeaders = {
        'Authorization': 'Bearer $token',
      };

      // Fields for the request, matching Django model
      final Map<String, String> fields = {
        'space': spaceId.toString(), // Django expects the ID for ForeignKey
        'username': username,
        'contact': contact,
        'startdate': startDate, // Send as "YYYY-MM-DD"
        'purpose': purpose,
        'district': district,
      };
      if (endDate != null && endDate.isNotEmpty) {
        fields['enddate'] = endDate; // Send as "YYYY-MM-DD"
      }

      if (file != null) {
        var request = http.MultipartRequest('POST', url);
        request.headers.addAll(commonHeaders);
        request.fields.addAll(fields);
        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // Key 'file' must match Django model's FileField name
            file.path,
          ),
        );
        print('BookingService: Sending multipart request with fields: ${request.fields} and file: ${file.path}');
        var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
        response = await http.Response.fromStream(streamedResponse);
      } else {
        final Map<String, String> headers = {
          ...commonHeaders,
          'Content-Type': 'application/json; charset=UTF-8',
        };
        print('BookingService: Sending JSON request with body: ${jsonEncode(fields)}');
        response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(fields),
        ).timeout(const Duration(seconds: 30));
      }

      print('BookingService: CreateBooking Response Status: ${response.statusCode}');
      print('BookingService: CreateBooking Response Body: ${response.body}');

      if (response.statusCode == 201) { // 201 Created
        print('BookingService: Booking created successfully.');
        return true;
      } else {
        // ... (error handling remains the same as previously provided) ...
        String serverMessage = "Failed to create booking.";
        try {
          final decodedBody = jsonDecode(response.body);
          if (decodedBody is Map) {
            if (decodedBody.containsKey('detail')) {
              serverMessage = decodedBody['detail'].toString();
            } else {
              StringBuffer errors = StringBuffer();
              decodedBody.forEach((key, value) {
                errors.writeln('$key: ${value is List ? value.join(', ') : value.toString()}');
              });
              serverMessage = errors.isNotEmpty ? errors.toString().trim() : jsonEncode(decodedBody);
            }
          } else if (decodedBody is List) {
            serverMessage = decodedBody.join(", ");
          } else {
            serverMessage = response.body.isNotEmpty ? response.body : "Status ${response.statusCode}";
          }
        } catch (_) {
          serverMessage = response.body.isNotEmpty ? response.body : "Status ${response.statusCode}";
        }
        _lastError = 'Failed to create booking (Status ${response.statusCode}): $serverMessage';
        print('BookingService: $_lastError');
        throw Exception(_lastError);
      }
    } on http.ClientException catch (e) {
      _lastError = 'Network error: Could not connect to create booking. (${e.message})';
      print('BookingService: ClientException: $_lastError');
      throw Exception(_lastError);
    } catch (e) {
      _lastError = 'An unexpected error occurred while creating booking: ${e.toString()}';
      print('BookingService: Error creating booking: $_lastError');
      throw Exception(_lastError);
    }
  }

  // getMyBookings method remains the same as previously provided,
  // as it correctly uses Booking.fromJson which is aligned with the Django model for fetching.
  Future<List<Booking>> getMyBookings() async {
    _lastError = null;
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception(_lastError ?? 'Authentication required.');
    }

    final Uri url = Uri.parse('$_baseUrl$_myBookingsEndpoint');
    print('BookingService: Fetching my bookings from $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print('BookingService: GetMyBookings Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Booking> bookings = body
            .map((dynamic item) => Booking.fromJson(item as Map<String, dynamic>))
            .toList();
        print('BookingService: Successfully fetched ${bookings.length} bookings.');
        return bookings;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // ... (error handling as before) ...
        String detail = "Invalid or expired token.";
        try {
          final decodedBody = jsonDecode(response.body);
          if(decodedBody is Map && decodedBody.containsKey('detail')) {
            detail = decodedBody['detail'];
          }
        } catch(_){}
        _lastError = "Authentication error (${response.statusCode}): $detail. Please log in again.";
        print('BookingService: $_lastError');
        throw Exception(_lastError);
      } else if (response.statusCode == 404) {
        print('BookingService: No bookings found for the user (404).');
        return [];
      } else {
        // ... (error handling as before) ...
        String serverMessage = "Failed to load bookings.";
        try {
          final decodedBody = jsonDecode(response.body);
          if (decodedBody is Map && decodedBody.containsKey('detail')) {
            serverMessage = decodedBody['detail'].toString();
          } else {
            serverMessage = response.body.isNotEmpty ? response.body : "Status ${response.statusCode}";
          }
        } catch (_) {
          serverMessage = response.body.isNotEmpty ? response.body : "Status ${response.statusCode}";
        }
        _lastError = 'Failed to load bookings (Status ${response.statusCode}): $serverMessage';
        print('BookingService: $_lastError');
        throw Exception(_lastError);
      }
    } on http.ClientException catch (e) {
      _lastError = 'Network error while fetching bookings: Could not connect. (${e.message})';
      print('BookingService: ClientException fetching bookings: $_lastError');
      throw Exception(_lastError);
    } catch (e) {
      _lastError = 'An unexpected error occurred while fetching bookings: ${e.toString()}';
      print('BookingService: Error fetching bookings: $_lastError');
      throw Exception(_lastError);
    }
  }
}