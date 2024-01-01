import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
class LocationService {
  late Timer _timer;

  void startSendingLocation() async {
    print("works till here start sending");

    _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('username');
      String? authToken = prefs.getString('auth_token');
      if (username == null || authToken == null) {
        _timer.cancel();
        print('Username or authToken is null. Unable to send location.');
        return;
      }

      _sendLocation(username!, authToken!, prefs);
    });
  }

  void _sendLocation(String username, String authToken, SharedPreferences prefs) async {
    LocationData locationData = await determineLocation();

    final geocode = "${locationData.latitude},${locationData.longitude}";
    final payload = jsonEncode({
      "geocode": geocode,
      "mobile": username,
      "location": {
        "lat": locationData.latitude,
        "lng": locationData.longitude,
      },
    });
    print("PAYLOAD");
    print(payload);

    try {
      final Uri locationUri = Uri.parse("${Constants.apiUrl}/api/crfr/location/");

      final response = await http.post(
        locationUri,
        body: payload,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        print("location sent");
        print('Location sent successfully');
        final locationString = "${locationData.latitude},${locationData.longitude}";
        prefs.setString('user_location', locationString);

      } else {
        print('Failed to send location. Status code: ${response.statusCode}');
        print('Failed to send location');
      }
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  Future<LocationData> determineLocation() async {
    print("calling fn");
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permission;

    serviceEnabled = await location.serviceEnabled();
    print("got the response");
    print(serviceEnabled);
    if (!serviceEnabled) {
      print("requesting service");
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print("services disabled");
        throw 'Location services are disabled.';
      }
    }

    permission = await location.hasPermission();
    print(permission);
    if (permission == PermissionStatus.denied) {
      print("denied");
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        throw 'Location permissions are denied.';
      }
    }
    return await location.getLocation();
  }

  void stopSendingLocation() {
    _timer.cancel();
  }
}
