import 'package:flutter/material.dart';
import '../../services/FR_services.dart';

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
        emergencyAlerts = fetchedAlerts.where((alert) => alert['type'] == 1).toList();
        bleedingAlerts = fetchedAlerts.where((alert) => alert['type'] == 2).toList();
        dehydrationAlerts = fetchedAlerts.where((alert) => alert['type'] == 3).toList();
        socialThreatAlerts = fetchedAlerts.where((alert) => alert['type'] == 4).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Alerts'),
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
                Tab(text: 'Emergency', icon: Icon(Icons.warning, color: Colors.red)),
                Tab(text: 'Bleeding', icon: Icon(Icons.local_hospital, color: Colors.orange)),
                Tab(text: 'Dehydration', icon: Icon(Icons.water_damage, color: Colors.blue)),
                Tab(text: 'Social Threat', icon: Icon(Icons.group, color: Colors.green)),
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
    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            title: Text('ID: ${alert['id']}'),
            subtitle: Text('At: ${alert['at']}\nStatus: ${alert['status']}'),
          ),
        );
      },
    );
  }
}
