import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetUserData extends StatelessWidget {
  const GetUserData({super.key, required this.documentId});
  final String documentId;

  @override
  Widget build(BuildContext context) {
    // Get the collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Terjadi kesalahan"));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("Data tidak ditemukan"));
        }

        Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) {
          return const Center(child: Text("Data kosong"));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getData(title: "Nama:", data: data['nama']),
              getData(title: "Tanggal Lahir:", data: data['tanggal_lahir']),
              getData(title: "Profesi:", data: data['profesi']),
              getData(title: "Telepon:", data: data['telepon']),
              getData(title: "Alamat:", data: data['alamat']),
              getData(title: "Alamat Domisili:", data: data['alamat_domisili']),
              getData(title: "NIK:", data: data['nik']),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/editData',  // Ganti dengan route halaman edit
                    arguments: documentId, // Kirim documentId ke halaman edit
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: KPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Edit Data",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getData({required String title, String? data}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            data ?? "Tidak tersedia",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
