import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/auth/redirect.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:gsconnect/widgets/snacbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gsconnect/widgets/record_error.dart';

class NotificationFirebase {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<String> getFirebaseMessagingToken() async {
    final String? fcmToken = await messaging.getToken();
    if (fcmToken != null) {
      return fcmToken;
    } else {
      return "";
    }
  }

  static Future<void> handleFirebaseMessagingToken(BuildContext context) async {
    if (userHiveData.length == 0) return;
    final hiveRes = userHiveData.getAt(0);
    if (hiveRes == null) return;
    await messaging.requestPermission().then((value) {
      if (value.authorizationStatus.toString().contains("denied")) {
        customSnacBarWithAction(
          context,
          "Allow notification!",
          SnackBarAction(
            label: "Settings",
            onPressed: () {
              AppSettings.openAppSettings(
                type: AppSettingsType.notification,
              );
            },
          ),
        );
      }
    });
    await messaging.getToken().then((token) async {
      if (token != null && hiveRes.fcmToken != token) {
        await publicUserDataRTDB
            .child(hiveRes.userName)
            .child("fcmToken")
            .set(token);
        await userDataRTDB.child(hiveRes.uid).child("fcmToken").set(token);
        deleteHiveAndRefetch();
      }
    });
  }

  static Future<void> handleForeground(BuildContext context) async {
    LocalNotificationService().initLocalNotification(context);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await LocalNotificationService().showLocalNotification(message: message);
      // print('Got a message whilst in the foreground!');
      // print('Message data: ${message.data}');
      // print(message.data["route"]);
      // if (message.notification != null) {
      //   print('Message also contained a notification: ${message.notification}');
      // }
    });
  }

  static Future<void> handleRedirect(
    RemoteMessage message,
    BuildContext context,
  ) async {
    int selectedIndex = 0;
    if (message.data["route"] == null || !context.mounted) return;
    final String route = message.data["route"];
    if (route == "chats") {
      selectedIndex = 2;
    } else if (route == "announcement") {
      selectedIndex = 1;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => RedirectUser(
          selectedIndex: selectedIndex,
        ),
      ),
      (route) => false,
    );
  }

  static Future<void> handleOpenNotification(BuildContext context) async {
    LocalNotificationService().initLocalNotification(context);
    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      await handleRedirect(
        event,
        context,
      );
    });
  }
}

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  void initLocalNotification(BuildContext context) {
    const androidSetting = AndroidInitializationSettings(
      "@mipmap/launcher_icon",
    );
    const initializationSettings = InitializationSettings(
      android: androidSetting,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        redirectFunctions(details, context);
      },
    );
  }

  void redirectFunctions(NotificationResponse details, BuildContext context) {
    final message = RemoteMessage(
      data: Map.from(
        {
          "route": details.payload,
          "sent_by": details.payload,
        },
      ),
    );
    NotificationFirebase.handleRedirect(
      message,
      context,
    );
  }

  Future<void> showLocalNotification({required RemoteMessage message}) async {
    final BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
      message.notification!.body!,
      htmlFormatBigText: true,
      contentTitle: message.notification!.title,
      htmlFormatTitle: true,
    );
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "notification",
      "notificationchannel",
      importance: Importance.max,
      priority: Priority.max,
      ongoing: (message.data["sent_by"] == "Faculty" ||
              message.data["sent_by"] == "Alumni")
          ? true
          : false,
      styleInformation: bigTextStyleInformation,
    );
    final notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
      payload: message.data["route"],
    );
  }
}

class MessagingServices {
  static const key =
      "AAAA1E_QwMo:APA91bGf186DxhjlPWAknMeIpW0b5FzJYmT8KPoNwDI4XO4IR8OofKrk6CrCwkIROCoEA7WEX319PJslpWRLlGp82wC20YYvA4V9W4O4LZxyddLaeBPNatwJaPa7oaLgxtv-g-VeJZK9";
  static Future<void> sendNotification({
    required String toID,
    required String name,
    required String body,
    required String commRole,
  }) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$key',
        },
        body: jsonEncode(<String, dynamic>{
          "to": toID,
          'notification': <String, dynamic>{
            'body': body,
            'title': name,
            "android_channel_id": "notification"
          },
          "data": {
            "route": "chats",
            "sent_by": commRole,
          },
        }),
      );
    } catch (e) {
      recordError(e, "sendNotification_FNs");
    }
  }
}
