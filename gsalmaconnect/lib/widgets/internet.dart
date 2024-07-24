import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/widgets/snacbar.dart';

class CheckForInternet {
  static Future checkForInternet(BuildContext context) async {
    final Connectivity connectivity = Connectivity();
    final List<ConnectivityResult> result;
    try {
      result = await connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        if (context.mounted) {
          customSnacBarWithAction(
            context,
            "No Internet Connection Found",
            SnackBarAction(
              label: "Retry",
              onPressed: () {
                checkForInternet(context);
              },
            ),
          );
        }
        return false;
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
