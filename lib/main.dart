import 'package:aidlink/screens/AM/ambulance_page.dart';
import 'package:aidlink/screens/FR/home_page.dart';
import 'package:aidlink/screens/login_page.dart';
import 'package:aidlink/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/DR/admin_alerts_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AidLink',
      theme: ThemeData(
        primarySwatch: Colors.blue,

      ),
      home: FutureBuilder<String>(
        future: _getUserType(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            if (snapshot.hasData) {
              print(snapshot.data);

              if (snapshot.data == 'F') {
                LocationService().startSendingLocation();
                return HomePage();
              }
              else if (snapshot.data == 'D') {
                LocationService().startSendingLocation();
                return AdminAlertsPage();
              }
              else if (snapshot.data == 'A') {
                LocationService().startSendingLocation();
                return AmbulancePage();
              }
              else {
                return LoginPage();
              }
            }
          }
          return LoginPage();
        },
      ),
    );
  }

  Future<String> _getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('type') ?? '';
  }
}
