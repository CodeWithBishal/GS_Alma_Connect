import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'snacbar.dart';

class LaunchUrl {
  static Future openLink(
          {required String url,
          required BuildContext context,
          required LaunchMode launchMode}) =>
      _launchUrl(url, context, launchMode);

  static Future _launchUrl(
      String url, BuildContext context, LaunchMode launchMode) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      try {
        await launchUrl(Uri.parse(url), mode: launchMode);
      } catch (e) {
        if (context.mounted) {
          customSnacBar(context, "No Browser Found");
        }
      }
    } else {
      if (context.mounted) {
        customSnacBar(context, "Invalid Link");
      }
    }
  }

  static Future sendEmail({
    required String toEmail,
    required String subject,
    required String body,
    required BuildContext context,
    required LaunchMode launchMode,
  }) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      query: "subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(body)}",
    );

    await _launchUrl(emailLaunchUri.toString(), context, launchMode);
  }
}
