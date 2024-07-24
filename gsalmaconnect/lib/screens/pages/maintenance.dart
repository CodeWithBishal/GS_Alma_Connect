import 'package:flutter/material.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

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
              "GS Connect is currently down for maintenance",
              semanticsLabel: "GS Connect is currently down for maintenance",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            const Text(
              "Please try after some time",
              semanticsLabel:
                  "Please ensure that your application is updated to the most recent version.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            Image.asset("assets/logo/maintenance.png")
          ],
        ),
      ),
    );
  }
}
