import 'package:aplikasi_lkbh_unmul/Components/default_back_button.dart';
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
        leadingWidth:150,
        leading: DefaultBackButton()
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
              CardFAQ(question: "Apa itu LKBH?", answer: "LKBH adalah singkatan dari Lembaga Konsultasi dan Bantuan Hukum. Lembaga ini adalah wadah pengadian kepada masyarakat yang dibentuk oleh Fakultas Hukum Perguruan Tinggi. Lembaga ini memberikan layanan hukum berupa konsultasi hukum dan bantuan/pendampingan hukum secara cuma-cuma kepada masyarakat (yang mungkin tidak mampu membayar jasa hukum konvensional)"),
              CardFAQ(question: "Cara lapor kasus", answer: "LKBH adalah singkatan dari Lembaga Konsultasi dan Bantuan Hukum. Lembaga ini adalah wadah pengadian kepada masyarakat yang dibentuk oleh Fakultas Hukum Perguruan Tinggi. Lembaga ini memberikan layanan hukum berupa konsultasi hukum dan bantuan/pendampingan hukum secara cuma-cuma kepada masyarakat (yang mungkin tidak mampu membayar jasa hukum konvensional)"),

            ],
          ),
        ),
      ),
    );
  }
}

class CardFAQ extends StatelessWidget {
  const CardFAQ({
    super.key, required this.question, required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EasyFaq(
            questionTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            anserTextStyle: TextStyle(fontSize: 13),
            borderRadius: BorderRadius.circular(5),
            backgroundColor: Colors.white,
            question: question,
            answer: answer),
          SizedBox(height: 10,)
      ],
    );
  }
}
