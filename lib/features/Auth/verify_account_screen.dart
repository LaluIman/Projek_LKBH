import 'dart:async';
import 'package:aplikasi_lkbh_unmul/core/components/custom_snackbar.dart';
import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';
import 'package:aplikasi_lkbh_unmul/core/components/default_button.dart';import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
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
      DefaultCustomSnackbar.buildSnackbar(context, "Link verifikasi sudah terkirim di inbox Gmailmu", KSuccess);
      print("verifikasi terkirim");
    } catch (e) {
      DefaultCustomSnackbar.buildSnackbar(context, "Gagal mengirim link verifikasi!", KPrimaryColor);
      print(e);
    } finally {
      setState(() => _isSending = false);
    }
  }

  void startAutoReload() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await user.reload();

      if (user.emailVerified) {
        timer.cancel();
        if (mounted) {
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

          await Future.delayed(const Duration(seconds: 3));

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
        leadingWidth: 150,
        leading: DefaultBackButton()
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
                  style: TextTheme.of(context).titleLarge?.copyWith(
                      color: KPrimaryColor
                    )
                ),
                Text(
                  "Cek Inbox dari akun ${auth.currentUser!.email.toString()} \n dan verifikasi untuk melanjutkan.",
                  style: TextTheme.of(context).bodyLarge,
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
                  style: TextTheme.of(context).bodyMedium,
                  textAlign: TextAlign.center,
                ),
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
