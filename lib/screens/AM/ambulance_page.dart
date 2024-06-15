import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/ambulance_services.dart';
import '../../services/fcm_services.dart';
import '../../services/login_services.dart';
import '../login_page.dart';
import '../maps_page.dart';

class AmbulancePage extends StatefulWidget {
  @override
  _AmbulancePageState createState() => _AmbulancePageState();
}


class _AmbulancePageState extends State<AmbulancePage> {
  FirebaseMessagingService _messagingService = FirebaseMessagingService();
  String? dutyLocation;
  String? typeDescription;
  String? name;
  String? reportingTo;


  AmbulanceServices ambulanceServices = AmbulanceServices();
  List<dynamic> alerts = [];
  @override
  void initState() {
    super.initState();
    _messagingService.onMessageReceived.listen((Map<String, dynamic> message) {

      fetchAlerts();
    });
    fetchAlerts();
    getUserData();
  }
  void getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      dutyLocation = prefs.getString('duty_location');
      typeDescription = prefs.getString('type_description');
      name = prefs.getString('name');
      reportingTo = prefs.getString('reporting_to');

    });
  }
  void fetchAlerts() async {
    try {
      List<dynamic> fetchedAlerts = await ambulanceServices.fetchAlerts(context);
      setState(() {
        alerts = fetchedAlerts;
      });
    } catch (e) {
      print('Error fetching alerts: $e');
      // Handle error, show error message, etc.
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Alerts',style: TextStyle(color: Colors.white)),
          actions: [
          IconButton(
            icon: Icon(Icons.location_pin),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapsPage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: UserAccountsDrawerHeader(
                      accountName: Text(
                        name!, // Replace with the user's name from SharedPreferences
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      accountEmail: Text(
                        typeDescription!, // Replace with the user's username from SharedPreferences
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.call),
                    title: Text('Helpdesk'),
                    onTap: () {
                      _makePhoneCall(reportingTo!);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.directions),
                    title: Text('Assigned Location'),
                    onTap: () {
                      _launchMaps(dutyLocation!);
                    },
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
            ),
            ListTile(
              leading: Icon(Icons.power_settings_new),
              title: Text('Logout'),
              onTap: () {
                LoginService().logoutUser(context);
              },
            ),
          ],
        ),
      ),
      body: alerts.isEmpty
        ? Center(child: Text('No Alerts')) // Display "No Alerts" message when alerts list is empty
        : ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          final alertId = alert['title'];
          final alertTime = DateTime.parse(alert['at']);
          final status = alert['statusdescription'];
          final statusColorHex = alert['statuscolor'];
          final typeDescription = alert['typedescription'];

          final istTime = alertTime.toUtc().add(Duration(hours: 5, minutes: 30));
          final formattedTime = DateFormat('hh:mm a').format(istTime);

          Color statusBackgroundColor = Colors.blue; // Default color
          if (statusColorHex != null && statusColorHex.isNotEmpty) {
            final statusColor = int.tryParse(statusColorHex);
            if (statusColor != null) {
              statusBackgroundColor = Color(statusColor);
            }
          }

          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('$alertId  $typeDescription'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$formattedTime'), // Display formatted time
                  SizedBox(height: 8), // Add space between time and status
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: statusBackgroundColor, // Background color for the label
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    ),
                    child: Text(
                      '$status',
                      style: TextStyle(
                        color: Colors.white, // Text color for the label
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      String latLong = '${alert['from'][0]},${alert['from'][1]}';
                      _launchMaps(latLong);
                    },
                    icon: Transform.rotate(
                      angle: 45 * (3.1415926535 / 180),
                      child: Icon(Icons.navigation, color: Colors.blue),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.green),
                    onPressed: () {
                      _makePhoneCall(alert['by']['mobile']);
                    },
                  ),
                ],
              ),
              onTap: () {
                _showAlertPopup(alert['nextstatus']['status'], alert['nextstatus']['description'], alert['_id']);
              },
            ),
          );
        },
      ),
    );
  }

  void _launchMaps(String latLong) async {
    String mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latLong';
    if (await canLaunch(mapsUrl)) {
      await launch(mapsUrl);
    } else {
      throw 'Could not launch $mapsUrl';
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    print("Phone number: $phoneNumber");
    String phoneUrl = 'tel:$phoneNumber';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      throw 'Could not launch $phoneUrl';
    }
  }void _showAlertPopup(int status, String statusDescription, String alertId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$statusDescription'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black87,
                      onPrimary: Colors.white,
                    ),
                    onPressed: () {
                      // Perform action on 'Cancel' button click
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black87,
                      onPrimary: Colors.white,
                    ),
                    onPressed: () async {
                      await ambulanceServices.updateAlertStatus(alertId, status);
                      Navigator.of(context).pop();
                      fetchAlerts();
                    },
                    child: Text('Yes'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
