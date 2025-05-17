import 'dart:async';
import 'package:aplikasi_lkbh_unmul/core/components/bottom_navbar.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
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
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(seconds: 5), () {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>  CustomBottomNavbar(),
              transitionDuration: const Duration(seconds: 0),
            ),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: 20,
            ),
            Text("Konsulhukum",
                style: TextTheme.of(context).titleLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800)),
            Text(
              "LKBH FH Universitas Mulawarman",
              style: TextStyle(
                fontSize: 12,
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
            SizedBox(
              height: 10,
            ),
            Text(
                "LKBH FH Universitas Mulawarman terakreditasi B \n berdasarkan Keputusan Menteri Hukum Republik Indonesia \n Nomor: M.HH-6.HN.04.03 Tahun 2024",
                textAlign: TextAlign.center,
                style: TextTheme.of(context)
                    .bodyMedium
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600))
          ],
        ),
      ),
    );
  }
}
