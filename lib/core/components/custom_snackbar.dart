import 'package:flutter/material.dart';

class DefaultCustomSnackbar {
  DefaultCustomSnackbar._();
  static buildSnackbar(
      BuildContext context, String message, Color bgcolor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.up,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150,
            left: 10,
            right: 10),
        backgroundColor: bgcolor,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
