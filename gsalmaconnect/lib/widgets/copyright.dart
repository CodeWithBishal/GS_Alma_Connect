import 'package:flutter/cupertino.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

Widget copywrite(
  BuildContext context,
) {
  String year = DateTime.now().year.toString();
  return GestureDetector(
    onTap: () {
      LaunchUrl.openLink(
        url: "https://linktr.ee/bishal_das_bd",
        context: context,
        launchMode: LaunchMode.externalApplication,
      );
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "© $year Made with ❤ by ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Bishal Das",
          style: TextStyle(
            color: ColorDefination.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
