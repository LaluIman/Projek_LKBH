import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Selections extends StatelessWidget {
  const Selections({
    super.key, required this.icon, required this.title, required this.press,
  });

  final String icon, title;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: KBg,
                borderRadius: BorderRadius.circular(10)
              ),
              child: SvgPicture.asset(
                icon,
                color: Colors.black,
                width: 25,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              title,
              overflow: TextOverflow.clip,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}