import 'package:flutter/material.dart';

class CustomTooltip extends StatelessWidget {
  const CustomTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.red.shade500, borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      textStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      enableTapToDismiss: true,
      showDuration: Duration(seconds: 5),
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      child: child
    );
  }
}
