import 'package:aplikasi_lkbh_unmul/core/services/token_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TokenService _tokenService = TokenService();

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Google sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign-in process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If canceled
      if (googleUser == null) return null;

      // Google authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential for new user
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      );

      // Sign in the user
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Initialize or reset daily tokens
      if (userCredential.user != null) {
        await _tokenService.initializeOrResetTokens(userCredential.user!.uid);
      }
      
      return userCredential;
    } catch (e) {
      print("Google Sign In Error: $e");
      return null;
    }
  }

  // Sign in with email and password for existing users
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Attempt to login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      // Initialize or reset daily tokens
      if (userCredential.user != null) {
        await _tokenService.initializeOrResetTokens(userCredential.user!.uid);
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Error handling
      switch (e.code) {
        case 'user-not-found':
          throw Exception("Akun tidak ditemukan. Silakan daftar terlebih dahulu.");
        case 'wrong-password':
          throw Exception("Password salah. Coba lagi.");
        case 'invalid-email':
          throw Exception("Format email tidak valid.");
        case 'too-many-requests':
          throw Exception("Terlalu banyak percobaan login. Coba lagi nanti.");
        default:
          throw Exception("Login gagal: ${e.message ?? e.code}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan. Silakan coba lagi.");
    }
  }
  
  // Register new user with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      // Create new user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      // Initialize daily tokens for new user
      if (userCredential.user != null) {
        await _tokenService.initializeOrResetTokens(userCredential.user!.uid);
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Error handling
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception("Email sudah digunakan. Silakan gunakan email lain atau login.");
        case 'invalid-email':
          throw Exception("Format email tidak valid.");
        case 'weak-password':
          throw Exception("Password terlalu lemah. Gunakan minimal 6 karakter.");
        case 'operation-not-allowed':
          throw Exception("Registrasi dengan email dan password tidak diaktifkan.");
        default:
          throw Exception("Registrasi gagal: ${e.message ?? e.code}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan. Silakan coba lagi.");
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}