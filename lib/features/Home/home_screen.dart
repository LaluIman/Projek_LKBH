import 'package:aplikasi_lkbh_unmul/core/components/custom_tooltip.dart';
import 'package:aplikasi_lkbh_unmul/core/services/double_tap_exit.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/consultations_type_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/model.dart';
import 'package:aplikasi_lkbh_unmul/features/Home/components/home_components.dart';
import 'package:aplikasi_lkbh_unmul/features/Home/components/username_cache.dart';
import 'package:aplikasi_lkbh_unmul/core/services/token_service.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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

  static const String _hasSeenWelcomeKey = 'has_seen_welcome_dialog';
  static const String _hasSeenTutorialKey = 'has_seen_tutorial';

  final GlobalKey _greetingKey = GlobalKey();
  final GlobalKey _consultationTypeKey = GlobalKey();
  final GlobalKey _tokenKey = GlobalKey();
  final GlobalKey _notifButtonKey = GlobalKey();
  final GlobalKey _chatButtonKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTokenData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createTutorial();
      _checkAndShowWelcomeDialog();
    });
  }

  Future<void> _checkAndShowWelcomeDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool(_hasSeenWelcomeKey) ?? false;

    if (!hasSeenWelcome && mounted) {
      _showWelcomeDialog();
    }
  }

  void _createTutorial() {
    List<TargetFocus> targets = [
      _buildTarget(
        _consultationTypeKey,
        'Jenis Konsultasi',
        'Pilih jenis konsultasi hukum yang Anda butuhkan di sini dan pilih pilih layanan yang anda butuhkan.',
        ContentAlign.top,
      ),
      _buildTarget(
        _tokenKey,
        'Token Konsultasi',
        'Jumlah token yang tersisa untuk melakukan layanan yang tersedia. Token akan direset setiap hari',
        ContentAlign.bottom,
      ),
      _buildTarget(
        _notifButtonKey,
        'Notifikasi',
        'Lihat pemberitahuan laporan & lainnya terbaru di sini',
        ContentAlign.bottom,
      ),
      _buildTarget(
        _chatButtonKey,
        'Riwayat Konsultasi',
        'Akses riwayat konsultasi Anda di sini',
        ContentAlign.bottom,
      ),
    ];
    tutorialCoachMark = TutorialCoachMark(
      useSafeArea: true,
      targets: targets,
      colorShadow: Colors.red.shade700.withOpacity(0.8),
      hideSkip: true,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () async {
        print("Tutorial selesai");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_hasSeenTutorialKey, true);
      },
      onClickTarget: (target) {
        print('${target.identify} clicked');
      },
    );
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selamat datang di HukumUnmul 👋',
                  style: TextTheme.of(context).titleLarge?.copyWith(
                      color: KPrimaryColor, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  'Terima kasih telah menggunakan aplikasi Lembaga Konsultasi dan Bantuan Hukum UNMUL. Mari kita pelajari beberapa fitur - fitur di aplikasi ini!',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Mark welcome dialog as seen
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(_hasSeenWelcomeKey, true);

                      if (mounted) {
                        Navigator.of(context).pop();
                        // Check if user has seen the tutorial before showing it
                        final hasSeenTutorial =
                            prefs.getBool(_hasSeenTutorialKey) ?? false;
                        if (!hasSeenTutorial) {
                          tutorialCoachMark.show(context: context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Lanjut Tutorial',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TargetFocus _buildTarget(
      GlobalKey key, String title, String description, ContentAlign align) {
    return TargetFocus(
      shape: ShapeLightFocus.RRect,
      enableOverlayTab: true,
      radius: 15,
      identify: key.toString(),
      keyTarget: key,
      alignSkip: Alignment.bottomRight,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextTheme.of(context).titleMedium?.copyWith(
                        fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 10),
                Text(description,
                    style: TextTheme.of(context).bodyLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            );
          },
        ),
      ],
    );
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

    //Ambil cached token buat update di UI
    Map<String, dynamic>? cachedTokens = _tokenService.getCachedTokens(user.uid);
    if (cachedTokens != null && mounted) {
      setState(() {
        _tokensLeft = cachedTokens['tokensLeft'];
        _isLoadingTokens = false;
      });
    }

    //refresh token di firestore
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
        Map<String, dynamic>? cachedTokens = _tokenService.getCachedTokens(
          FirebaseAuth.instance.currentUser?.uid ?? ''
        );
        _tokensLeft = cachedTokens?['tokensLeft'] ?? 0;
        _isLoadingTokens = false;
      });
    }
  }
}

// Juga, ubah method _refreshData untuk menghindari double loading:
Future<void> _refreshData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Clear cache untuk memastikan data fresh
    _tokenService.clearUserCache(user.uid);
    
    await Future.wait([
      _loadUserData(),
      _loadTokenData(),
    ]);
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

  bool _isProfileComplete(Map<String, dynamic> data) {
    return data['nama'] != null && data['nama'].toString().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return DoubleTapBackExit(
      child: Scaffold(
        key: _greetingKey,
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
                                  SizedBox(
                                    height: 3,
                                  ),
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
                            HomeHeaderButtonWithKeys(
                              notifButtonKey: _notifButtonKey,
                              chatButtonKey: _chatButtonKey,
                            )
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
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                CustomTooltip(
                                    message:
                                        '⚠️ Anda mendapat 3 token per hari untuk layanan hukum.\nGunakan dengan bijak. Token akan reset setiap hari.',
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: Container(
                                          key: _tokenKey,
                                          decoration: BoxDecoration(
                                            color: KPrimaryColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                                                FontWeight
                                                                    .w700)),
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
                          Container(
                            key: _consultationTypeKey,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 1,
                                mainAxisSpacing: 5,
                              ),
                              itemCount: 8,
                              itemBuilder: (context, index) {
                                final consultationType = ConsultationType
                                    .listConsultationType[index];
                                return JenisKonsultasiItem(
                                  consultationType: consultationType,
                                  tokensLeft: _tokensLeft,
                                  onTokenChanged: _loadTokenData,
                                );
                              },
                            ),
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
      ),
    );
  }
}

// Modified HomeHeaderButton to accept keys for tutorial
class HomeHeaderButtonWithKeys extends StatelessWidget {
  final GlobalKey notifButtonKey;
  final GlobalKey chatButtonKey;

  const HomeHeaderButtonWithKeys({
    required this.notifButtonKey,
    required this.chatButtonKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          key: notifButtonKey,
          onTap: () {
            Navigator.pushNamed(context, "/notificationScreen");
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SvgPicture.asset(
                "assets/icons/Notif.svg",
                width: 17,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        InkWell(
          key: chatButtonKey,
          onTap: () {
            Navigator.pushNamed(context, "/consultation_history");
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SvgPicture.asset(
                "assets/icons/List Chat.svg",
                width: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
