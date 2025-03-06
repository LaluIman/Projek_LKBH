import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    super.key, 
    required this.text, 
    required this.press, 
    required this.bgcolor, 
    required this.textColor, 
    this.icon = '',
  });

  final String icon;
  final String text;
  final Color textColor;
  final Color bgcolor;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: press,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: bgcolor,
          minimumSize: Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Conditionally render the icon if it's not an empty string
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
