import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_faq/flutter_easy_faq.dart';

class QnaScreen extends StatelessWidget {
  const QnaScreen({super.key});

  static String routeName = "/qna";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              SizedBox(
                width: 6,
              ),
              Icon(Icons.arrow_back_ios_new, color: KPrimaryColor),
              SizedBox(
                width: 3,
              ),
              Text(
                "Kembali",
                style: TextStyle(
                    fontSize: 16,
                    color: KPrimaryColor,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Text(
                "Hal yang sering ditanyakan",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: KPrimaryColor,
                ),
              ),
              Text(
                "Lihat apa saja pertanyaan yang sering \n ditanyakan oleh pengguna lain",
                style: TextStyle(color: KGray),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              EasyFaq(
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.white,
                  question: "Apa itu LKBH?",
                  answer:
                      "LKBH adalah singkatan dari Lembaga Konsultasi dan Bantuan Hukum. Lembaga ini adalah wadah pengadian kepada masyarakat yang dibentuk oleh Fakultas Hukum Perguruan Tinggi. Lembaga ini memberikan layanan hukum berupa konsultasi hukum dan bantuan/pendampingan hukum secara cuma-cuma kepada masyarakat (yang mungkin tidak mampu membayar jasa hukum konvensional)"),
              SizedBox(
                height: 10,
              ),
              EasyFaq(
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.white,
                  question: "Siapa kami?",
                  answer: "LKBH Fakultas Hukum Universitas Mulawarman"),
              SizedBox(
                height: 10,
              ),
              EasyFaq(
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.white,
                  question: "Siapa kami?",
                  answer: "LKBH Fakultas Hukum Universitas Mulawarman"),
               SizedBox(
                height: 10,
              ),
              EasyFaq(
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.white,
                  question: "Siapa kami?",
                  answer: "LKBH Fakultas Hukum Universitas Mulawarman"),
            ],
          ),
        ),
      ),
    );
  }
}
