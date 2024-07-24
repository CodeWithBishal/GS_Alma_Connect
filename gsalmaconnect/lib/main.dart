import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/firebase_options.dart';
import 'package:gsconnect/models/authentication.dart';
import 'package:gsconnect/models/hive/hive_user.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/auth/redirect.dart';
import 'package:gsconnect/screens/backend/notification.dart';
import 'package:gsconnect/theme/themes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data["sent_by"] == "Faculty" ||
      message.data["sent_by"] == "Alumni") {
    await LocalNotificationService().showLocalNotification(message: message);
  }
}

const bool isUseProdDB = false;
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileDataAdapter());
  try {
    await Hive.openBox<UserProfileData>(HiveBoxes.userProfileData);
  } catch (e) {
    await Hive.deleteBoxFromDisk(HiveBoxes.userProfileData);
    await Hive.openBox<UserProfileData>(HiveBoxes.userProfileData);
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      await Firebase.initializeApp();
    }
  }
  // emulator
  if (kDebugMode && !isUseProdDB) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseDatabase.instance.useDatabaseEmulator('10.0.2.2', 9000);
    FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  } else {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }
  // emulator
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        title: 'GS Connect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const RedirectUser(),
      ),
    );
  }
}

initMessaging(BuildContext context) async {
  if (!context.mounted) return;
  NotificationFirebase.handleForeground(context);
  NotificationFirebase.handleOpenNotification(context);
  // NotificationFirebase.checkForBgMsg(context);
}
