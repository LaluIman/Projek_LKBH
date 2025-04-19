// consultation_type.dart (Model file)

import 'package:flutter/material.dart';

class ConsultationType {
  final String name;
  final String icon;

  ConsultationType({
    required this.name,
    required this.icon,
  });

  static List<ConsultationType> listConsultationType = [
    ConsultationType(name: "Waris", icon: "assets/icons/konsultasi/Waris Icon.svg"),
    ConsultationType(name: "Perusahaan", icon: "assets/icons/konsultasi/Perusahaan Icon.svg"),
    ConsultationType(name: "Pertahanan\n& Properti", icon: "assets/icons/konsultasi/P&P Icon.svg"),
    ConsultationType(name: "Asuransi", icon: "assets/icons/konsultasi/Asuransi Icon.svg"),
    ConsultationType(name: "Penceraian", icon: "assets/icons/konsultasi/Penceraian Icon.svg"),
    ConsultationType(name: "Perkawinan", icon: "assets/icons/konsultasi/Perkawinan Icon.svg"),
    ConsultationType(name: "Kehutanan\n & Perkebunan", icon: "assets/icons/konsultasi/Kehutanan Icon.svg"),
    ConsultationType(name: "Pertambangan", icon: "assets/icons/konsultasi/Pertambangan Icon.svg"),
    ConsultationType(name: "Perjanjian", icon: "assets/icons/konsultasi/Perjanjain Icon.svg"),
    ConsultationType(name: "Ketenagakerjaan", icon: "assets/icons/konsultasi/ketenagakerjaan.svg"),
    ConsultationType(name: "Pidana umum", icon: "assets/icons/konsultasi/Pidana Icon.svg"),
    ConsultationType(name: "Pemilu", icon: "assets/icons/konsultasi/Pemilu Icon.svg"),
    ConsultationType(name: "HKI", icon: "assets/icons/konsultasi/HKI Icon.svg"),
    ConsultationType(name: "Pajak", icon: "assets/icons/konsultasi/Pajak Icon.svg"),
    ConsultationType(name: "Adopsi", icon: "assets/icons/konsultasi/Adopsi Icon.svg"),
    ConsultationType(name: "Investasi &\nPasar modal", icon: "assets/icons/konsultasi/Investasi.svg"),
    ConsultationType(name: "Informasi &\nTeknologi", icon: "assets/icons/konsultasi/Teknologi Icon.svg"),
    ConsultationType(name: "Korupsi", icon: "assets/icons/konsultasi/Korupsi Icon.svg"),
    ConsultationType(name: "Perlindungan\nKonsumen", icon: "assets/icons/konsultasi/Proteksi Icon.svg"),
    ConsultationType(name: "Pengampunan", icon: "assets/icons/konsultasi/Pengampuan Icon.svg"),
    ConsultationType(name: "Perdagangan", icon: "assets/icons/konsultasi/Perdagangan Icon.svg"),
    ConsultationType(name: "KDRT", icon: "assets/icons/konsultasi/KDRT Icon.svg"),
    ConsultationType(name: "Pinjaman\nOnline", icon: "assets/icons/konsultasi/Pinjol Icon.svg"),
    ConsultationType(name: "Narkoba", icon: "assets/icons/konsultasi/narkoba.svg"),
  ];
}


class ButtonConsultantChoises {
  final String buttonName;
  final String buttonIcon;
  final String buttonDesc;
  final void Function(BuildContext) click; // Tambahkan click

  ButtonConsultantChoises({
    required this.buttonName,
    required this.buttonIcon,
    required this.buttonDesc,
    required this.click, // Sekarang wajib ada event click
  });

  static List<ButtonConsultantChoises> listButtonConsultantChoises = [
    ButtonConsultantChoises(
      buttonName: "Konsultasi",
      buttonDesc: "Ceritakan masalah kamu untuk mendapatkan\nsaran atau pendapat hukum dari kami",
      buttonIcon: "assets/icons/Konsultasi Icon.svg",
      click: (context) {
        Navigator.pushNamed(context, "/uploadKtpScreen");
      },
    ),
    ButtonConsultantChoises(
      buttonName: "Bantuan Hukum",
      buttonDesc: "Dapatkan layanan bantuan dan pendampingan hukum secara cuma-cuma bagi masyarakat kurang mampu yang membutuhkan.",
      buttonIcon: "assets/icons/Bantuan Hukum.svg",
      click: (context) {
        Navigator.pushNamed(context, "/bantuanScreen");
      },
    ),
    ButtonConsultantChoises(
      buttonName: "Lapor Kasus Hukum",
      buttonDesc: "Laporkan kasus hukum atau peristiwa hukum yang kamu alami atau ketahui.",
      buttonIcon: "assets/icons/Lapor Kasus Hukum.svg",
      click: (context) {
        Navigator.pushNamed(context, "/laporScreen");
      },
    ),
  ];
}