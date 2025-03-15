import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';

class HimbauanScreen extends StatelessWidget {
  static String routeName = "/himbauan";
  const HimbauanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldGradientBackground(
      gradient: LinearGradient(colors: [
        Color(0xff0E3350),
        Color(0xff25435A),
      ]),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset("assets/images/Indobre.png"),
              SizedBox(
                height: 50,
              ),
              Container(
                padding: EdgeInsets.only(bottom: 70),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                    Colors.white38,
                    Colors.white,
                  ]),
                  color: Color.fromARGB(35, 254, 254, 254),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "Layanan konsultasi dan bantuan hukum ini adalah \n gratis/",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: "pro bono",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ", bagi masyarakat kurang mampu yang berdomisili di Provinsi ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: "Kalimantan Timur",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                decorationThickness: 2
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "(dengan menyertakan SKTM/Surat Keterangan Tidak Mampu)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 70,
                      ),
                      DefaultButton(
                          text: "Lanjutkan",
                          press: () {
                            Navigator.pushReplacementNamed(context, "/login");
                          },
                          bgcolor: KPrimaryColor,
                          textColor: Colors.white),
                      SizedBox(
                        height: 70,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
