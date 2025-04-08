import 'dart:math';

import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Account/components/selections.dart';
import 'package:aplikasi_lkbh_unmul/services/auth_service.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AccountScreen extends StatefulWidget {
  static String routeName = "/account";
  AccountScreen({super.key,});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final auth = AuthService();
  String? userName;

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  Future<void> getUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // print("User UID: ${user.uid}"); // Cek UID

        String uid = user.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          // print("Data ditemukan: ${userDoc.data()}");  // Debug data
          setState(() {
            userName = userDoc['nama'];
          });
        } else {
          print('User tidak ditemukan di Firestore');
        }
      } else {
        print('User belum login');
      }
    } catch (e) {
      print('Error: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30,),
                Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                      color: Colors
                          .primaries[Random().nextInt(Colors.primaries.length)],
                      shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      userName.toString().substring(0, 1).toUpperCase(),
                      // auth.getCurrentUser()!.email.toString().substring(0, 4).toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  userName ?? "Nama Pengguna",
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
      ),
    );
  }
}
