import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //ambil user saat ini
  User? getCurrentUser(){
    return _auth.currentUser;
  }

  //google sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      //proses sign-innya
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      //jika gak jadi 
      if (googleUser == null) return null;

      //google authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      //bikin credential yang baru untuk user baru
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      );

      //baru user baru sign in
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Google Sign In Error: $e");
      return null;
    }
  }

  // masuk dengan gmail dan password untuk user yang sudah ada
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      // mencoba untuk login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // error cik
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
  
  // registrasi user dengan gmail dan password untuk user baru
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      // bikin user baru
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // error
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
  
  //sign out
  Future<void> signOut() async{
    return await _auth.signOut();
  }
}