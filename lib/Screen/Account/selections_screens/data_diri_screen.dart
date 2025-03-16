import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';

class DataDiriScreen extends StatelessWidget {
  const DataDiriScreen({super.key});

  static String routeName = "/datadiri";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              SizedBox(
                width: 6,
              ),
              Icon(Icons.arrow_back_ios_new, color: KPrimaryColor),
              SizedBox(
                width: 3,
              ),
              Text(
                "Kembali",
                style: TextStyle(
                    fontSize: 16,
                    color: KPrimaryColor,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      ),
    );
  }
}