import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NoInternetScreen extends StatefulWidget {
  static String routeName = "/no_internet";

  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  Image? image1;

  @override
  void initState() {
    super.initState();
    image1 = Image.asset(
      "assets/images/No Internet.png",
      fit: BoxFit.cover,
      width: 300,
    );
  }

  @override
  void didChangeDependencies() {
    if (image1 != null) {
      precacheImage(image1!.image, context);
    }
    super.didChangeDependencies();
  }

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
                  if (image1 != null) image1!,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
