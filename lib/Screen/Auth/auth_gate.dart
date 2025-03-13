// import 'package:aplikasi_lkbh_unmul/Screen/Auth/complete_profile_screen.dart';
// import 'package:aplikasi_lkbh_unmul/Screen/Auth/login_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(), 
//         builder: (context, snapshot){
//           //user is log in
//           if (snapshot.hasData) {
//             return CompleteProfileScreen();
//           }else{
//             return LoginScreen();
//           }
//         }
//       ),
//     );
//   }
// }