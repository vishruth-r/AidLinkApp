import 'package:aidlink/services/admin_services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/FR_services.dart';
import '../widgets/bottom_app_bar.dart';

class AdminAlertsPage extends StatefulWidget {
  @override
  _AdminAlertsPageState createState() => _AdminAlertsPageState();
}

class _AdminAlertsPageState extends State<AdminAlertsPage> {
  FRServices _frServices = FRServices();
  MapService _mapService = MapService();


  List<Map<String, dynamic>> emergencyAlerts = [];
  List<Map<String, dynamic>> bleedingAlerts = [];
  List<Map<String, dynamic>> dehydrationAlerts = [];
  List<Map<String, dynamic>> socialThreatAlerts = [];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
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
        title: Text('Admin Alerts Page'),
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
              tabs: [
                Tab(text: 'Emergency',
                    icon: Icon(Icons.warning, color: Colors.red)),
                Tab(text: 'Bleeding',
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
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onPressed: [
              () {
            // Handle Home button tap
            setState(() {
              _currentIndex = 0;
            });
          },
              () {
            // Handle Search button tap
            setState(() {
              _currentIndex = 1;
            });
          },
              () {
            // Handle Favorite button tap
            setState(() {
              _currentIndex = 2;
            });
          },
              () {
            // Handle Profile button tap
            setState(() {
              _currentIndex = 3;
            });
          },
        ],
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
        return Card(
          margin: EdgeInsets.all(8.0),
          elevation: 4.0,
          child: ListTile(
            title: Text('ID: ${alert['id']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('At: ${alert['at']}'),
                Text('Status: ${alert['status']}'),
                Text('FR Name: ${alert['FRname']}'),
                Text('Ambulance Mobile: ${
                    alert['ambulance'] is Map<String, dynamic>
                        ? alert['ambulance']['mobile'] ?? 'Not assigned'
                        : 'Not assigned'
                }'),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.navigation, color: Colors.blue,),
                      onPressed: () {
                        String latLong = '${alert['location'][1]},${alert['location'][0]}';
                        _launchMaps(latLong);
                      },
                    ),
                    SizedBox(width: 16.0),
                    IconButton(
                      icon: Icon(Icons.phone, color: Colors.green),
                      onPressed: () {
                        _makePhoneCall(alert['FRmobile']);
                      },
                    ),
                  ],
                ),
              ],
            ),
            onTap: () async {
              if (alert['ambulance'] != null) {
                final ambulance = alert['ambulance'];
                print("works ambu");
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return _buildAmbulanceCard(ambulance);
                  },
                );
              }
              else {
                List<Map<String, dynamic>>? ambulanceDetails = await _mapService
                    .getUsersList(
                  fr: false,
                  am: true,
                  ad: false,
                  al: false,
                );

                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return _buildAmbulanceDetails(
                      ambulanceDetails,
                      alert['id'],
                      alert['status'],
                    );
                  },
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildAmbulanceCard(Map<String, dynamic> ambulance) {
    print("works ambul");
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 4.0,
      child: ListTile(
        title: Text('Ambulance ID: ${ambulance['id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ambulance Number: ${ambulance['number']}'),
            Text('Ambulance Type: ${ambulance['type']}'),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.phone, color: Colors.green),
                  onPressed: () {
                    _makePhoneCall(ambulance['mobile']);
                  },
                ),
                SizedBox(width: 16.0),
                IconButton(
                  icon: Icon(Icons.navigation, color: Colors.blue,),
                  onPressed: () {
                    String latLong = '${ambulance['location'][1]},${ambulance['location'][0]}';
                    _launchMaps(latLong);
                  },
                ),
              ],
            ),
          ],
        ),
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
  }

  Widget _buildAmbulanceDetails(List<Map<String, dynamic>>? ambulanceDetails,
      String alertID, int alertStatus) {
    int currentStatus = alertStatus;
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Alert ID: $alertID',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 16.0),
          Column(
            children: [
              Text(
                'Alert Status: $currentStatus',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  // Existing code remains the same
                ],
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
                  subtitle: ElevatedButton(
                    onPressed: () {
                      _makePhoneCall(ambulance?['mobile'] ?? '');
                    },
                    child: Icon(Icons.phone),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      if (ambulance != null && alertID != null) {
                        String ambulanceID = ambulance['id'] ??
                            ''; // Assuming the ambulance ID is stored in 'id' field
                        _mapService.assignAmbulanceToAlert(
                            alertID, ambulanceID);
                      }
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
}