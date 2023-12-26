import 'package:aidlink/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AmbulanceServices {
  static const String baseUrl = '${Constants.apiUrl}/api/crfr/alerts';

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<dynamic>> fetchAlerts() async {
    final token = await getToken();

    if (token == null) {
      // Handle case when token is not available
      return []; // Or throw an error, etc.
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      dynamic responseData = json.decode(response.body);

      if (responseData is List<dynamic>) {
        return responseData;
      } else if (responseData.containsKey('data') && responseData['data'] is List<dynamic>) {
        return responseData['data'];
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load alerts');
    }
  }
}
