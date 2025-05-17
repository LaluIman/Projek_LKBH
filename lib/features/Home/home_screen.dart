import 'package:aplikasi_lkbh_unmul/core/components/custom_tooltip.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/consultations_type_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/model.dart';
import 'package:aplikasi_lkbh_unmul/features/Home/components/home_components.dart';
import 'package:aplikasi_lkbh_unmul/features/Home/components/username_cache.dart';
import 'package:aplikasi_lkbh_unmul/core/services/token_service.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
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
  bool _isLoading = true;
  final UserCacheService _userCache = UserCacheService();
  final TokenService _tokenService = TokenService();
  int _tokensLeft = 0;
  bool _isLoadingTokens = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTokenData();
  }

  Future<void> _loadTokenData() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _tokensLeft = 0;
          _isLoadingTokens = false;
        });
      }
      return;
    }

    // First, try to get cached tokens for faster UI update
    Map<String, dynamic>? cachedTokens = _tokenService.getCachedTokens(user.uid);
    if (cachedTokens != null && mounted) {
      setState(() {
        _tokensLeft = cachedTokens['tokensLeft'];
        _isLoadingTokens = false;
      });
    }

    // Then get fresh data from Firestore if needed
    Map<String, dynamic> tokenData = await _tokenService.getUserTokens(user.uid);

    if (mounted) {
      setState(() {
        _tokensLeft = tokenData['tokensLeft'];
        _isLoadingTokens = false;
      });
    }
  } catch (e) {
    print('Error loading token data: $e');
    if (mounted) {
      setState(() {
        _tokensLeft = 0;
        _isLoadingTokens = false;
      });
    }
  }
}


  Future<void> _loadUserData() async {
    try {
      if (_userCache.isInitialized && _userCache.userName != null) {
        if (mounted) {
          setState(() {
            userName = _userCache.userName;
            _isLoading = false;
          });
        }
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      bool isLoaded = await _userCache.loadUserData();

      if (!isLoaded) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/complete_profile');
          }
          return;
        }

        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        if (!_isProfileComplete(data)) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/complete_profile');
          }
          return;
        }
      }

      if (mounted) {
        setState(() {
          userName = _userCache.userName ?? "User";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          userName = "User";
        });
      }
    }
  }

  Future<void> _refreshData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Clear cache to force fresh fetch
      _tokenService.clearCache(user.uid);
      
      // Refresh both user data and token data
      await Future.wait([
        _loadUserData(),
        _loadTokenData(),
      ]);
    }
  }

  bool _isProfileComplete(Map<String, dynamic> data) {
    return data['nama'] != null && data['nama'].toString().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: RefreshIndicator(
            color: KPrimaryColor,
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selamat datang 👋",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: KPrimaryColor),
                                ),
                                SizedBox(height: 5,),
                                _isLoading
                                    ? NameShimmer()
                                    : Text(userName ?? "User",
                                        maxLines: 2,
                                        style: TextTheme.of(context)
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          HomeHeaderButton()
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Carousel(),
                  SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Jenis Konsultasi",
                                  style: TextTheme.of(context)
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              CustomTooltip(
                                  message:
                                      '⚠️ Anda mendapat 3 token per hari untuk layanan hukum.\nGunakan dengan bijak. Token akan reset setiap hari.',
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: KPrimaryColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.bolt,
                                                color: Colors.white,
                                              ),
                                              Text("Token tersisa:",
                                                  style: TextTheme.of(context)
                                                      .bodyLarge
                                                      ?.copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              _isLoadingTokens
                                                  ? SizedBox(
                                                      width: 10,
                                                      height: 10,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Text(
                                                      "$_tokensLeft",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )))
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 5,
                          ),
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            final consultationType =
                                ConsultationType.listConsultationType[index];
                            return JenisKonsultasiItem(
                              consultationType: consultationType,
                              tokensLeft: _tokensLeft,
                              onTokenChanged: _loadTokenData,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  HomeNewsSection()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
