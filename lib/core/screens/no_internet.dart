import 'package:aplikasi_lkbh_unmul/core/components/custom_snackbar.dart';
import 'package:aplikasi_lkbh_unmul/core/components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:aplikasi_lkbh_unmul/core/services/connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

class NoInternetScreen extends StatefulWidget {
  static String routeName = "/no_internet";

  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final hasInternet =
            await InternetConnectionChecker.createInstance().hasConnection;
        return hasInternet;
      },
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Internet bermasalah!",
                    style: TextTheme.of(context)
                        .titleLarge
                        ?.copyWith(color: KPrimaryColor),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    "assets/images/No Internet.png",
                    fit: BoxFit.cover,
                    width: 300,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Cek atau sambungkan ke internet\ndan coba lagi",
                    textAlign: TextAlign.center,
                    style: TextTheme.of(context)
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: DefaultButton(
                        text: "Coba lagi",
                        press: () async {
                          await _checkConnectionAndNavigate();
                        },
                        bgcolor: KPrimaryColor,
                        textColor: Colors.white,
                        isLoading: _isChecking,),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkConnectionAndNavigate() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final hasInternet =
          await InternetConnectionChecker.createInstance().hasConnection;

      await Provider.of<ConnectivityProvider>(context, listen: false)
          .checkConnection();

      if (hasInternet) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      } else {
        if (mounted) {
          print("Masih belum ada koneksi internet");
        }
      }
    } catch (e) {
      print('Error checking internet connection: $e');
      if (mounted) {
        DefaultCustomSnackbar.buildSnackbar(context, "Terjadi kesalahan saat memeriksa interent", KError);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }
}
