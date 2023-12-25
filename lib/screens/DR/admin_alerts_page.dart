import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Alerts Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AdminAlertsPage(),
    );
  }
}

class AdminAlertsPage extends StatelessWidget {
  List<Map<String, dynamic>> alerts = [

    {
      'alertStatus': 'New',
      'aidStationName': 'Aid Station 1',
      'alertDescription': 'Description for New Alert 1Description for New Alert 1Description for New Alert 1Description for New Alert 1Description for New Alert 1Description for New Alert 1',
      'bibNumber': '123',
      'alertTime': null,
      'alertType': 'Red',
      'phoneNumber': '1234567890',
      'latlng': '40.7128, -74.0060',
      'ambulanceNumber':'999999999'
    },
    {
      'alertStatus': 'New',
      'aidStationName': 'Aid Station 2',
      'alertDescription': 'Description for New Alert 2',
      'bibNumber': '456',
      'alertTime': '09:15 AM',
      'alertType': 'Orange',
      'phoneNumber': '9876543210',
      'latlng': '40.7128, -74.0060'
    },
    {
      'alertStatus': 'Responded',
      'aidStationName': 'Aid Station 3',
      'alertDescription': 'Description for Active Alert 1',
      'bibNumber': '789',
      'alertTime': '09:30 AM',
      'alertType': 'Blue',
      'phoneNumber': '1112223333',
      'latlng': '40.7128, -74.0060'
    },
    {
      'alertStatus': 'Closed',
      'aidStationName': 'Aid Station 4',
      'alertDescription': 'Description for Closed Alert 1',
      'bibNumber': '321',
      'alertTime': '09:45 AM',
      'alertType': 'Green',
      'phoneNumber': '4445556666',
      'latlng': '40.7128, -74.0060'
    },
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Alerts'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'New'),
              Tab(text: 'Active'),
              Tab(text: 'Closed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAlertsList(context, 'New'),
            _buildAlertsList(context, 'Active'),
            _buildAlertsList(context, 'Closed'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Action for floating button
          },
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  // Action for menu button
                },
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  // Action for search button
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  // Action for settings button
                },
              ),
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  // Action for notifications button
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context, String status) {
    // Filter alerts based on the selected status
    List<Map<String, dynamic>> filteredAlerts =
    alerts.where((alert) => alert['alertStatus'] == status).toList();

    return ListView.builder(
      itemCount: filteredAlerts.length,
      itemBuilder: (context, index) {
        String alertType = filteredAlerts[index]['alertType'];
        Color cardColor = _getColorByAlertType(alertType);

        bool hasAmbulanceNumber = filteredAlerts[index].containsKey('ambulanceNumber');
        IconData ambulanceIcon = Icons.local_hospital; // Default ambulance icon

        if (hasAmbulanceNumber) {
          ambulanceIcon = Icons.local_hospital; // Change to desired ambulance icon
        }

        return Card(
          margin: EdgeInsets.all(8.0),
          color: cardColor.withOpacity(0.6),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filteredAlerts[index]['aidStationName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text('${filteredAlerts[index]['alertDescription']}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text('${filteredAlerts[index]['bibNumber']}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${filteredAlerts[index]['alertTime']}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _openMap(filteredAlerts[index]['latlng']);
                  },
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                ),
                if (hasAmbulanceNumber)
                  IconButton(
                    onPressed: () {
                      _makePhoneCall(filteredAlerts[index]['ambulanceNumber']);
                    },
                    icon: Icon(
                      ambulanceIcon,
                      color: Colors.white,
                    ),
                  ),
                IconButton(
                  onPressed: () {
                    _makePhoneCall(filteredAlerts[index]['phoneNumber']);
                  },
                  icon: Icon(
                    Icons.phone,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getColorByAlertType(String alertType) {
    switch (alertType) {
      case 'Red':
        return Colors.red;
      case 'Orange':
        return Colors.orange;
      case 'Blue':
        return Colors.blue;
      case 'Green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _openMap(String latLng) async {
    final String url = 'https://www.google.com/maps/search/?api=1&query=$latLng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}