import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  static String routeName = "/no_internet";

  final VoidCallback onRefresh;

  const NoInternetScreen({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Terjadwalkan!",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: KPrimaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Image.asset("assets/images/No Internet.png"),
                    SizedBox(
                      height: 50,
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Cek atau sambungkan ke internet\ndan coba lagi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: DefaultButton(
                          text: "Refresh aplikasi",
                          press: onRefresh,
                          bgcolor: KPrimaryColor,
                          textColor: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
