import 'package:flutter/material.dart';
import 'package:gsconnect/theme/colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Ubuntu',
    scaffoldBackgroundColor: ColorDefination.bgColor,
    useMaterial3: true,
    primaryColor: ColorDefination.blue,
    appBarTheme: AppBarTheme(
      backgroundColor: ColorDefination.bgColor,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        enableFeedback: false,
        iconColor: WidgetStatePropertyAll(
          ColorDefination.blue,
        ),
        foregroundColor: WidgetStatePropertyAll(
          ColorDefination.blue,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        enableFeedback: false,
        backgroundColor: WidgetStatePropertyAll(
          ColorDefination.secondaryColor,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: ColorDefination.blue,
      suffixIconColor: ColorDefination.blue,
      labelStyle: TextStyle(color: ColorDefination.blue, fontSize: 14),
      hintStyle: TextStyle(color: ColorDefination.blue, fontSize: 14),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(19),
        ),
        borderSide: BorderSide(
          width: 2,
          color: Colors.white,
        ),
      ),
      enabledBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(19),
        borderSide: const BorderSide(
          width: 2,
          color: Colors.white,
        ),
      ),
      focusedBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(19),
        borderSide: BorderSide(
          width: 2,
          color: ColorDefination.blue,
        ),
      ),
      errorBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(19),
        borderSide: const BorderSide(
          width: 2,
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(19),
        borderSide: const BorderSide(
          width: 2,
          color: Colors.red,
        ),
      ),
      contentPadding: const EdgeInsets.all(20),
      filled: true,
      fillColor: ColorDefination.blueBg,
      floatingLabelBehavior: FloatingLabelBehavior.never,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: ColorDefination.bgColor,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    // scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: ColorDefination.beige,
    ),
  );
}
