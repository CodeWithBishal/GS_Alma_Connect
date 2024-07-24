import 'package:flutter/material.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "New Update is available for GS Connect ",
              semanticsLabel: "New Update for GS Connect is Available",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            const Text(
              "Please update your app.",
              semanticsLabel: "Please update your app.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            Image.asset("assets/logo/maintenance.png"),
            const SizedBox(
              height: 20,
            ),
            TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    ColorDefination.blueBg,
                  ),
                ),
                onPressed: () {
                  LaunchUrl.openLink(
                    url:
                        "https://play.google.com/store/apps/details?id=com.sgsits.gs_connect_debug&hl=en-US&ah=1UXWm0TtNUfwRsrbhRHo-TfN0lI",
                    context: context,
                    launchMode: LaunchMode.externalNonBrowserApplication,
                  );
                },
                child: const Text("Update"))
          ],
        ),
      ),
    );
  }
}
