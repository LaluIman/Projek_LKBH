import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

class DataDiriScreen extends StatefulWidget {
  const DataDiriScreen({super.key});

  static String routeName = "/datadiri";

  @override
  State<DataDiriScreen> createState() => _DataDiriScreenState();
}

class _DataDiriScreenState extends State<DataDiriScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leadingWidth: 150,
          leading: DefaultBackButton(),
          actionsPadding: EdgeInsets.only(right: 20),
          actions: [
            Text(
              'Data diri',
              style: TextTheme.of(context).titleMedium?.copyWith(
                fontWeight: FontWeight.w600
              ),
            ),
          ]),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Data tidak ditemukan'));
          }
          
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          
          return _buildUserDataForm(userData);
        },
      ),
    );
  }

  Widget _buildUserDataForm(Map<String, dynamic> userData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Personal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Nama Lengkap
          _buildReadOnlyField(
            label: 'Nama Lengkap',
            value: userData['nama'] ?? 'Tidak ada data',
            icon: "assets/icons/User Icon.svg",
          ),
          
          // Email
          _buildReadOnlyField(
            label: 'Email',
            value: userData['email'] ?? user.email ?? 'Tidak ada data',
            icon: "assets/icons/Mail Icon.svg",
          ),
          
          // Tanggal Lahir
          _buildReadOnlyField(
            label: 'Tanggal Lahir',
            value: userData['tanggal_lahir'] ?? 'Tidak ada data',
            icon: "assets/icons/Calendar Icon.svg",
          ),
          
          // Nomor Telepon
          _buildReadOnlyField(
            label: 'Nomor Telepon', 
            value: userData['telepon'] ?? 'Tidak ada data',
            icon: "assets/icons/Telepon Icon.svg",
          ),
          
          // Alamat KTP
          _buildReadOnlyField(
            label: 'Alamat KTP',
            value: userData['alamat'] ?? 'Tidak ada data',
            icon: "assets/icons/Address Icon.svg",
          ),
          
          // Alamat Domisili
          _buildReadOnlyField(
            label: 'Alamat Domisili',
            value: userData['alamat_domisili'] ?? 'Tidak ada data',
            icon: "assets/icons/Domisili Icon.svg",
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Informasi Tambahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Profesi
          _buildReadOnlyField(
            label: 'Profesi',
            value: userData['profesi'] ?? 'Tidak ada data',
            icon: "assets/icons/Profesi Icon.svg",
          ),
          
          // NIK
          _buildReadOnlyField(
            label: 'NIK',
            value: userData['nik'] ?? 'Tidak ada data',
            icon: "assets/icons/KTP Icon.svg",
          ),
          
          const SizedBox(height: 32),
          
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context, 
                '/editData',
                arguments: user.uid
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: KPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Edit Data",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 50,)
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required String icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
            decoration: BoxDecoration(
              color: KGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SvgPicture.asset(icon),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              
              for (int i = 0; i < 10; i++) ...[
                Container(
                  width: 100,
                  height: 17,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}