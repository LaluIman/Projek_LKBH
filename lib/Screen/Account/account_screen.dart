import 'dart:math';

import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Account/components/selections.dart';
import 'package:aplikasi_lkbh_unmul/services/auth_service.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AccountScreen extends StatelessWidget {
  static String routeName = "/account";
  AccountScreen({super.key});
  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                    color: Colors
                        .primaries[Random().nextInt(Colors.primaries.length)],
                    shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    auth.getCurrentUser()!.email.toString().substring(0, 4).toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Nama pengguna",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                auth.getCurrentUser()!.email.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Selections(
                      icon: "assets/icons/User Icon.svg",
                      title: "Data diri",
                      press: () => Navigator.pushNamed(context, "/datadiri")
                    ),
                    Selections(
                      icon: "assets/icons/Setting Icon.svg",
                      title: "Pengaturan",
                      press: () => Navigator.pushNamed(context, "/pengaturan"),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Selections(
                      icon: "assets/icons/QnA Icon.svg",
                      title: "Hal yang sering ditanyakan",
                      press: () => Navigator.pushNamed(context, "/qna"),
                    ),
                    Selections(
                      icon: "assets/icons/ProfileLKBH Icon.svg",
                      title: "Tentang LKBH FH Universitas Mulawarman",
                      press: () => Navigator.pushNamed(context, "/profil_lkbh"),
                    ),
                    Selections(
                      icon: "assets/icons/Feedback Icon.svg",
                      title: "Berikan umpan balik!",
                      press: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: DefaultButton(
                    icon: "assets/icons/Log out.svg",
                    text: "Keluar dari akun ini",
                    press: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            titleTextStyle: TextStyle(
                                color: KPrimaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
                            contentTextStyle: TextStyle(
                              color: Colors.black,
                            ),
                            title: Text("Konfirmasi"),
                            content: Text("Apakah Anda ingin keluar?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Batal",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final auth = AuthService();
                                  auth.signOut();
                                  // Tampilkan loading selama 3 detik
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          LoadingAnimationWidget.inkDrop(
                                              color: KPrimaryColor, size: 70),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            "Keluar dari akun...",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                decoration:
                                                    TextDecoration.none),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                  await Future.delayed(
                                      const Duration(seconds: 3));

                                  Navigator.pop(context);
                                  Navigator.pushReplacementNamed(
                                      context, "/login");
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                    "Keluar",
                                    style: TextStyle(
                                        color: KPrimaryColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    bgcolor: KPrimaryColor,
                    textColor: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
