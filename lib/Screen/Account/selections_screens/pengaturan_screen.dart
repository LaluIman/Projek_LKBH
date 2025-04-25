import 'package:aplikasi_lkbh_unmul/Components/default_back_button.dart';
import 'package:flutter/material.dart';

class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  static String routeName = "/pengaturan";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 150,
        leading:DefaultBackButton()
      ),
    );
  }
}