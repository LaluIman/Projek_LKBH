import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/Components/flushbar_notif.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';

class SuccessScreen extends StatefulWidget {
  static String routeName = "/success_login";
  const SuccessScreen({super.key});

  @override
  SuccessScreenState createState() => SuccessScreenState();
}

class SuccessScreenState extends State<SuccessScreen> {
  @override
void initState() {
  super.initState();
  FlushbarNotif.show(
    context,
    "Berhasil masuk!",
    "assets/icons/Success Icon.svg",
    KSuccess
  );
}

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
                Text("Berhasil masuk!", style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: KPrimaryColor,
                ),),
                SizedBox(height: 20,),
                Image.asset("assets/images/Success cuy.png",),
                SizedBox(height: 20,),
                Text("Kamu telah teregistrasi di Konsulhukum \n Ayo ke Beranda dan Konsultasi!", textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black
                ),),
                SizedBox(height: 50,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: DefaultButton(text: "Ke beranda", press: (){
                    Navigator.pushReplacementNamed(context, "/custom_navigation_bar");
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