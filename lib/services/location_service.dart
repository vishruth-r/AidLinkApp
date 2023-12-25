import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class LocationService {
  late Timer _timer;

  void startSendingLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? authToken = prefs.getString('auth_token');

    if (username != null && authToken != null) {
      _timer = Timer.periodic(Duration(minutes: 60), (timer) {
        _sendLocation(username, authToken);
      });
    } else {
      print('Username or auth token not found in shared preferences.');
    }
  }

  void _sendLocation(String username, String authToken) async {
    LocationData locationData = await determineLocation();

    final geocode = "${locationData.latitude},${locationData.longitude}";
    final payload = jsonEncode({
      "geocode": geocode,
      "mobile": username,
    });

    try {
      final Uri locationUri = Uri.parse("${Constants.apiUrl}/api/crfr/dummyurl/");

      final response = await http.post(
        locationUri,
        body: payload,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        print('Location sent successfully');
      } else {
        print('Failed to send location');
      }
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  Future<LocationData> determineLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permission;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }
    }

    permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
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
