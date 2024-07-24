import 'package:flutter/material.dart';

class Whitelabel {
  static String get platName {
    return "GS Connect";
  }

  static String get logoPath {
    return "assets/logo/sgsits_logo.png";
  }

  static String get tag_1 {
    return "Connecting Minds,";
  }

  static String get tag_2 {
    return " Advancing Research";
  }

  static String get subTag {
    return "Connect. Research. Innovate.";
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
