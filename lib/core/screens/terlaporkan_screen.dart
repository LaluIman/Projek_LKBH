import 'package:aplikasi_lkbh_unmul/core/components/default_button.dart';import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:flutter/material.dart';

class TerlaporkanScreen extends StatelessWidget {
  static String routeName = "/terlaporkan";
  const TerlaporkanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Terlaporkan!", style: TextTheme.of(context).titleLarge?.copyWith(
                      color: KPrimaryColor
                    )),
                SizedBox(height: 20,),
                Image.asset("assets/images/terlaporkan.png", fit: BoxFit.cover, width: 300,),
                SizedBox(height: 20,),
                Text("Kamu Akan di kabari oleh tim LKBH melewati \n Whatsapp!", textAlign: TextAlign.center, style: TextTheme.of(context).bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600
                ),),
                SizedBox(height: 50,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: DefaultButton(text: "Kembali ke beranda", press: (){
                    Navigator.pushNamedAndRemoveUntil(context, '/custom_navigation_bar', (Route<dynamic> routeName) => false);
                  }, bgcolor: KPrimaryColor, textColor: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}