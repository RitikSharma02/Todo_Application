import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;



class NotifyHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  Future<void> initializeNotification() async {
    // Initialize the timezone
    tz.initializeTimeZones();


    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("appicon");

    final InitializationSettings initializationSettings = InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        handleNotificationResponse(response);
      },
    );


    if (await Permission.notification.isDenied) {
      var status = await Permission.notification.request();
      if (!status.isGranted) {
        print("Notification permission not granted.");
        return;
      }
    }


    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id',
      'Your Channel Name',
      description: 'Your Channel Description',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }


  Future<void> scheduledNotification({required String title, required String body}) async {
    try {
      final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your_channel_id',
        'Your Channel Name',
        channelDescription: 'Your Channel Description',
        importance: Importance.max,
        priority: Priority.high,
      );

      const platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        scheduledTime,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'Your payload data here',
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print("Notification scheduled successfully.");
    } catch (error) {
      print("Error scheduling notification: $error");
    }
  }

  Future<void> zonedScheduleAlarmClockNotification({required String title, required String body}) async {
    try {
      final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'alarm_clock_channel', // Channel for alarm clock
        'Alarm Clock Channel',
        channelDescription: 'Alarm Clock Notification',
        importance: Importance.max,
        priority: Priority.high,
      );

      const platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        123,
        title,
        body,
        scheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      print("Alarm clock notification scheduled successfully.");
    } catch (error) {
      print("Error scheduling alarm clock notification: $error");
    }
  }


  Future onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    Get.dialog(Text("Welcome here"));
  }

  void handleNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      print('Notification payload: ${response.payload}');
    } else {
      print("Notification Done");
    }
    Get.to(() => Container(color: Colors.white)); // Navigate to a screen after notification tap
  }


  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }


  void displayNotification({required String title, required String body}) async {
    print("Displaying notification: $title - $body"); // Debugging line

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your_channel_id', // Use the defined constant
      'Your Channel Name',
      channelDescription: 'Your Channel Description',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Your payload data here',
    );
  }
}






// Future<void> scheduledNotification() async {
//   try {
//     final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
//
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       'Scheduled Title',
//       'This is a test notification without external timezone',
//       scheduledTime,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'your_channel_id',
//           'Your Channel Name',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//       ),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
//     );
//
//     print("Notification scheduled successfully.");
//   } catch (error) {
//     print("Error scheduling notification: $error");
//   }
// }