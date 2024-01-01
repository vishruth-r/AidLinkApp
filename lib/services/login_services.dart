import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:location/location.dart';
import '../constants.dart';
import 'location_service.dart';

class LoginService {
  Future<Map<String, String>?> loginUser(String username, String password) async {
    try {
      final Uri loginUri = Uri.parse("${Constants.apiUrl}/api/crfr/users/signin/");

      //String? fcmToken = await FirebaseMessaging.instance.getToken();
      //print('FCM Token: $fcmToken');

     // LocationData? location = await LocationService().determineLocation();
      //print(location.latitude);
      //print(location.longitude);
      if (username != null) { // change to fcm token and location not null
        final response = await http.post(
          loginUri,
          body: jsonEncode({
            'username': username,
            'password': password,
            'devicetoken': 'fcmToken',
            'location': {
              'lat': '13.34',
              'lng': '80.87',
            },
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final String authToken = responseData['data']['authtoken'];
          final String type = responseData['data']['type'];
          final String userid = responseData['data']['id'];
          final List<dynamic> dutyLocation = responseData['data']['dutylocation'];
          final String name = responseData['data']['name'];
          final String typeDescription = responseData['data']['typedescription'];
          final String reportingTo = responseData['data']['reportingto'];

          await saveUserData(username, userid, type, 'fcmToken', authToken, dutyLocation, name, typeDescription, reportingTo);


          if (authToken != null) {
            LocationService().startSendingLocation();
          }

          return {'authToken': authToken, 'type': type};
        } else {
          print(response.statusCode);
          print(response.body);
          return null;
        }
      } else {
        print('FCM Token or location is null. Unable to proceed with login.');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }
  Future<void> saveUserData(String username, String userid, String type, String fcmToken, String authToken,List<dynamic> dutyLocation,String name, String typeDescription, String reportingTo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('userid', userid);
    await prefs.setString('type', type);
    await prefs.setString('fcm_token', fcmToken);
    await prefs.setString('auth_token', authToken);
    await prefs.setString('duty_location', '${dutyLocation[0]},${dutyLocation[1]}');
    await prefs.setString('name', name);
    await prefs.setString('type_description', typeDescription);
    await prefs.setString('reporting_to', reportingTo);

  }

  Future<void> logoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the user token from SharedPreferences
    String? token = prefs.getString('auth_token');

    // Define the API endpoint for the logout request
    String apiUrl = '${Constants.apiUrl}/api/crfr/users/signout/';

    try {
      // Prepare the data to be sent in the request body
      Map<String, dynamic> requestData = {
        // Add any additional data if required
      };

      // Convert the requestData to JSON
      String requestBody = jsonEncode(requestData);

      // Make a POST request to the API endpoint
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
          // Add any additional headers if required
        },
        body: requestBody,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Clear SharedPreferences data after successful logout API call
        await prefs.remove('username');
        await prefs.remove('type');
        await prefs.remove('userid');
        await prefs.remove('fcm_token');
        await prefs.remove('auth_token');
        await prefs.remove('duty_location');
        await prefs.remove('name');
        await prefs.remove('type_description');
        await prefs.remove('reporting_to');
      } else {
        // Handle the case when the API call fails
        print('Failed to logout. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors that occur during the logout process
      print('Error occurred while logging out: $e');
    }
  }
}
