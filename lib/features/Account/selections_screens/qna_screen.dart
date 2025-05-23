import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:aplikasi_lkbh_unmul/features/Account/components/cardFaq.dart';
import 'package:flutter/material.dart';

class QnaScreen extends StatelessWidget {
  const QnaScreen({super.key});

  static String routeName = "/qna";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 150,
        leading: DefaultBackButton(),
        actionsPadding: EdgeInsets.only(right: 20),
        actions: [
          Text(
            'FAQ',
            style: TextTheme.of(context)
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hal yang sering ditanyakan",
                style: TextTheme.of(context).titleMedium?.copyWith(
                    fontWeight: FontWeight.w700, color: KPrimaryColor),
              ),
              Text(
                "Lihat apa saja pertanyaan yang sering ditanyakan oleh pengguna lain",
                style: TextTheme.of(context)
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 30,
              ),
              CardFAQ(
                  question: "Apa itu HukumUnmul?",
                  answer:
                      "HukumUnmul adalah aplikasi konsultasi hukum yang menyediakan layanan konsultasi via chat, pengajuan bantuan hukum, dan pelaporan kasus hukum secara online, khususnya untuk warga Kalimantan Timur."),
              CardFAQ(
                  question: "Siapa saja yang bisa menggunakan layanan di HukumUnmul?",
                  answer:
                      "Semua pengguna dapat menggunakan layanan konsultasi chat. Namun, layanan bantuan hukum dan pelaporan kasus hanya tersedia untuk warga Kalimantan Timur."),
              CardFAQ(
                  question: "Apakah layanan ini berbayar?",
                  answer:
                      "Tidak, semua layanan di HukumUnmul saat ini diberikan secara gratis, namun setiap pengguna dibatasi oleh sistem token harian."),
               CardFAQ(
                  question: "Bagaimana cara menggunakan aplikasi HukumUnmul?",
                  answer:
                      "Untuk mulai menggunakan HukumUnmul, Anda perlu mendaftar akun, melakukan login, dan memilih salah satu dari tiga layanan utama: Konsultasi Chat, Bantuan Hukum, atau Lapor Kasus."),
              CardFAQ(
                  question: "Apa saja layanan yang tersedia di HukumUnmul?",
                  answer:
                      "HukumUnmul menyediakan tiga layanan:\n\nKonsultasi Chat: untuk berdiskusi langsung dengan admin mengenai permasalahan hukum.\n\nBantuan Hukum: untuk mengajukan permohonan pendampingan hukum, khusus warga Kalimantan Timur.\n\nLapor Kasus: untuk melaporkan kasus hukum yang sedang dihadapi."),
              CardFAQ(
                  question: "Apakah saya bisa menggunakan layanan lebih dari satu kali dalam sehari?",
                  answer:
                      "Selama token harian Anda masih tersedia, Anda bisa menggunakan layanan lebih dari satu kali. Jika token habis, Anda harus menunggu hingga token direset keesokan harinya."),
              CardFAQ(
                  question: "Apakah saya bisa menggunakan aplikasi tanpa internet?",
                  answer:
                      "Tidak. Semua layanan HukumUnmul memerlukan koneksi internet yang stabil."),
               CardFAQ(
                  question: "Apakah saya perlu mengunggah dokumen pribadi?",
                  answer:
                      "Ya, untuk layanan Konsutalsi, Bantuan Hukum dan Lapor Kasus, Anda wajib mengunggah KTP sebagai bukti bahwa Anda berdomisili di Kalimantan Timur. Dokumen lain seperti kronologi dan bukti pendukung juga dapat diperlukan."),
              
            ],
          ),
        ),
      ),
    );
  }
}

