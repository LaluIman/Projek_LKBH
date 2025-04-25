import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';

class TerjadwalkanScreen extends StatelessWidget {
    static String routeName = "/terjadwalkan";

  const TerjadwalkanScreen({super.key});

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
                Text("Terjadwalkan!", style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: KPrimaryColor,
                ),),
                SizedBox(height: 10,),
                Image.asset("assets/images/Terjadwalkan.png", fit: BoxFit.cover, width: 300,),
                SizedBox(height: 20,),
                Text("Kami akan menghubungi kamu melalui \n Whatsapp", textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black
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