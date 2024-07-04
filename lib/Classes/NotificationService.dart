import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Ensure you have this icon in your Android app

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    final bool? initialized = await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    if (initialized == true) {
      print('Notifications initialized successfully');
    } else {
      print('Failed to initialize notifications');
    }
  }

  Future<void> showNotification(String title, String body) async {
    print('Preparing to show notification');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'appointment_reminders', // Unique channel ID
      'Appointment Reminders', // Channel name
      channelDescription: 'Notification channel for appointment reminders', // Channel description
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: 'item x',
      );
      print('Notification shown successfully');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}
