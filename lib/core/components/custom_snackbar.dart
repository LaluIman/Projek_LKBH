import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class DefaultCustomSnackbar {
  DefaultCustomSnackbar._();
  static buildSnackbar(
      BuildContext context, String message, Color bgcolor) {
    Flushbar(
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: bgcolor,
      flushbarPosition: FlushbarPosition.TOP,
      borderRadius: BorderRadius.circular(10),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 2),
          blurRadius: 3,
        )
      ],
    ).show(context);
  }
}