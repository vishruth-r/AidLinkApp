import 'package:aidlink/screens/FR/raise_alerts_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/FR_services.dart';
import '../../services/login_services.dart';
import '../login_page.dart';
import '../maps_page.dart';

class ViewAlertsFR extends StatefulWidget {
  @override
  _ViewAlertsFRState createState() => _ViewAlertsFRState();
}

class _ViewAlertsFRState extends State<ViewAlertsFR> {
  String? dutyLocation;
  String? typeDescription;
  String? name;
  String? reportingTo;
  FRServices _frServices = FRServices();
  List<Map<String, dynamic>> emergencyAlerts = [];
  List<Map<String, dynamic>> bleedingAlerts = [];
  List<Map<String, dynamic>> dehydrationAlerts = [];
  List<Map<String, dynamic>> socialThreatAlerts = [];

  @override
  void initState() {
    super.initState();
    getUserData();
    _fetchAlerts();
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


  Future<void> _fetchAlerts() async {
    List<Map<String, dynamic>>? fetchedAlerts = await _frServices.getFRAlerts(context);
    if (fetchedAlerts != null) {
      setState(() {
        emergencyAlerts =
            fetchedAlerts.where((alert) => alert['type'] == 1).toList();
        bleedingAlerts =
            fetchedAlerts.where((alert) => alert['type'] == 2).toList();
        dehydrationAlerts =
            fetchedAlerts.where((alert) => alert['type'] == 3).toList();
        socialThreatAlerts =
            fetchedAlerts.where((alert) => alert['type'] == 4).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Alerts',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.warning),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RaiseAlertsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.location_pin),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapsPage()),
              );
            },
          )
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
                        name ?? '', // Replace with the user's name from SharedPreferences
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      accountEmail: Text(
                        typeDescription ?? '', // Replace with the user's username from SharedPreferences
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
                      _makePhoneCall(reportingTo ?? '');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.directions),
                    title: Text('Assigned Location'),
                    onTap: () {
                      _launchMaps(dutyLocation ?? '');
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body:
      DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black87,
              indicatorWeight: 2.0,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 9.0,
              ),
              tabs: [
                Tab(text: 'Emergency',
                    icon: Icon(Icons.warning, color: Colors.red)),
                Tab(text: 'Injury',
                    icon: Icon(Icons.local_hospital, color: Colors.orange)),
                Tab(text: 'Dehydration',
                    icon: Icon(Icons.water_drop_outlined, color: Colors.blue)),
                Tab(text: 'Others',
                    icon: Icon(Icons.group, color: Colors.green)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [

                  _buildAlertsList(emergencyAlerts),
                  _buildAlertsList(bleedingAlerts),
                  _buildAlertsList(dehydrationAlerts),
                  _buildAlertsList(socialThreatAlerts),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAlertsList(List<Map<String, dynamic>> alerts) {
    return alerts.isEmpty
        ? Center(
      child: Text(
        'No Alerts',
        style: TextStyle(fontSize: 24.0),
      ),
    )
        : ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        final ambulanceData = alert['ambulance'];
        final hasAmbulanceData = ambulanceData != null && ambulanceData is Map;
        final hasPhoneNumber = hasAmbulanceData && ambulanceData.containsKey('mobile');

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${alert['title']}',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '${alert['at']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Color(int.parse(alert['statusColor'])),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: Text(
                        '${alert['statusdescription']}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                if (hasPhoneNumber)
                  GestureDetector(
                    onTap: () {
                      _makePhoneCall(ambulanceData['mobile']);
                    },
                    child: Icon(
                      Icons.call,
                      color: Colors.green, // Change the color as needed
                      size: 30.0,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _makePhoneCall(String phoneNumber) async {
    print("Phone number: $phoneNumber");
    String phoneUrl = 'tel:$phoneNumber';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      throw 'Could not launch $phoneUrl';
    }
  }

  void _launchMaps(String latLong) async {
    String mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latLong';
    if (await canLaunch(mapsUrl)) {
      await launch(mapsUrl);
    } else {
      throw 'Could not launch $mapsUrl';
    }
  }
}