import 'package:flutter/material.dart';
import '../../services/ambulance_services.dart';
import '../maps_page.dart';

class AmbulancePage extends StatefulWidget {
  @override
  _AmbulancePageState createState() => _AmbulancePageState();
}

class _AmbulancePageState extends State<AmbulancePage> {
  AmbulanceServices ambulanceServices = AmbulanceServices();
  List<dynamic> alerts = [];
  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  void fetchAlerts() async {
    try {
      List<dynamic> fetchedAlerts = await ambulanceServices.fetchAlerts();
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
        title: Text('Ambulance Alerts'),
      ),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          final alertId = alert['id'];
          final alertTime = DateTime.parse(alert['at']); // Assuming 'at' is the time field in the response

          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Alert ID: $alertId'),
              subtitle: Text('Time: ${alertTime.toString()}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.navigation),
                    onPressed: () {
                      // Handle navigation action
                      // Navigate to the specific page or perform the required action
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.call),
                    onPressed: () {
                      // Handle call action
                      // Implement the call functionality here
                    },
                  ),
                ],
              ),
              onTap: () {
                // Handle tapping on the alert (if needed)
                // You can navigate to a detailed alert page or perform any other action
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.map),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapsPage()),
                );
              },
            ),

            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapsPage()),
                );
              },
            ),
            // Add more buttons/icons as needed
            // Add more buttons/icons as needed
          ],
        ),

      ),
    );
  }
}
