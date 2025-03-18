import 'package:aplikasi_lkbh_unmul/services/auth_service.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = AuthService();
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    spacing: 0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selamat datang 👋",
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            color: KPrimaryColor),
                      ),
                      Text(
                        auth.getCurrentUser()!.email.toString(),
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              CarouselSlider(
                items: [
                  Image.asset("assets/images/banner 1.png"),
                  Image.asset("assets/images/banner 2.png"),
                  Image.asset("assets/images/banner 1.png"),
                ],
                options: CarouselOptions(
                  height: 200,
                  scrollDirection: Axis.horizontal,
                  enableInfiniteScroll: false,
                  reverse: false,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  autoPlayInterval: Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(milliseconds: 1000),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/banner 1.png"),
                  Image.asset("assets/images/banner 1.png"),
                  Image.asset("assets/images/banner 1.png"),
                ].asMap().entries.map((entry) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    curve: Curves.ease,
                    width: _currentIndex == entry.key ? 25 : 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : KPrimaryColor)
                          .withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
