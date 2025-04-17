import 'dart:async';
import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VerifyAccountScreen extends StatefulWidget {
  static String routeName = "/verify";
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final auth = FirebaseAuth.instance;
  String? userName;
  bool _isSending = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    sendverifylink();
    startAutoReload();
  }

  @override
  void dispose() {
    _timer?.cancel(); // pastikan timer dihentikan saat widget di-dispose
    super.dispose();
  }

  Future<void> sendverifylink() async {
    if (_isSending) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSending = true);
    try {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link verifikasi telah dikirim ke email anda"),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim verifikasi: $e")),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void startAutoReload() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await user.reload();

      if (user.emailVerified) {
        timer.cancel();
        if (mounted) {
          // Tampilkan loading dulu
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.inkDrop(
                      color: KPrimaryColor, size: 70),
                  const SizedBox(height: 30),
                  const Text(
                    "Sedang Verifikasi...",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none),
                  ),
                ],
              ),
            ),
          );

          // Delay 2–3 detik biar smooth transisi
          await Future.delayed(const Duration(seconds: 2));

          // Tutup dialog dan pindah ke halaman berikutnya
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, "/complete_profile");
        }
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, "/register");
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
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  "Verifikasi Akun",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: KPrimaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Cek Inbox dari akun ${auth.currentUser!.email.toString()} \n dan verifikasi untuk melanjutkan.",
                  style: TextStyle(color: KGray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                Image.asset(
                  "assets/images/verify.png",
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 40),
                Text(
                  "Pesan verifikasi belum terkirim? Kirim ulang!",
                  style: TextStyle(color: KGray),
                  textAlign: TextAlign.center,
                ),
                // const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: DefaultButton(
                    text: 'Kirim Ulang',
                    press: sendverifylink,
                    bgcolor: KPrimaryColor,
                    textColor: Colors.white,
                    icon: 'assets/icons/Resend Icon.svg',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
