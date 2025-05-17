// services/user_cache_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserCacheService {
  static final UserCacheService _instance = UserCacheService._internal();
  factory UserCacheService() => _instance;
  UserCacheService._internal();

  // Cache untuk menyimpan data user
  String? _userName;
  String? _userId;
  Map<String, dynamic>? _userProfile;
  bool _isInitialized = false;

  // Getter untuk mendapatkan data user
  String? get userName => _userName;
  String? get userId => _userId;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isInitialized => _isInitialized;

  // Method untuk mengatur data user
  void setUserData({
    required String userName,
    required String userId,
    required Map<String, dynamic> userProfile,
  }) {
    _userName = userName;
    _userId = userId;
    _userProfile = userProfile;
    _isInitialized = true;
  }

  // Method untuk menghapus cache (saat logout)
  void clearCache() {
    _userName = null;
    _userId = null;
    _userProfile = null;
    _isInitialized = false;
  }

  // Method untuk load data dari Firestore (hanya sekali)
  Future<bool> loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return false;

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      
      if (data['nama'] == null || data['nama'].toString().isEmpty) {
        return false;
      }

      // Set cache data
      setUserData(
        userName: data['nama'],
        userId: user.uid,
        userProfile: data,
      );

      return true;
    } catch (e) {
      print('Error loading user data: $e');
      return false;
    }
  }
}