import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';
import 'package:flutter/material.dart';

class PanduanScreen extends StatelessWidget {
  static String routeName = "/panduan";
  const PanduanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 150,
        leading: DefaultBackButton(),
        actionsPadding: EdgeInsets.only(right: 20),
        actions: [
          Text(
            'Panduan',
            style: TextTheme.of(context)
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
