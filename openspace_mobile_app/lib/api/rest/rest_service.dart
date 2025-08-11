import 'package:http/http.dart' as http;
import 'dart:convert';

class RestService {
  final String baseUrl = 'https://your-api.com/api/';

  Future<dynamic> getRequest(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
