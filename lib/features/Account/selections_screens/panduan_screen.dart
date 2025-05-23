import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
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
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Panduan penggunaan",
                  style: TextTheme.of(context).titleMedium?.copyWith(
                      fontWeight: FontWeight.w700, color: KPrimaryColor),
                ),
                Text(
                  "Baca panduan untuk melakukan layanan di aplikasi HukumUnmul.",
                  style: TextTheme.of(context)
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 30,
                ),
                PanduanHeader(
                  icon: Icons.chat,
                  title: "Panduan Layanan Konsultasi Chat",
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Layanan ini memungkinkan Anda untuk berkonsultasi langsung dengan admin mengenai masalah hukum melalui percakapan teks.",
                  style: TextTheme.of(context)
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "- Langkah-langkah Penggunaan:",
                  style: TextTheme.of(context)
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "1. Masuk ke aplikasi dan login menggunakan akun Anda.\n2. Pilih jenis konsultasi. Dan pilih menu konsultasi dan masukan foto KTP dan Permasalahan anda.\n3. Admin akan membalas chat Anda sesegera mungkin.\n4. Riwayat percakapan akan tersimpan dan dapat dilihat kembali.",
                  style: TextTheme.of(context)
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "- Ketentuan:",
                  style: TextTheme.of(context)
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "1. Gunakan bahasa yang sopan dan jelas.\n2. Token akan dikurangi setiap kali Anda memulai sesi konsultasi baru.",
                  style: TextTheme.of(context)
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 20,
                ),
                 PanduanHeader(
                  icon: Icons.policy,
                  title: "Panduan Layanan Bantuan Hukum",
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Fitur ini digunakan untuk mengajukan pendampingan hukum secara langsung, seperti untuk urusan pengadilan, mediasi, atau penanganan kasus hukum serius.",
                  style: TextTheme.of(context)
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "- Langkah-langkah Penggunaan:",
                  style: TextTheme.of(context)
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "1.  Masuk ke aplikasi dan login menggunakan akun Anda.\n2. Pilih jenis konsultasi. Dan pilih menu bantuan hukum dan masukan Nama lengkap, Nomor telepon, Alamat, Unggah foto KTP, Ungggah dokumen SKTM & Pilih jadwal untuk janji temu.\n3. Tunggu respon tim LKBH melalui Whatsapp.",
                  style: TextTheme.of(context)
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                 SizedBox(
                  height: 10,
                ),
                Text(
                  "- Ketentuan:",
                  style: TextTheme.of(context)
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "1.Layanan ini hanya untuk warga Kalimantan Timur.\n2. Pastikan foto KTP yang diunggah jelas dan sesuai format (.png, .jpg, .jpeg).\n3. Admin akan melakukan verifikasi sebelum menindaklanjuti pengajuan.",
                  style: TextTheme.of(context)
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 20,
                ),
                 PanduanHeader(
                  icon: Icons.report_rounded,
                  title: "Panduan Layanan Lapor Kasus",
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Fitur ini digunakan untuk melaporkan kasus hukum yang sedang dihadapi, agar bisa ditindaklanjuti oleh tim hukum HukumUnmul.",
                  style: TextTheme.of(context)
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "- Langkah-langkah Penggunaan:",
                  style: TextTheme.of(context)
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "1.  Masuk ke aplikasi dan login menggunakan akun Anda.\n2. Pilih jenis konsultasi. Dan pilih menu lapor kasus hukum dan masukan Nama lengkap, Nomor telepon, Alamat, Unggah foto KTP, Nama lengkap pihak yang dilaporkan & laporan kasusnya.\n3. Tunggu respon tim LKBH melalui Whatsapp.",
                  style: TextTheme.of(context)
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                 SizedBox(
                  height: 10,
                ),
                Text(
                  "- Ketentuan:",
                  style: TextTheme.of(context)
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "1.Layanan ini hanya untuk warga Kalimantan Timur.\n2. Pastikan foto KTP yang diunggah jelas dan sesuai format (.png, .jpg, .jpeg).\n3. Jangan membuat laporan palsu. Pengguna yang terbukti menyalahgunakan layanan akan diblokir.",
                  style: TextTheme.of(context)
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 50,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PanduanHeader extends StatelessWidget {
  const PanduanHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          title,
          style: TextTheme.of(context)
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        )
      ],
    );
  }
}
