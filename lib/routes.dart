import 'package:aplikasi_lkbh_unmul/Screen/Auth/complete_profile_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Auth/login_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Account/account_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/bottom_navbar.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/consultation_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Home/home_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/News/news_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/himbauan_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/splash_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/success_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/terjadwalkan_screen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  HimbauanScreen.routeName: (context) => HimbauanScreen(),
  CustomBottomNavbar.routeName: (context) => CustomBottomNavbar(),
  LoginScreen.routeName: (context) => LoginScreen(),
  CompleteProfileScreen.routeName: (context) => CompleteProfileScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  ConsultationScreen.routeName: (context) => ConsultationScreen(),
  NewsScreen.routeName: (context) => NewsScreen(),
  AccountScreen.routeName: (context) => AccountScreen(),
  SuccessScreen.routeName: (context) => SuccessScreen(),
  TerjadwalkanScreen.routeName: (context) => TerjadwalkanScreen(),
};