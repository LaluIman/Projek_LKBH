import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get current user
  User? getCurrentUser(){
    return _auth.currentUser;
  }

  //google sign in
  signInWithGoogle() async{
    //interactive sign in proses
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    //when user cancel sign in
    if (googleUser == null) return;

    //google authentication
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    //create new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );

    //finally sign in user
    return await _auth.signInWithCredential(credential);
  }

  // Perbaikan di AuthService
    Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
      try {
        // Coba melakukan login ke Firebase
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, 
          password: password,
        );

        // Simpan user ke Firestore jika belum ada
        // await _firestore.collection("Users").doc(userCredential.user!.uid).set(
        //   {
        //     "uid": userCredential.user!.uid,
        //     "email": email,
        //   }, 
        // );

        return userCredential;

      } on FirebaseAuthException catch (e) {
        // Tangani berbagai jenis error Firebase Auth
        if (e.code == 'user-not-found') {
          throw Exception("Akun tidak ditemukan. Silakan daftar terlebih dahulu.");
        } else if (e.code == 'wrong-password') {
          throw Exception("Password salah. Coba lagi.");
        } else if (e.code == 'invalid-email') {
          throw Exception("Format email tidak valid.");
        } else if (e.code == 'too-many-requests') {
          throw Exception("Terlalu banyak percobaan login. Coba lagi nanti.");
        } else {
          throw Exception("Login gagal. Periksa kembali email dan password Anda.");
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