import 'package:aplikasi_lkbh_unmul/features/Account/selections_screens/data_diri_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Account/selections_screens/edit_data_diri_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Account/selections_screens/panduan_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Account/selections_screens/profil_lkbh_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Account/selections_screens/qna_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Auth/complete_profile_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Auth/login_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Account/account_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Auth/register_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Auth/verify_account_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/layanan/layanan_konsultasi/upload_ktp_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/layanan/bantuan_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/layanan/lapor_kasus_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Home/components/home_header/consultation_history.dart';
import 'package:aplikasi_lkbh_unmul/core/components/bottom_navbar.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/consultations_type_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Home/home_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/News/news_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Home/components/home_header/notification.dart';
import 'package:aplikasi_lkbh_unmul/core/screens/no_internet.dart';
import 'package:aplikasi_lkbh_unmul/core/screens/splash_screen.dart';
import 'package:aplikasi_lkbh_unmul/core/screens/terjadwalkan_screen.dart';
import 'package:aplikasi_lkbh_unmul/core/screens/terlaporkan_screen.dart';
import 'package:flutter/material.dart';


final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  CustomBottomNavbar.routeName: (context) => CustomBottomNavbar(),
  LoginScreen.routeName: (context) => LoginScreen(),
  RegisterScreen.routeName: (context) => RegisterScreen(),
  CompleteProfileScreen.routeName: (context) => CompleteProfileScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  ConsultationScreen.routeName: (context) => ConsultationScreen(),
  NewsScreen.routeName: (context) => NewsScreen(),
  AccountScreen.routeName: (context) => AccountScreen(),
  TerjadwalkanScreen.routeName: (context) => TerjadwalkanScreen(),
  TerlaporkanScreen.routeName:(context) => TerlaporkanScreen(),
  VerifyAccountScreen.routeName: (context) => VerifyAccountScreen(),
  //Profile
  DataDiriScreen.routeName: (context) => DataDiriScreen(),
  QnaScreen.routeName: (context) => QnaScreen(),
  PanduanScreen.routeName: (context) => PanduanScreen(),
  ProfilLkbhScreen.routeName: (context) => ProfilLkbhScreen(),
  UploadKTPScreen.routeName: (context) => UploadKTPScreen(),
  BantuanScreen.routeName:(context) => BantuanScreen(),
  LaporScreen.routeName: (context) => LaporScreen(),
  EditDataDiriScreen.routeName: (context) => EditDataDiriScreen(
    documentId: ModalRoute.of(context)!.settings.arguments as String,
  ),
  //Header
  NotificationScreen.routeName: (context) => NotificationScreen(),
  ConsultationHistoryScreen.routeName: (context) => ConsultationHistoryScreen(),
  //No internet
  NoInternetScreen.routeName: (context) => NoInternetScreen()
};