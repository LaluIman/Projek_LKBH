import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:aplikasi_lkbh_unmul/core/components/custom_snackbar.dart';
import 'package:aplikasi_lkbh_unmul/core/components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/features/Account/components/selections.dart';
import 'package:aplikasi_lkbh_unmul/features/Auth/services/auth_service.dart';
import 'package:aplikasi_lkbh_unmul/features/Home/components/username_cache.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/size_config.dart';import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';

class AccountScreen extends StatefulWidget {
  static String routeName = "/account";
  const AccountScreen({
    super.key,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final auth = AuthService();
  String? userName;
  String? profileImage;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  final UserCacheService _userCache = UserCacheService();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      if (_userCache.isInitialized && _userCache.userName != null) {
        Map<String, dynamic>? cachedProfile = _userCache.userProfile;
        if (mounted) {
          setState(() {
            userName = _userCache.userName;
            profileImage = cachedProfile?['profileImage'];
            _isLoading = false;
          });
        }
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        
        if (mounted) {
          if (userDoc.exists) {
            Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
            
            _userCache.setUserData(
              userName: data['nama'] ?? '',
              userId: uid,
              userProfile: data,
            );
            
            setState(() {
              userName = data['nama'];
              profileImage = data['profileImage'];
              _isLoading = false;
            });
          } else {
            print('User tidak ditemukan di Firestore');
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        print('User belum login');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.inkDrop(color: KPrimaryColor, size: 70),
                SizedBox(height: 20),
                Text(
                  "Menyimpan foto profil...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        );

        final bytes = await File(pickedFile.path).readAsBytes();
        final base64Image = base64Encode(bytes);
        await saveProfileImage(base64Image);
        if (mounted) Navigator.pop(context);
        if (mounted) {
          setState(() {
            profileImage = base64Image;
          });
          
          if (_userCache.userProfile != null) {
            Map<String, dynamic> updatedProfile = Map.from(_userCache.userProfile!);
            updatedProfile['profileImage'] = base64Image;
            _userCache.setUserData(
              userName: _userCache.userName!,
              userId: _userCache.userId!,
              userProfile: updatedProfile,
            );
          }
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      DefaultCustomSnackbar.buildSnackbar(
          context, "Gagal upload gambar", KError);
    }
  }

  Future<void> saveProfileImage(String base64Image) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'profileImage': base64Image,
        });
      }
    } catch (e) {
      print('Error saving profile image: $e');
      rethrow;
    }
  }

  Widget _buildProfilePicShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 130,
        width: 130,
        decoration: BoxDecoration(
          color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (profileImage != null && profileImage!.isNotEmpty) {
      return GestureDetector(
        onTap: pickImage,
        child: Stack(
          children: [
            Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: MemoryImage(base64Decode(profileImage!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: KPrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: pickImage,
        child: Stack(
          children: [
            Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                color:
                    Colors.primaries[Random().nextInt(Colors.primaries.length)],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  userName != null && userName!.isNotEmpty
                      ? userName![0].toUpperCase()
                      : "?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: KPrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildUsernameShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 200,
        height: 25,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget _buildEmailShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: getPropScreenWidth(150),
          height: getPropScreenWidth(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                _isLoading ? _buildProfilePicShimmer() : _buildProfileImage(),
                SizedBox(
                  height: 10,
                ),
                _isLoading
                    ? _buildUsernameShimmer()
                    : Text(
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        userName ?? "Nama Pengguna",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                _isLoading
                    ? _buildEmailShimmer()
                    : Text(
                        auth.getCurrentUser()?.email?.toString() ??
                            "Email tidak tersedia",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Selections(
                              icon: "assets/icons/User Icon.svg",
                              title: "Data diri",
                              press: () =>
                                  Navigator.pushNamed(context, "/datadiri")),
                          Selections(
                            icon: "assets/icons/Panduan.svg",
                            title: "Panduan Penggunaan",
                            press: () =>
                                Navigator.pushNamed(context, "/panduan"),
                          ),
                          Selections(
                            icon: "assets/icons/QnA Icon.svg",
                            title: "Hal yang sering ditanyakan",
                            press: () => Navigator.pushNamed(context, "/qna"),
                          ),
                          Selections(
                            icon: "assets/icons/ProfileLKBH Icon.svg",
                            title: "Tentang LKBH FH UNMUL",
                            press: () =>
                                Navigator.pushNamed(context, "/profil_lkbh"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: DefaultButton(
                      icon: "assets/icons/Log out.svg",
                      text: "Keluar dari akun ini",
                      press: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              titleTextStyle: TextStyle(
                                  color: KPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20),
                              contentTextStyle: TextStyle(
                                color: Colors.black,
                              ),
                              title: Text("Konfirmasi"),
                              content: Text("Apakah Anda ingin keluar?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "Batal",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final auth = AuthService();
                                    auth.signOut();
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            LoadingAnimationWidget.inkDrop(
                                                color: KPrimaryColor, size: 70),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              "Keluar dari akun...",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                    await Future.delayed(
                                        const Duration(seconds: 3));

                                    // Clear cache saat logout
                                    UserCacheService().clearCache();

                                    Navigator.pop(context);
                                    Navigator.pushReplacementNamed(
                                        context, "/login");
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 25, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: KPrimaryColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                      "Keluar",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      bgcolor: KPrimaryColor,
                      textColor: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}