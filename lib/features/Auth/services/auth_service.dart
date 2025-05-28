import 'package:aplikasi_lkbh_unmul/core/services/token_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TokenService _tokenService = TokenService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Menyimpan ID user terakhir yang diinisialisasi tokennya dalam 1 sesi
  static String? _lastInitializedUserId;

  // Ambil user yang sedang login
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Cek metode login yang sudah terdaftar untuk email tertentu
  Future<List<String>> _getSignInMethodsForEmail(String email) async {
    try {
      return await _auth.fetchSignInMethodsForEmail(email);
    } catch (e) {
      print("Gagal cek metode login: $e");
      return [];
    }
  }

  // Cek apakah profil user sudah ada di Firestore
  Future<bool> _checkUserProfileExists(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.exists && userDoc.data() != null;
    } catch (e) {
      print("Gagal cek profil user: $e");
      return false;
    }
  }

  // Login dengan Google, serta deteksi jika email sudah terdaftar dengan metode lain
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print("Memulai Google Sign In...");
      
      // Cek apakah sudah ada user yang sign in sebelumnya
      GoogleSignInAccount? currentGoogleUser = _googleSignIn.currentUser;
      if (currentGoogleUser != null) {
        print("Ditemukan user Google yang sudah sign in: ${currentGoogleUser.email}");
        // Silently sign in jika sudah ada
        await _googleSignIn.signInSilently();
      }
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Jika login dibatalkan atau gagal
      if (googleUser == null) {
        print("Google Sign In dibatalkan oleh user atau gagal");
        return null;
      }

      String email = googleUser.email;
      print("Berhasil mendapat akun Google: $email");

      // Cek apakah email sudah terdaftar dengan metode lain
      List<String> signInMethods = await _getSignInMethodsForEmail(email);
      print("Sign in methods untuk email ini: $signInMethods");

      // Jika sudah terdaftar dan bukan Google
      if (signInMethods.isNotEmpty && !signInMethods.contains('google.com')) {
        if (signInMethods.contains('password')) {
          // Sign out Google karena ada konflik
          await _googleSignIn.signOut();
          throw Exception(
            "Email ini sudah terdaftar dengan metode email/password. "
            "Silakan login menggunakan email dan password, atau hubungi admin untuk menggabungkan akun."
          );
        }
      }

      print("Mendapatkan authentication credential...");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Pastikan access token dan id token ada
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print("Token Google null - accessToken: ${googleAuth.accessToken}, idToken: ${googleAuth.idToken}");
        await _googleSignIn.signOut();
        throw Exception("Gagal mendapatkan token dari Google");
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      );

      print("Mencoba login ke Firebase dengan credential...");

      // Login ke Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;
        print("Login berhasil! User ID: $userId, Email: ${userCredential.user!.email}");

        // Inisialisasi token jika belum dilakukan di sesi ini
        if (_lastInitializedUserId != userId) {
          try {
            bool profileExists = await _checkUserProfileExists(userId);
            print("Profile exists: $profileExists");
            
            if (!profileExists) {
              print("Menginisialisasi token untuk user baru");
              await _tokenService.initializeOrResetTokens(userId);
            }
            _lastInitializedUserId = userId;
          } catch (tokenError) {
            print("Error inisialisasi token: $tokenError");
            // Lanjutkan meskipun ada error token
          }
        }
      } else {
        await _googleSignIn.signOut();
        throw Exception("User credential null setelah login");
      }

      return userCredential;
    } on PlatformException catch (e) {
      print("PlatformException: ${e.code} - ${e.message}");
      await _googleSignIn.signOut();
      
      if (e.code == 'sign_in_canceled') {
        print("User membatalkan sign in");
        return null;
      } else if (e.code == 'network_error') {
        throw Exception("Tidak ada koneksi internet. Periksa koneksi Anda.");
      } else {
        throw Exception("Login Google gagal: ${e.message ?? e.code}");
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      await _googleSignIn.signOut();
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception("Email sudah terdaftar dengan metode login lain.");
        case 'invalid-credential':
          throw Exception("Credential Google tidak valid.");
        case 'operation-not-allowed':
          throw Exception("Login Google tidak diizinkan.");
        case 'user-disabled':
          throw Exception("Akun Anda telah dinonaktifkan.");
        default:
          throw Exception("Autentikasi gagal: ${e.message ?? e.code}");
      }
    } catch (e) {
      print("General exception: $e");
      await _googleSignIn.signOut();
      
      if (e.toString().contains("dibatalkan")) {
        return null;
      }
      throw Exception(e.toString());
    }
  }

  // Login menggunakan email dan password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;

        // Inisialisasi token jika belum dilakukan di sesi ini
        if (_lastInitializedUserId != userId) {
          bool profileExists = await _checkUserProfileExists(userId);
          if (!profileExists) {
            await _tokenService.initializeOrResetTokens(userId);
          }
          _lastInitializedUserId = userId;
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception("Akun tidak ditemukan.");
        case 'wrong-password':
          throw Exception("Password salah.");
        case 'invalid-email':
          throw Exception("Format email tidak valid.");
        case 'too-many-requests':
          throw Exception("Terlalu banyak percobaan login.");
        default:
          throw Exception("Login gagal: ${e.message}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat login.");
    }
  }

  // Daftar akun baru dengan email dan password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      List<String> signInMethods = await _getSignInMethodsForEmail(email);

      if (signInMethods.isNotEmpty && signInMethods.contains('google.com')) {
        throw Exception(
          "Email ini sudah terdaftar dengan Google. Silakan login menggunakan Google."
        );
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;
        await _tokenService.initializeOrResetTokens(userId);
        _lastInitializedUserId = userId;
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception("Email sudah digunakan.");
        case 'invalid-email':
          throw Exception("Format email tidak valid.");
        case 'weak-password':
          throw Exception("Password terlalu lemah.");
        default:
          throw Exception("Registrasi gagal: ${e.message}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat registrasi.");
    }
  }

  // Hubungkan akun Google dengan akun email/password
  Future<UserCredential> linkGoogleAccount() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("Tidak ada user yang login.");
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception("Login Google dibatalkan.");
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await currentUser.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'provider-already-linked':
          throw Exception("Akun Google sudah terhubung.");
        case 'credential-already-in-use':
          throw Exception("Akun Google sudah dipakai oleh user lain.");
        default:
          throw Exception("Gagal menghubungkan akun: ${e.message}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat menghubungkan akun Google.");
    }
  }

  // Lepaskan akun Google dari akun user saat ini
  Future<User> unlinkGoogleAccount() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("Tidak ada user yang login.");

      // Pastikan masih ada metode login lain sebelum melepas
      bool hasPassword = currentUser.providerData.any((p) => p.providerId == 'password');
      if (!hasPassword) {
        throw Exception("Tidak bisa melepas Google karena tidak ada login lain. Silakan atur password dulu.");
      }

      return await currentUser.unlink('google.com');
    } on FirebaseAuthException catch (e) {
      throw Exception("Gagal melepas akun Google: ${e.message ?? e.code}");
    } catch (e) {
      throw Exception("Terjadi kesalahan saat melepas akun Google.");
    }
  }

  // Ambil metode login yang tersedia untuk user saat ini
  Future<List<String>> getUserSignInMethods() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.email == null) return [];
      return await _getSignInMethodsForEmail(currentUser.email!);
    } catch (e) {
      print("Gagal ambil metode login: $e");
      return [];
    }
  }

  // Cek apakah user masih punya token
  Future<bool> checkTokenAvailability(String userId) async {
    try {
      return await _tokenService.hasTokensAvailable(userId);
    } catch (e) {
      print("Gagal cek token: $e");
      return false;
    }
  }

  // Gunakan 1 token user
  Future<int> consumeToken(String userId) async {
    try {
      return await _tokenService.consumeToken(userId);
    } catch (e) {
      throw Exception("Gagal menggunakan token.");
    }
  }

  // Ambil data token user
  Future<Map<String, dynamic>> getUserTokens(String userId) async {
    try {
      return await _tokenService.getUserTokens(userId);
    } catch (e) {
      throw Exception("Gagal mengambil informasi token.");
    }
  }

  // Cek apakah user perlu lengkapi profil
  Future<bool> needsProfileCompletion(String userId) async {
    try {
      return !(await _checkUserProfileExists(userId));
    } catch (e) {
      print("Error checking profile completion: $e");
      return true;
    }
  }

  // Logout user dari aplikasi
  Future<void> signOut() async {
    try {
      _lastInitializedUserId = null;
      await _googleSignIn.signOut();
      return await _auth.signOut();
    } catch (e) {
      throw Exception("Gagal keluar.");
    }
  }
}