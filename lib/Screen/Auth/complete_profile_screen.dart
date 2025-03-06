import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class CompleteProfileScreen extends StatefulWidget {
  static String routeName = "/complete_profile";
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  TextEditingController dateController = TextEditingController();
  String? selectedProfesi = 'Profesi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Kamu pengguna baru di",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Konsulhukum",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: KPrimaryColor,
                        height: 0),
                  ),
                  Text(
                    "Lengkapi Profil kamu sebelum kamu bisa \n lanjutkan untuk konsultasi!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: KGray),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Form(
                        child: Column(
                      children: [
                        namaForm(),
                        SizedBox(
                          height: 10,
                        ),
                        umurPicker(context),
                        SizedBox(
                          height: 10,
                        ),
                        profesiPicker(),
                        SizedBox(
                          height: 5,
                        ),
                        teleponForm(),
                        SizedBox(
                          height: 10,
                        ),
                        alamatForm(),
                        SizedBox(
                          height: 10,
                        ),
                        alamatDomisili(),
                        SizedBox(
                          height: 10,
                        ),
                        nikForm(),
                        // ErrorMessageForm(errors: errors)
                        SizedBox(
                          height: 50,
                        ),
                        DefaultButton(
                            text: "Lanjut",
                            press: () {},
                            bgcolor: KPrimaryColor,
                            textColor: Colors.white),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Kamu akan masuk aplikasi menggunakan \n akun example@mail.com",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: KGray),
                        ),
                      ],
                    )),
                  )
                ],
              ),
            )),
      ),
    );
  }

  TextFormField alamatDomisili() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset("assets/icons/Domisili Icon.svg"),
        ),
        labelText: "Alamat domisili sekarang",
        hintText: "Provinsi, Kota, Jalan",
      ),
    );
  }

  TextFormField nikForm() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset("assets/icons/KTP Icon.svg"),
        ),
        labelText: "(NIK) Nomor Induk Kependudukan",
        hintText: "Nomor NIK",
      ),
      keyboardType: TextInputType.number,
    );
  }

  TextFormField alamatForm() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset("assets/icons/Address Icon.svg"),
        ),
        labelText: "Alamat sesuai KTP",
        hintText: "Provinsi, Kota, Jalan",
      ),
    );
  }

  TextFormField teleponForm() {
    return TextFormField(
      decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset("assets/icons/Telepon Icon.svg"),
          ),
          labelText: "Nomor telepon",
          hintText: "62+"),
      keyboardType: TextInputType.phone,
    );
  }

  DropdownButtonFormField<String> profesiPicker() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset("assets/icons/Profesi Icon.svg"),
        ),
      ),
      value: selectedProfesi,
      style: TextStyle(
          fontSize: 17, color: Color(0xff909090), fontWeight: FontWeight.w600),
      items: <String>[
        "Profesi",
        "Guru",
        "Dokter",
        "Perawat",
        "Insinyur",
        "Akuntan",
        "Pengacara",
        "Polisi",
        "Tentara",
        "Pegawai Negeri Sipil (PNS)",
        "Arsitek",
        "Sales/Marketing",
        "Petani",
        "Nelayan",
        "Chef/Koki",
        "Pengusaha",
        "Customer Service",
        "Ahli IT (Information Technology)",
        "Tukang Bangunan",
        "Pekerjaan lain"
      ].map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (String? newValue) {
        selectedProfesi = newValue;
      },
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(20),
      menuMaxHeight: 400,
      elevation: 1,
      padding: EdgeInsets.only(right: 5),
      icon: Icon(
        Icons.arrow_drop_down_circle_rounded,
        color: Colors.grey.shade500,
      ),
    );
  }

  TextFormField umurPicker(BuildContext context) {
    return TextFormField(
      controller: dateController,
      decoration: InputDecoration(
        labelText: "Umur",
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset("assets/icons/Calendar Icon.svg"),
        ),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: KPrimaryColor, 
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor:
                    Colors.white, // Background color of the date picker
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          dateController.text = formattedDate;
        }
      },
    );
  }

  TextFormField namaForm() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: "Nama Lengkap",
          hintText: "Berikan nama lengkap kamu",
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset("assets/icons/User Icon.svg"),
          )),
    );
  }
}
