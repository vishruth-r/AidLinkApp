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

  Future<void> updateAlertStatus(String alertId, int status) async {
    print(status);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      print('Token not found in SharedPreferences');
      return;
    }

    try {
      final url = Uri.parse('${Constants.apiUrl}/api/crfr/ambulance/update'); // Replace with your API endpoint
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',},
        body: {
          'alertid': alertId,
          'status': status.toString(),
        },
      );

      if (response.statusCode == 200) {
        // Successful API call, handle response if needed
        print('Alert status updated successfully');
      } else {
        // Handle error scenario
        print('Failed to update alert status. Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception occurred while updating alert status: $e');
    }
  }
}
