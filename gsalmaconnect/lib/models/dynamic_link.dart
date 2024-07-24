import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsconnect/theme/whitelabel.dart';

ActionCodeSettings resetPasswordEmail = ActionCodeSettings(
  url: "$domain/reset",
  //test androidInstallApp
  androidInstallApp: true,
  androidPackageName: "com.sgsits.gs_connect",
  handleCodeInApp: false,
  androidMinimumVersion: "1",
);
