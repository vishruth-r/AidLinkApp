import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'location_service.dart';

class FRServices {
  Future<bool> sendAlert({
    required int type,
  }) async {
    print('Sending alert of type $type');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobile = prefs.getString('username');
    String? token = prefs.getString('auth_token');
    String? userId = prefs.getString('userid');


    LocationData? locationData = await LocationService().determineLocation();
    double lat = locationData?.latitude ?? 0.0;
    double lng = locationData?.longitude ?? 0.0;

    Map<String, dynamic> data = {
      "mobile": mobile,
      "type": type,
      "location": {
        "lat": lat,
        "lng": lng,
      },
      "userid": userId,
    };
    print(data);

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/api/crfr/alerts/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {

        print('Alert sent successfully');
        return true;
      } else {

        print('Failed to send alert. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {

      print('Exception while sending alert: $e');
    }
    return false;
  }
}
