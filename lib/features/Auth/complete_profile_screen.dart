import 'package:aplikasi_lkbh_unmul/core/components/custom_snackbar.dart';
import 'package:aplikasi_lkbh_unmul/core/components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? selectedProfesi = 'Profesi';
  final _namaController = TextEditingController();
  final _dateController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _alamatDomisiliController = TextEditingController();
  final _nikController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _namaController.dispose();
    _dateController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _alamatDomisiliController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  Future<void> completeProfile() async {
    setState(() {
      _isSubmitting = true;
    });
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'nama': _namaController.text.trim(),
            'tanggal_lahir': _dateController.text.trim(),
            'profesi': selectedProfesi,
            'telepon': _teleponController.text.trim(),
            'alamat': _alamatController.text.trim(),
            'alamat_domisili': _alamatDomisiliController.text.trim(),
            'nik': _nikController.text.trim(),
          });
          Navigator.pushReplacementNamed(context, '/custom_navigation_bar');
        }
      } catch (e) {
        DefaultCustomSnackbar.buildSnackbar(
            context, "Gagal menyimpan profil!", KPrimaryColor);
      }
    }
  }

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
                    height: 35,
                  ),
                  Text(
                    "Lengkapi profil",
                    style: TextTheme.of(context)
                        .titleLarge
                        ?.copyWith(color: KPrimaryColor),
                  ),
                  Text(
                    "Lengkapi Profil kamu sebelum kamu bisa \n lanjutkan untuk konsultasi!",
                    style: TextTheme.of(context).bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            buildTextFormField(
                                controller: _namaController,
                                label: "Nama Lengkap",
                                icon: "assets/icons/User Icon.svg"),
                            buildDatePicker(),
                            buildProfesiDropdown(),
                            buildTextFormField(
                                controller: _teleponController,
                                label: "Nomor Telepon",
                                hint: "08*********",
                                icon: "assets/icons/Telepon Icon.svg",
                                keyboardType: TextInputType.phone),
                            buildTextFormField(
                                controller: _alamatController,
                                label: "Alamat KTP",
                                hint: "Sesuai dengan KTP anda",
                                icon: "assets/icons/Address Icon.svg"),
                            buildTextFormField(
                                controller: _alamatDomisiliController,
                                label: "Alamat Domisili",
                                hint: "Jalan, Perumahan, Kota, Provinsi",
                                icon: "assets/icons/Domisili Icon.svg"),
                            buildTextFormField(
                                controller: _nikController,
                                label: "NIK",
                                hint: "Sesuai dengan KTP anda",
                                icon: "assets/icons/KTP Icon.svg",
                                keyboardType: TextInputType.number),
                            SizedBox(height: 20),
                            DefaultButton(
                              text: "Simpan Profil",
                              press: completeProfile,
                              bgcolor: KPrimaryColor,
                              textColor: Colors.white,
                              isLoading: _isSubmitting,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }

  Widget buildProfesiDropdown() {
    List<String> profesiList = [
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
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        menuMaxHeight: 400,
        dropdownColor: Colors.white,
        elevation: 1,
        borderRadius: BorderRadius.circular(16),
        value: selectedProfesi,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset("assets/icons/Profesi Icon.svg"),
          ),
        ),
        items: profesiList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: TextTheme.of(context).bodyLarge),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedProfesi = newValue;
          });
        },
        validator: (value) =>
            value == "Profesi" ? "Pilih profesi yang sesuai" : null,
      ),
    );
  }

  Widget buildTextFormField(
      {required TextEditingController controller,
      required String label,
      required String icon,
      String? hint,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(icon),
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) =>
            value == null || value.isEmpty ? "$label tidak boleh kosong" : null,
      ),
    );
  }

  Widget buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _dateController,
        decoration: InputDecoration(
          labelText: "Tanggal Lahir",
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
                  ),
                  dialogBackgroundColor: Colors.white,
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
        validator: (value) => value == null || value.isEmpty
            ? "Tanggal lahir tidak boleh kosong"
            : null,
      ),
    );
  }
}
