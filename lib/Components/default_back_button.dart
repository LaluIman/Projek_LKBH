import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';

class DefaultBackButton extends StatelessWidget {
  const DefaultBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          children: [
            Icon(Icons.arrow_back_ios_new, color: KPrimaryColor,),
            Text("Kembali", style: TextStyle(fontSize: 20, color: KPrimaryColor),)
          ],
        ),
      ),
    );
  }
}