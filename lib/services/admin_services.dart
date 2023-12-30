  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:aidlink/constants.dart';

  class MapService {
    final String baseUrl = '${Constants.apiUrl}/api/crfr/users/filter/v2';

    Future<String> _getMobileFromPrefs() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('username') ?? '';
    }

    Future<String> _getTokenFromPrefs() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token') ?? '';
    }

    Future<List<Map<String, dynamic>>?> getUsersList({
      required bool fr,
      required bool am,
      required bool ad,
      required bool al,
      required bool as,
    }) async {
      String mobile = await _getMobileFromPrefs();
      String token = await _getTokenFromPrefs();

      final Map<String, dynamic> requestBody = {
        'mobile': mobile,
        'FR': fr ? 1 : 0,
        'AM': am ? 1 : 0,
        'AD': ad ? 1 : 0,
        'AL': al ? 1 : 0,
        'AS': as ? 1 : 0,

      };
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print("body ${response.body}");
        dynamic data = jsonDecode(response.body);
        data = data['data'];
        if (data != null) {
          print("Data: $data");
          if (data is List<dynamic>) {
            final List<Map<String, dynamic>> usersList = data.cast<
                Map<String, dynamic>>();
            print("Userslist $usersList");
            return usersList;
          } else {
            print("Data is not a List<dynamic>");
            return [];
          }
        } else {
          print("Data is null");
          return [];
        }
      }
      else {
        print("Status code: ${response.statusCode}");
        return [];
      }
    }

    Future<void> assignAmbulanceToAlert(String alertID,
        String ambulanceID) async {
      final String assignRoute = '${Constants.apiUrl}/api/crfr/doctor/assign';
      final String? token = await _getTokenFromPrefs();


      Map<String, String> requestBody = {
        'alertid': alertID,
        'ambulanceid': ambulanceID,
      };
      print("requestBody $requestBody");


      // Encode the request body to JSON
      String jsonBody = json.encode(requestBody);

      try {
        // Make the HTTP POST request
        http.Response response = await http.post(
          Uri.parse(assignRoute),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonBody,
        );
        print("token $token");

        // Check the response status
        if (response.statusCode == 200) {
          print('Assigned ambulance to alert successfully.');
        } else {
          print('Failed to assign ambulance to alert. Status code: ${response
              .statusCode}');
        }

        // For demonstration, printing the data that was sent and the response
        print('Sending request to $assignRoute with body: $jsonBody');
        print('Response: ${response.body}');
      } catch (e) {
        // Handle errors
        print('Error assigning ambulance to alert: $e');
      }
    }
    Future<void> updateAlert(String alertId, int status) async {
      print("hello world");
      String? authToken = await _getTokenFromPrefs();
      String? mobiile = await _getMobileFromPrefs();

      if (authToken != null) {
        Map<String, dynamic> requestBody = {
          "mobile": mobiile, // Replace with the actual value
          "alertid": alertId,
          "status": status
        };

        String apiUrl = '${Constants.apiUrl}/api/crfr/doctor/alert/update'; // Replace with your actual API endpoint

        try {
          final response = await http.post(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          );

          if (response.statusCode == 200) {
            // Alert updated successfully
            print('Alert updated successfully');
          } else {
            // Handle other status codes or errors
            print('Failed to update alert. Status code: ${response.statusCode}');
          }
        } catch (e) {
          // Handle any exceptions or errors during the API call
          print('Exception while updating alert: $e');
        }
      } else {
        // Handle case where auth token is not available
        print('JWT token not found');
      }
    }
  }