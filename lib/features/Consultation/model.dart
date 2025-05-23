import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConsultationType {
  final String id;
  final String name;
  final String icon;

  ConsultationType({
    required this.id,
    required this.name,
    required this.icon,
  });

  static Future<void> precacheIcons(BuildContext context) async {
    for (var type in listConsultationType) {
      await precacheImage(
        ExactAssetImage(SvgPicture(SvgStringLoader as BytesLoader) as String, package: type.icon),
        context,
      );
    }
  }

  static List<ConsultationType> listConsultationType = [
    ConsultationType(id: "Waris", name: "Waris", icon: "assets/icons/konsultasi/Waris Icon.svg"),
    ConsultationType(id: "Perusahaan", name: "Perusahaan", icon: "assets/icons/konsultasi/Perusahaan Icon.svg"),
    ConsultationType(id: "Pertanahan & Properti", name: "Pertanahan & Properti", icon: "assets/icons/konsultasi/P&P Icon.svg"),
    ConsultationType(id: "Asuransi", name: "Asuransi", icon: "assets/icons/konsultasi/Asuransi Icon.svg"),
    ConsultationType(id: "Perceraian", name: "Perceraian", icon: "assets/icons/konsultasi/Penceraian Icon.svg"),
    ConsultationType(id: "Perkawinan", name: "Perkawinan", icon: "assets/icons/konsultasi/Perkawinan Icon.svg"),
    ConsultationType(id: "Kehutanan & Perkebunan", name: "Kehutanan & Perkebunan", icon: "assets/icons/konsultasi/Kehutanan Icon.svg"),
    ConsultationType(id: "Pertambangan", name: "Pertambangan", icon: "assets/icons/konsultasi/Pertambangan Icon.svg"),
    ConsultationType(id: "Perjanjian", name: "Perjanjian", icon: "assets/icons/konsultasi/Perjanjain Icon.svg"),
    ConsultationType(id: "Ketenagakerjaan", name: "Ketenagakerjaan", icon: "assets/icons/konsultasi/ketenagakerjaan.svg"),
    ConsultationType(id: "Pidana umum", name: "Pidana umum", icon: "assets/icons/konsultasi/Pidana Icon.svg"),
    ConsultationType(id: "Pemilu", name: "Pemilu", icon: "assets/icons/konsultasi/Pemilu Icon.svg"),
    ConsultationType(id: "HKI", name: "HKI", icon: "assets/icons/konsultasi/HKI Icon.svg"),
    ConsultationType(id: "Pajak", name: "Pajak", icon: "assets/icons/konsultasi/Pajak Icon.svg"),
    ConsultationType(id: "Adopsi", name: "Adopsi", icon: "assets/icons/konsultasi/Adopsi Icon.svg"),
    ConsultationType(id: "Investasi & Pasar Modal", name: "Investasi & Pasar Modal", icon: "assets/icons/konsultasi/Investasi.svg"),
    ConsultationType(id: "Informasi & Teknologi", name: "Informasi & Teknologi", icon: "assets/icons/konsultasi/Teknologi Icon.svg"),
    ConsultationType(id: "Korupsi", name: "Korupsi", icon: "assets/icons/konsultasi/Korupsi Icon.svg"),
    ConsultationType(id: "Perlindungan Konsumen", name: "Perlindungan Konsumen", icon: "assets/icons/konsultasi/Proteksi Icon.svg"),
    ConsultationType(id: "Pengampuan", name: "Pengampuan", icon: "assets/icons/konsultasi/Pengampuan Icon.svg"),
    ConsultationType(id: "Perdagangan", name: "Perdagangan", icon: "assets/icons/konsultasi/Perdagangan Icon.svg"),
    ConsultationType(id: "KDRT", name: "KDRT", icon: "assets/icons/konsultasi/KDRT Icon.svg"),
    ConsultationType(id: "Pinjaman Online", name: "Pinjaman Online", icon: "assets/icons/konsultasi/Pinjol Icon.svg"),
    ConsultationType(id: "Narkoba", name: "Narkoba", icon: "assets/icons/konsultasi/narkoba.svg"),
  ];
}



class LayananButtontChoises {
  final String buttonName;
  final String buttonIcon;
  final String buttonDesc;
  final void Function(BuildContext) click;

  LayananButtontChoises({
    required this.buttonName,
    required this.buttonIcon,
    required this.buttonDesc,
    required this.click,
  });

  static Future<void> precacheIcons(BuildContext context) async {
    for (var layanan in listLayananButtontChoises) {
      await precacheImage(
        ExactAssetImage(SvgPicture(SvgStringLoader as BytesLoader) as String, package: layanan.buttonIcon),
        context,
      );
    }
  }

  static List<LayananButtontChoises> listLayananButtontChoises = [
    LayananButtontChoises(
      buttonName: "Konsultasi",
      buttonDesc: "Ceritakan masalah kamu untuk mendapatkan saran atau pendapat hukum dari kami",
      buttonIcon: "assets/icons/Layanan Konsultasi.svg",
      click: (context) {
        Navigator.pushNamed(context, "/uploadKtp");
      },
    ),
    LayananButtontChoises(
      buttonName: "Bantuan Hukum",
      buttonDesc: "Dapatkan layanan bantuan dan pendampingan hukum secara cuma-cuma bagi masyarakat kurang mampu yang membutuhkan.",
      buttonIcon: "assets/icons/Layanan Bantuan Hukum.svg",
      click: (context) {
        Navigator.pushNamed(context, "/bantuanHukumScreen");
      },
    ),
    LayananButtontChoises(
      buttonName: "Lapor Kasus Hukum",
      buttonDesc: "Laporkan kasus hukum atau peristiwa hukum yang kamu alami atau ketahui.",
      buttonIcon: "assets/icons/Layanan Lapor Kasus.svg",
      click: (context) {
        Navigator.pushNamed(context, "/laporKasusScreen");
      },
    ),
  ];
}