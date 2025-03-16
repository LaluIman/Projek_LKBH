import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilLkbhScreen extends StatelessWidget {
  const ProfilLkbhScreen({super.key});

  static String routeName = "/profil_lkbh";

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
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "LKBH FH UNMUL",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: KPrimaryColor,
                          ),
                        ),
                        Text(
                          "Kenalan dengan Lembaga Konsultasi Bantuan Hukum Fakultas Hukum Universitas Mulawarman",
                          style: TextStyle(color: KGray),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30,),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset("assets/images/fotolkbh.jpg")),
                  SizedBox(height: 30,),
                  Text(
                    textAlign: TextAlign.justify,
                    "Lembaga Konsultasi dan Bantuan Hukum Fakultas Hukum Universitas Mulawarman, disingkat LKBH FH Unmul bertujuan untuk melakukan kegiatan pengabdian masyarakat dengan jalan membangun supremasi hukum, membantu dan memberikan pemahaman di kalangan masyarakat, baik masyarakat yang mampu maupun masyarakat yang tidak mampu, serta memberikan kontrol sosial terhadap perilaku aparat penegak hukum dalam penegakan hukum di masyarakat. Lembaga Konsultasi dan Bantuan Hukum juga menyelenggarakan Kalabahu yang merupakan akronim dari Karya Latihan Bantuan Hukum, Kalabahu merupakan program tahunan yang bertujuan untuk melatih kemampuan para mahasiswa-mahasiswi Fakultas Hukum Universitas Mulawarman dalam memberikan advokasi dan konsultasi hukum."),
                  SizedBox(height: 20,),
                   Text(
                    textAlign: TextAlign.justify,
                    "Ide awal pembentukkan LKBH FH Unmul adalah untuk memberikan ruang kepada dosen yang setiap saat berada di kampus dalam rangka memberikan ilmu pengetahuan kepada para Mahasiswa untuk dapat mempraktikkan keilmuannya dalam suatu perkara. Bukan hanya sebagai advokat yang berperkara, akan tetapi sebagai Saksi Ahli yang keterangannya diperlukan dalam suatu perkara. Ide tersebut kemudian berkembang menjadi sebuah lembaga yang dapat membantu masyarakat secara luas tidak hanya beracara dipersidangan, namun juga untuk konsultasi dan penyelesaian permasalahan lainnya. Sekaligus pula sebagai lembaga yang dapat menelurkan sarjana-sarjana hukum yang sudah siap menjawab tantangan didunia hukum sebagai pengacara/lawyer."),
                  SizedBox(height: 20,),
                  DefaultButton(icon: "assets/icons/Read.svg", text: "Baca selengkapnya", press: ()async {
                    final url = 'https://fh.unmul.ac.id/page/read/lembaga-konsultasi-dan-bantuan-hukum-lkbh';
                    if (await canLaunch(url)) {
                      await launch(
                        url,
                      );
                    }}, bgcolor: KPrimaryColor, textColor: Colors.white),
                   SizedBox(height: 50,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
