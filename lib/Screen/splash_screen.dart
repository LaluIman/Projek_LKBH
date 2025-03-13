import 'dart:async';

import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5),(){
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Sudah login → ke halaman himbauan
        Navigator.pushReplacementNamed(context, '/custom_navigation_bar');
      } else {
        // Belum login → ke halaman login
        Navigator.pushReplacementNamed(context, '/himbauan');
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/icons/Logo Icon.svg",
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Konsulhukum",
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "LKBH FH Universitas Mulawarman",
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo unmul.png", width: 50, height: 50),
                SizedBox(width: 10,),
                Image.asset("assets/images/logo lkbh.png", width: 50, height: 50),
              ],
            ),
            SizedBox(height: 10,),
            Text(
              "LKBH FH Universitas Mulawarman terakreditasi B \n berdasarkan Keputusan Menteri Hukum Republik Indonesia \n Nomor: M.HH-6.HN.04.03 Tahun 2024",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
