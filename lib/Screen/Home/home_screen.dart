import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkIfProfileIsComplete();
    });
  }

  Future<void> checkIfProfileIsComplete() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        Navigator.pushReplacementNamed(context, '/complete_profile');
      } else {
        // Cast the data to Map<String, dynamic>
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        if (!_isProfileComplete(data)) {
          Navigator.pushReplacementNamed(context, '/complete_profile');
        } else {
          setState(() {
            userName = data['nama'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error checking profile: $e');
    }
  }


  bool _isProfileComplete(Map<String, dynamic> data) {
    return data['nama'] != null &&
        data['tanggal_lahir'] != null &&
        data['profesi'] != null &&
        data['telepon'] != null &&
        data['alamat'] != null &&
        data['alamat_domisili'] != null &&
        data['nik'] != null &&
        data['nama'].toString().isNotEmpty &&
        data['tanggal_lahir'].toString().isNotEmpty &&
        data['profesi'].toString().isNotEmpty &&
        data['telepon'].toString().isNotEmpty &&
        data['alamat'].toString().isNotEmpty &&
        data['alamat_domisili'].toString().isNotEmpty &&
        data['nik'].toString().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selamat datang 👋",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            color: KPrimaryColor,
                          ),
                        ),
                        Text(
                          userName ?? "User",
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
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
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [0, 1, 2].map((index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.ease,
                      width: _currentIndex == index ? 25 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: KPrimaryColor.withOpacity(_currentIndex == index ? 0.9 : 0.4),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
