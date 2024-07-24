import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/main.dart';
import 'package:gsconnect/models/authentication.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/auth/continue.dart';
import 'package:gsconnect/screens/auth/mobile_auth.dart';
import 'package:gsconnect/screens/backend/remote_config.dart';
import 'package:gsconnect/screens/pages/maintenance.dart';
import 'package:gsconnect/screens/pages/update.dart';
import 'package:gsconnect/widgets/dynamic_link.dart';
import 'package:gsconnect/widgets/internet.dart';
import 'package:gsconnect/widgets/loading.dart';
import 'package:gsconnect/widgets/navbar.dart';
import 'package:gsconnect/widgets/toast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class RedirectUser extends StatefulWidget {
  final int? selectedIndex;
  const RedirectUser({super.key, this.selectedIndex});

  @override
  State<RedirectUser> createState() => _RedirectUserState();
}

class _RedirectUserState extends State<RedirectUser> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  late bool isForceUpdate = false;
  late bool isMaintenanceUpdate = false;
  late int minUseVerUpdate = 1;
  late int currentVer = 1;
  late int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex ?? 0;
    initMessaging(context);
    remoteConfig();
    initDeepLinks();
    RemoteConfigInfo().remoteConfig.onConfigUpdated.listen((event) async {
      await RemoteConfigInfo().remoteConfig.activate();
      remoteConfig();
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void remoteConfig() async {
    bool isInternet = await CheckForInternet.checkForInternet(context);
    PackageInfo currentVersion = await PackageInfo.fromPlatform();
    if (!isInternet) return;
    await RemoteConfigInfo().initConfig();
    int minUseVer = int.parse(
        RemoteConfigInfo().remoteConfig.getString('min_usable_version'));
    bool forceUpdate =
        bool.parse(RemoteConfigInfo().remoteConfig.getString('force_update'));
    bool isMaintenance =
        bool.parse(RemoteConfigInfo().remoteConfig.getString('is_maintenance'));
    setState(() {
      minUseVerUpdate = minUseVer;
      isForceUpdate = forceUpdate;
      isMaintenanceUpdate = isMaintenance;
      currentVer = int.parse(currentVersion.buildNumber);
    });
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialLink();
    if (appLink != null) {
      openAppLink(appLink);
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) async {
    bool isInternet = await CheckForInternet.checkForInternet(context);
    if (!isInternet || !mounted) return;
    final List<String> mainData = uri.pathSegments;
    final User? user = FirebaseAuth.instance.currentUser;
    final length = userHiveData.length;
    if (user == null || length == 0 || user.phoneNumber == null) {
      flutterToast("Please login first!");
      return;
    }
    final res = userHiveData.getAt(0);
    if (res == null || res.isVerified == false) {
      flutterToast("Please verify your profile to open the link");
      return;
    }
    if (mainData[0].contains("@")) {
      handleSearchUsername(mainData[0], context);
    } else if (mainData[0].contains("p")) {
      handlePostDynamicShareLink(mainData[1], context, false);
    } else if (mainData[0].contains("announcement")) {
      handlePostDynamicShareLink(mainData[1], context, true);
    } else {
      flutterToast("Invalid Link");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          FirebaseAuth.instance.currentUser?.reload().catchError((onError) {
            if (onError.toString().contains("[firebase_auth/unknown]")) {
              final provider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.logoutUser();
            }
          });
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          } else if (snapshot.hasData) {
            if (isMaintenanceUpdate) {
              return const MaintenancePage();
            } else if (isForceUpdate || (minUseVerUpdate > currentVer)) {
              return const UpdatePage();
            } else {
              User? user = FirebaseAuth.instance.currentUser;
              if (user?.phoneNumber == null || user?.phoneNumber == "") {
                return const MobileOTP();
              } else {
                return NavBarBottom(
                  selectedInd: selectedIndex,
                );
              }
            }
          } else if (snapshot.hasError) {
            return const Center(
              child:
                  Text("Something went terribly wrong, Please try again later"),
            );
          } else {
            return const ContinuePage();
          }
        },
      ),
    );
  }
}
