import 'package:aidlink/screens/maps_page.dart';
import 'package:aidlink/services/admin_services.dart';
import 'package:aidlink/services/login_services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import '../../services/FR_services.dart';
import '../../services/fcm_services.dart';
import '../login_page.dart';

class AdminAlertsPage extends StatefulWidget {
  @override
  _AdminAlertsPageState createState() => _AdminAlertsPageState();
}

class _AdminAlertsPageState extends State<AdminAlertsPage> {
  bool _isDisposed = false;
  late TabController _tabController;
  FirebaseMessagingService _messagingService = FirebaseMessagingService();
  late final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;


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
    _messagingService.onMessageReceived.listen((Map<String, dynamic> message) {
      print('New alert received: $message');
      _fetchAlerts();
      _showSnackbarWithButton(message['event']['type']); // Pass type from FCM message
      _ringAndVibrate();
    });
    _fetchAlerts();
    getUserData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Dispose resources, listeners, etc.
    super.dispose();
  }

  void _showSnackbarWithButton(int type) {
    print("works snackbar");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text('New Alert Raised!'),
            ),
          ],
        ),
        duration: Duration(days: 1), // Change the duration as needed
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _stopAudio();
            _stopVibration();
            _switchToTab(type);
            },
        ),
      ),
    );
  }


  void _ringAndVibrate() async {
      await _audioPlayer.play(AssetSource('emergency-alarm.mp3'));
        _isAudioPlaying = true;
        await Vibration.vibrate(duration: 10000000, amplitude: 128, intensities: [128]);
      }


  void _stopAudio() async {
    if (_isAudioPlaying) {
      await _audioPlayer.stop();
      _isAudioPlaying = false;
    }
  }

  void _stopVibration() {
    Vibration.cancel();
  }


  void _switchToTab(int type) {
    if (type >= 1 && type <= 4) {
      _tabController.animateTo(type - 1); // Switch to the corresponding tab (0-based index)
    }
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
      List<Map<String, dynamic>>? fetchedAlerts = await _frServices.getFRAlerts();
      if (!_isDisposed) {
        setState(() {
          if (fetchedAlerts != null) {
            // Filter alerts according to their types
            emergencyAlerts = fetchedAlerts.where((alert) => alert['type'] == 1).toList();
            bleedingAlerts = fetchedAlerts.where((alert) => alert['type'] == 2).toList();
            dehydrationAlerts = fetchedAlerts.where((alert) => alert['type'] == 3).toList();
            socialThreatAlerts = fetchedAlerts.where((alert) => alert['type'] == 4).toList();
          }
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        print('Exception while fetching alerts: $e');
      }
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
    Color getStatusColor(String statusColorHex) {
      if (statusColorHex != null && statusColorHex.isNotEmpty) {
        try {
          int colorValue = int.parse(statusColorHex.substring(2), radix: 16);
          return Color(colorValue);
        } catch (e) {
          print('Error parsing color: $e');
        }
      }
      return Colors.blue; // Default color if parsing fails
    }
    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        bool isAmbulanceAssigned = alert['ambulance'] is Map<String, dynamic>;
        bool isClickable = alert['docstatus'] != Map<String, dynamic>;

        final status = alert['statusdescription'];
        final statusColorHex = alert['statusColor'];
        Color statusBackgroundColor = getStatusColor(statusColorHex);

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
                    Text('${alert['name']}'),
                    if (isAmbulanceAssigned)
                      Text('${alert['ambulance']['name']}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            String latLong =
                                '${alert['location'][1]},${alert['location'][0]}';
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
                  if (!isAmbulanceAssigned && isClickable) {
                    List<Map<String, dynamic>>? ambulanceDetails =
                    await _mapService.getUsersList(
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
                          alert['docstatus'],
                          alert['title'],
                          alert['id'],
                          alert['statusdescription'],
                        );
                      },
                    );
                  }
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: statusBackgroundColor, // Use status color as background
                    borderRadius: BorderRadius.all(Radius.circular(20.0)
                    ),
                  ),
                  child: Text(
                    '$status',
                    style: TextStyle(
                      color: Colors.white, // Text color for status label
                    ),
                  ),
                ),
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
    String phoneUrl = 'tel: +91$phoneNumber';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      throw 'Could not launch $phoneUrl';
    }
  }
  Widget _buildAmbulanceDetails(
      List<Map<String, dynamic>>? ambulanceDetails,
      Map<String, dynamic>? docstatus,
      String alertTitle,
      String alertID,
      String alertStatus,

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
                  int docstatusNo = docstatus!['status'];
                  String docstatusDescription = docstatus!['description'];

                  _showActionPopup(docstatusNo, docstatusDescription, alertID);
                },
                child: Text('Update Status'),
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
                    onPressed: () async {
                      if (ambulance != null && alertID != null) {
                         String ambulanceID = ambulance['id'] ?? '';
                         await _mapService.assignAmbulanceToAlert(
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

  void _showActionPopup(int docStatus, String docStatusDescription, String alertId){
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
                onPressed: () async {
                  await _mapService.updateAlertStatus(alertId, docStatus);
                  _fetchAlerts();
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
