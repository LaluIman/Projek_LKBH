import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  static String routeName = "/account";
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Center(
        child: Text("akun"),
      ),
    );
  }
}