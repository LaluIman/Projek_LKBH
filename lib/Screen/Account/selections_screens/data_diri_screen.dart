import 'package:aplikasi_lkbh_unmul/read%20data/get_user_data.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DataDiriScreen extends StatefulWidget {
  const DataDiriScreen({super.key});

  static String routeName = "/datadiri";

  @override
  State<DataDiriScreen> createState() => _DataDiriScreenState();
}

class _DataDiriScreenState extends State<DataDiriScreen> {
  final user = FirebaseAuth.instance.currentUser!; // Ambil user yang login

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: const [
              SizedBox(width: 6),
              Icon(Icons.arrow_back_ios_new, color: KPrimaryColor),
              SizedBox(width: 3),
              Text(
                "Kembali",
                style: TextStyle(
                  fontSize: 16,
                  color: KPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          // Menampilkan data pengguna yang sedang login
          return ListTile(
            title: GetUserData(documentId: user.uid),
          );
        },
      ),
    );
  }
}
