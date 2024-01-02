import 'package:aidlink/screens/FR/raisealerts_page.dart';
import 'package:flutter/material.dart';
import '../../services/FR_services.dart';
import '../maps_page.dart';

class ViewAlertsFR extends StatefulWidget {
  @override
  _ViewAlertsFRState createState() => _ViewAlertsFRState();
}

class _ViewAlertsFRState extends State<ViewAlertsFR> {
  FRServices _frServices = FRServices();
  List<Map<String, dynamic>> emergencyAlerts = [];
  List<Map<String, dynamic>> bleedingAlerts = [];
  List<Map<String, dynamic>> dehydrationAlerts = [];
  List<Map<String, dynamic>> socialThreatAlerts = [];

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    List<Map<String, dynamic>>? fetchedAlerts = await _frServices.getFRAlerts();
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
        title: Text('My Alerts'),
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
      body:
      DefaultTabController(
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
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            title: Text(
              '${alert['title']}',
              style: TextStyle(fontSize: 20),
            ),
            subtitle: Text(
              '${alert['at']}',
              style: TextStyle(fontSize: 16),
            ),
            trailing: Container(
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
          ),
        );
      },
    );
  }
}