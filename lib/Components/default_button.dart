import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    super.key, 
    required this.text, 
    required this.press, 
    required this.bgcolor, 
    required this.textColor, 
    this.icon = '',
    this.isLoading = false,
  });

  final String icon;
  final String text;
  final Color textColor;
  final Color bgcolor;
  final VoidCallback? press;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: isLoading ? null : press,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isLoading ? Colors.red.shade300 : bgcolor,
          minimumSize: Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: isLoading
            ? LoadingAnimationWidget.waveDots(
                color: KPrimaryColor,
                size: 25,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon.isNotEmpty) SvgPicture.asset(icon),
                  if (icon.isNotEmpty) SizedBox(width: 10),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
    );
  }
}