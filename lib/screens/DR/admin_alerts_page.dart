import 'package:aidlink/screens/maps_page.dart';
import 'package:aidlink/services/admin_services.dart';
import 'package:aidlink/services/login_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/FR_services.dart';
import '../login_page.dart';

class AdminAlertsPage extends StatefulWidget {
  @override
  _AdminAlertsPageState createState() => _AdminAlertsPageState();
}

class _AdminAlertsPageState extends State<AdminAlertsPage> {
  String? dutyLocation;
  String? typeDescription;
  String? name;
  String? reportingTo;
  FRServices _frServices = FRServices();
  MapService _mapService = MapService();


  List<Map<String, dynamic>> emergencyAlerts = [];
  List<Map<String, dynamic>> bleedingAlerts = [];
  List<Map<String, dynamic>> dehydrationAlerts = [];
  List<Map<String, dynamic>> socialThreatAlerts = [];


  @override
  void initState() {
    super.initState();
    _fetchAlerts();
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

  Future<void> _fetchAlerts() async {
    try {
      List<Map<String, dynamic>>? fetchedAlerts = await _frServices
          .getFRAlerts();
      if (fetchedAlerts != null) {
        setState(() {
          // Filter alerts according to their types
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
    } catch (e) {
      print('Exception while fetching alerts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alerts'),
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
                    color: Colors.blue,
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
                      color: Colors.blue,
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
            onTap: () async {
              await LoginService().logoutUser();
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
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorWeight: 2.0,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12
              ),
              tabs: [
                Tab(text: 'Emergency',icon: Icon(Icons.warning, color: Colors.red)),
                Tab(text: 'Injury',
                    icon: Icon(Icons.local_hospital, color: Colors.orange)),
                Tab(text: 'Dehydration',
                    icon: Icon(Icons.water_drop_outlined, color: Colors.blue)),
                Tab(text: 'Social Threat',
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

  @override
  Widget _buildAlertsList(List<Map<String, dynamic>> alerts) {
    if (alerts.isEmpty) {
      return Center(
        child: Text('No alerts found'),
      );
    }
    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        bool isAmbulanceAssigned = alert['ambulance'] is Map<String, dynamic>;

        return Card(
          margin: EdgeInsets.all(8.0),
          elevation: 4.0,
          color: Colors.white,
          child: Stack(
            children: [
              ListTile(
                title: Text('${alert['title']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${alert['at']}'),
                    Text('${alert['statusDescription']}'),
                    Text('${alert['name']}'),
                    if (isAmbulanceAssigned)
                      Text(' ${alert['ambulance']['name']}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            String latLong = '${alert['location'][1]},${alert['location'][0]}';
                            _launchMaps(latLong);
                          },
                          icon: Transform.rotate(
                            angle: 45 * (3.1415926535 / 180),
                            child: Icon(Icons.navigation, color: Colors.blue),
                          ),
                        ),

                        IconButton(
                          icon: Icon(Icons.phone, color: Colors.green),
                          onPressed: () {
                            print("Phone number: ${alert['FRmobile']}");
                            String phone = '${alert['FRmobile']}';
                            _makePhoneCall(phone);
                          },
                        ),
                        if (isAmbulanceAssigned)
                          IconButton(
                            icon: Icon(Icons.directions_bus, color: Colors.orange),
                            onPressed: () {
                              _makePhoneCall(alert['ambulance']['mobile']);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
                onTap: isAmbulanceAssigned ? null : () async {
                  if (!isAmbulanceAssigned) {
                    List<Map<String, dynamic>>? ambulanceDetails = await _mapService.getUsersList(
                      fr: false,
                      am: true,
                      ad: false,
                      al: false,
                      as: false,
                    );
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return _buildAmbulanceDetails(
                          ambulanceDetails,
                          alert['title'],
                          alert['id'],
                          alert['statusdescription'],
                          alert['status'],
                          alert['docstatusdescription'],
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
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
  }
  Widget _buildAmbulanceDetails(
      List<Map<String, dynamic>>? ambulanceDetails,
      String alertTitle,
      String alertID,
      String alertStatus,
      int docstatus,
      String docstatusDescription,

      ) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$alertTitle',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$alertStatus',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Open a Popup to perform an action
                  _showActionPopup(docstatus, docstatusDescription);
                },
                child: Text('Action'),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ambulanceDetails?.length ?? 0,
              itemBuilder: (context, index) {
                final ambulance = ambulanceDetails?[index];
                return ListTile(
                  title: Text('${ambulance?['name'] ?? ''}'),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${ambulance?['assign'] ?? ''}'),
                      ElevatedButton.icon(
                        onPressed: () {
                          _makePhoneCall(ambulance?['mobile'] ?? '');
                        },
                        icon: Icon(Icons.phone, color: Colors.green),
                        label: Text(''),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      if (ambulance != null && alertID != null) {
                        String ambulanceID = ambulance['id'] ?? '';
                        _mapService.assignAmbulanceToAlert(
                          alertID,
                          ambulanceID,
                        );
                      }
                      _fetchAlerts();
                    },
                    child: Text('Assign'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showActionPopup(int docStatus, String docStatusDescription) {
    // Example:
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$docStatusDescription'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),

              ElevatedButton(
                onPressed: () {
                  _handleDocStatusAction();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Yes'),
              ),
              // Add more buttons or widgets as needed
            ],
          ),
        );
      },
    );
  }
}

void _handleDocStatusAction() {
}
