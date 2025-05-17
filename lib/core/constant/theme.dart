import 'package:flutter/material.dart';

const KPrimaryColor = Color(0xffDA3435);
const KGray = Color(0xffE5E5E5);
const KBg = Color(0xffF1F1F1);
const KError = Color(0xfFF00000);
const kUnselectedColor = Color(0xffAAAAAA);
const KGoogleButton = Color(0xffF1F1F1);
const KSuccess = Color(0xff00C037);

themeData() {
  return ThemeData(
      fontFamily: 'Manrope',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: KBg,
      appBarTheme: AppBarTheme(
        color: KBg,
      ),
      inputDecorationTheme: inputDecoration(),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0
        ),
        labelMedium: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0
        ),
      ));
}

InputDecorationTheme inputDecoration() {
  var outlineInputBorder = const OutlineInputBorder(
      borderSide: BorderSide(width: 0, color: Colors.transparent),
      borderRadius: BorderRadius.all(Radius.circular(10)),
      gapPadding: 5);
  return InputDecorationTheme(
    fillColor: KGray,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 17),
    labelStyle:
        TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
    hintStyle:
        TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
    hintFadeDuration: Durations.medium3,
    enabledBorder: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    border: outlineInputBorder,
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(16)),
        gapPadding: 5),
  );
}

