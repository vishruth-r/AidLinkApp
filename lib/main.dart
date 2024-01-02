import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:aidlink/screens/AM/ambulance_page.dart';
import 'package:aidlink/screens/FR/home_page.dart';
import 'package:aidlink/screens/login_page.dart';
import 'package:aidlink/services/fcm_services.dart';
import 'package:aidlink/services/location_service.dart';
import 'package:aidlink/screens/DR/admin_alerts_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options: const FirebaseOptions( apiKey: "AIzaSyDEQ1bH-4hs4EgtT6LrEe68tRvCNcC7sU0", appId: "1:594393011949:web:21595670cec2ca198adee4", messagingSenderId: "594393011949", projectId: "resq-14587", ), );

  AwesomeNotifications().initialize(
    'resource://drawable/app_icon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic notifications',
      ),
    ],
  );

  FirebaseMessagingService messagingService = FirebaseMessagingService();
  await messagingService.configureFirebaseMessaging();

  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
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
              if (snapshot.data == 'F' || snapshot.data == 'R') {
                LocationService().startSendingLocation();
                return HomePage();
              } else if (snapshot.data == 'D') {
                LocationService().startSendingLocation();
                return AdminAlertsPage();
              } else if (snapshot.data == 'A') {
                LocationService().startSendingLocation();
                return AmbulancePage();
              } else {
                return LoginPage();
              }
            }
          }
          return LoginPage();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<String> _getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('type') ?? '';
  }
}
