import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleTapBackExit extends StatefulWidget {
  final Widget child;
  final String message;
  final Duration exitDuration;

  const DoubleTapBackExit({
    super.key,
    required this.child,
    this.message = 'Tekan kembali sekali lagi untuk keluar',
    this.exitDuration = const Duration(seconds: 2),
  });

  @override
  State<DoubleTapBackExit> createState() => _DoubleTapBackExitState();
}

class _DoubleTapBackExitState extends State<DoubleTapBackExit> {
  DateTime? _lastPressedTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }

        final now = DateTime.now();
        if (_lastPressedTime == null ||
            now.difference(_lastPressedTime!) > widget.exitDuration) {
          _lastPressedTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
              content: Text(
                widget.message,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              duration: widget.exitDuration,
            ),
          );
        } else {
          await SystemNavigator.pop();
        }
      },
      child: widget.child,
    );
  }
}
