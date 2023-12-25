import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:location/location.dart';
import '../constants.dart';
import 'location_service.dart';

class LoginService {
  Future<String?> loginUser(String username, String password) async {
    try {
      final Uri loginUri = Uri.parse("${Constants.apiUrl}/api/crfr/users/signin/");


      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $fcmToken');

      LocationData? location = await LocationService().determineLocation();
      if (fcmToken != null && location != null) {

        final response = await http.post(
          loginUri,
          body: jsonEncode({
            'username': username,
            'password': password,
            'deviceToken': fcmToken,
            'location': {
              'lat': location.latitude,
              'lng': location.longitude,
            },
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final String authToken = responseData['data']['authtoken'];
          final String type = responseData['data']['type'];
          final String userid = responseData['data']['id'];

          await saveUserData(username, userid, type, fcmToken, authToken);

          if (authToken != null) {
            LocationService().startSendingLocation();
          }
          return authToken;
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

  Future<void> saveUserData(String username, String userid, String type, String fcmToken, String authToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('userid', userid);
    await prefs.setString('type', type);
    await prefs.setString('fcm_token', fcmToken);
    await prefs.setString('auth_token', authToken);
  }

  Future<void> logoutUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('type');
    await prefs.remove('userid');
    await prefs.remove('fcm_token');
    await prefs.remove('auth_token');
  }
}
