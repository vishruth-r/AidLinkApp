import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';


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
    double lat = locationData.latitude ?? 0.0;
    double lng = locationData.longitude ?? 0.0;

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
  }Future<List<Map<String, dynamic>>?> getFRAlerts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    print('Token: $token');

    if (token == null) {
      print('Token not found');
      return null; // Return null if token is not available
    }

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/api/crfr/alerts/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Use 'Authorization' instead of 'Bearer'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> alerts = json.decode(response.body)['data'];
        List<Map<String, dynamic>> formattedAlerts = [];

        for (var alert in alerts) {
          String formattedDate = formatDateTime(alert['at']);
          int alertType = alert['type'];

          formattedAlerts.add({
            'id': alert['_id'],
            'title': alert['title'],
            'statusDescription': alert['statusdescription'],
            'at': formattedDate,
            'type': alertType,
            'status' : alert['status'],
            'name'  : alert['by']['name'],
            'mobile' : alert['by']['mobile'],
            'location' : alert['from'],
            'ambulance' : alert['ambulance'] ?? 'Not assigned',
            'statusdescription' : alert['statusdescription'],
            'docstatus' : alert['docstatus']['status'],
            'docstatusdescription' : alert['docstatus']['description'],
          });
        }

        print('Formatted alerts: $formattedAlerts');
        return formattedAlerts;
      } else {
        print('Failed to fetch alerts. Status code: ${response.statusCode}');
        return null; // Return null in case of failure
      }
    } catch (e) {
      print('Exception while fetching alerts: $e');
      return null; // Return null in case of exceptions
    }
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('hh:mm a').format(dateTime.toLocal());
  }

}
