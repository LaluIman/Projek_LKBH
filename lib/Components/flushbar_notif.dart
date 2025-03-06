import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlushbarNotif {
  static Future<void> show(
      BuildContext context, String message, String iconPath, Color  backgroundColor,
      {
      int durationInSeconds = 3,
      FlushbarPosition position = FlushbarPosition.TOP}) async {
    await Future.delayed(Duration.zero);
    Flushbar(
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      icon: SvgPicture.asset(iconPath),
      duration: Duration(seconds: durationInSeconds),
      flushbarPosition: position,
      flushbarStyle: FlushbarStyle.FLOATING,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      margin: const EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: backgroundColor,
    ).show(context);
  }
}
