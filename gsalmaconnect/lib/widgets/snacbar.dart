import 'package:flutter/material.dart';

void customSnacBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
}

void customSnacBarWithAction(
    BuildContext context, String message, SnackBarAction? action) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        action: action,
      ),
    );
}
