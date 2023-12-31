import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class FirebaseMessagingService {
  late BuildContext _context;
  int notificationId = 1;

  void setContext(BuildContext context) {
    _context = context;
  }

  void initializeAwesomeNotifications() {
    AwesomeNotifications().initialize(
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic notifications',
        ),
      ],
    );
  }

  Future<void> configureFirebaseMessaging() async {
    initializeAwesomeNotifications();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message!');
      print('Message data: ${message.data}');
      _showAwesomeNotification(message);
      _showSnackbarWithButton();
    });

    // Rest of your Firebase Messaging configuration...

  }

  Future<void> _showAwesomeNotification(RemoteMessage message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'basic_channel',
        title: 'New Notification',
        body: 'This is a notification example',
      ),
      // Use device's default notification sound
    );
  }

  void _showSnackbarWithButton() {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text('New Notification Received!'),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(_context).hideCurrentSnackBar();
                // Perform an action when the button is pressed
              },
              child: Text(
                'Dismiss',
                style: TextStyle(color: Colors.yellow),
              ),
            ),
          ],
        ),
        duration: Duration(days: 1), // Change the duration as needed
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            ScaffoldMessenger.of(_context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
void handleData(Map<String, dynamic> messageData) {
    // Handle data when notification is received
  }

  void handleNavigation(Map<String, dynamic> messageData) {
    // Handle navigation logic based on message data
  }

  Stream<Map<String, dynamic>> get onMessageReceived {
    return FirebaseMessaging.onMessage.map((RemoteMessage message) => message.data);
  }
}
