import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:flutter/material.dart';

class AlertDialogAction extends StatelessWidget {
  final Widget child;

  const AlertDialogAction({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class CustomAlertdialog extends StatelessWidget {
  const CustomAlertdialog({super.key, required this.title, required this.content, required this.actions});

  final String title, content;
  final List<AlertDialogAction> actions;
  

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      titleTextStyle: TextStyle(
          color: KPrimaryColor, fontWeight: FontWeight.w600, fontSize: 20),
      contentTextStyle: TextStyle(
        color: Colors.black,
      ),
      title: Text(title),
      content: Text(content),
      actions: actions.map((action) => action.child).toList(),
    );
  }
}
