import 'package:aplikasi_lkbh_unmul/Screen/Account/selections_screens/data_diri_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Account/selections_screens/edit_data_diri_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Account/selections_screens/pengaturan_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Account/selections_screens/profil_lkbh_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Account/selections_screens/qna_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Auth/complete_profile_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Auth/login_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Account/account_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Auth/register_screen.dart';
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
  RegisterScreen.routeName: (context) => RegisterScreen(),
  CompleteProfileScreen.routeName: (context) => CompleteProfileScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  ConsultationScreen.routeName: (context) => ConsultationScreen(),
  NewsScreen.routeName: (context) => NewsScreen(),
  AccountScreen.routeName: (context) => AccountScreen(),
  SuccessScreen.routeName: (context) => SuccessScreen(),
  TerjadwalkanScreen.routeName: (context) => TerjadwalkanScreen(),
  //Profile
  DataDiriScreen.routeName: (context) => DataDiriScreen(),
  PengaturanScreen.routeName : (context) => PengaturanScreen(),
  QnaScreen.routeName: (context) => QnaScreen(),
  ProfilLkbhScreen.routeName: (context) => ProfilLkbhScreen(),
  EditDataDiriScreen.routeName: (context) => EditDataDiriScreen(
    documentId: ModalRoute.of(context)!.settings.arguments as String,
  ),

};