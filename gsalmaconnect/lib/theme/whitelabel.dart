import 'package:flutter/material.dart';

class Whitelabel {
  static String get platName {
    return "GS AlmaConnect";
  }

  static String get logoPath {
    return "assets/logo/sgsits_logo.png";
  }

  static String get tag_1 {
    return "Hello Alumni,";
  }

  static String get tag_2 {
    return " Welcome to GS AlmaConnect";
  }

  static String get subTag {
    return "";
  }
}

Widget logo = Image.asset(
  "assets/logo/sgsits_logo.png",
  scale: 2.5,
);
String logoPath = "assets/logo/sgsits_logo.png";

String domain = "https://gsconnect.web.app/";

const ButtonStyle transparentButtonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(
    Colors.transparent,
  ),
);
