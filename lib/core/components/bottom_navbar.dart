// ignore_for_file: deprecated_member_use

import 'package:aplikasi_lkbh_unmul/features/Account/account_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/consultations_type_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Home/home_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/News/news_screen.dart';import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomBottomNavbar extends StatefulWidget {
  static String routeName = "/custom_navigation_bar";
  const CustomBottomNavbar({super.key});

  static final GlobalKey<_CustomBottomNavbarState> navigationKey = GlobalKey<_CustomBottomNavbarState>();

  static void navigateToTab(int index) {
    navigationKey.currentState?.changeTab(index);
  }

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar> {
  int _selectedIndex = 0;

   void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _Screens = [
    const HomeScreen(),
    const ConsultationScreen(),
    const NewsScreen(),
    AccountScreen(),
  ];

   final Color selectedIconColor = KPrimaryColor;
   final Color unselectedIconColor = kUnselectedColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: selectedIconColor,
        unselectedItemColor: unselectedIconColor,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600
        ),
         onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        items: [
          //home
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SvgPicture.asset('assets/icons/Home Icon.svg', width: 35, height: 35, fit: BoxFit.cover, 
              color: _selectedIndex == 0 ? selectedIconColor : unselectedIconColor,),
            ),
            label: 'Beranda',
          ),
          //consultation
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SvgPicture.asset('assets/icons/Chat Icon.svg', width: 35, height: 35, fit: BoxFit.cover,
              color: _selectedIndex == 1 ? selectedIconColor : unselectedIconColor,),
            ),
            label: 'Konsultasi',
          ),
          //news
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SvgPicture.asset('assets/icons/News Icon.svg', width: 35, height: 35, fit: BoxFit.cover,
              color: _selectedIndex == 2 ? selectedIconColor : unselectedIconColor,),
            ),
            label: 'Berita',
          ),
          //account
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SvgPicture.asset('assets/icons/Account Icon.svg', width: 35, height: 35, fit: BoxFit.cover,
              color: _selectedIndex == 3 ? selectedIconColor : unselectedIconColor,),
            ),
            label: 'Akun',
          ),
        ],
      )
    );
  }
}