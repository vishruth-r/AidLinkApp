import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  late BuildContext _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> configureFirebaseMessaging() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message while app is in the foreground!');
      print('Message data: ${message.data}');
      showNotification(message);
      _playAlarmAndVibration();
      _showAlarmSnackBar();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('User tapped on the notification!');
      print('Message data: ${message.data}');
      handleData(message.data);
      _notificationsPlugin.cancel(0);
      Vibration.cancel();
    });

    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('User opened the app from a terminated state!');
      print('Message data: ${initialMessage.data}');
      handleData(initialMessage.data);
      _notificationsPlugin.cancel(0);
      Vibration.cancel();
    }
  }

  void showNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id', // Change this channel ID as needed
      'Your Channel Name', // Change this channel name as needed
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0, // Notification ID
      message.notification?.title, // Notification title
      message.notification?.body, // Notification body
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  void handleData(Map<String, dynamic> messageData) {

  }

  void _playAlarmAndVibration() async {
      Vibration.vibrate(duration: 0, amplitude: 255);


    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'alarm_channel', // Change this channel ID as needed
      'RESQ_default_notifications_channel', // Change this channel name as needed
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0, // Notification ID
      'Alarm', // Notification title
      'Alert! Click to stop the alarm.', // Notification body
      platformChannelSpecifics,
      payload: 'Alarm',
    );
  }

  void _showAlarmSnackBar() {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Text('Alert! Click to stop the alarm.'),
        action: SnackBarAction(
          label: 'Stop',
          onPressed: () {
            _notificationsPlugin.cancel(0);
            Vibration.cancel();
          },
        ),
      ),
    );
  }
}
