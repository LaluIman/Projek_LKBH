import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:flutter/material.dart';

class DefaultBackButton extends StatelessWidget {
  // Tambahkan parameter onPressed yang opsional
  final VoidCallback? onPressed;
  
  const DefaultBackButton({
    super.key,
    this.onPressed, // Parameter opsional
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          children: [
            Icon(Icons.arrow_back_ios_new, color: KPrimaryColor, size: 20,),
            SizedBox(width: 3,),
            Text("Kembali", style: TextTheme.of(context).titleMedium?.copyWith(
              color: KPrimaryColor
            ))
          ],
        ),
      ),
    );
  }
}