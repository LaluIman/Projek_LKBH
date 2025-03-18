import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EditDataDiriScreen extends StatefulWidget {
  final String documentId;
  static String routeName = "/editData";

  const EditDataDiriScreen({super.key, required this.documentId});

  @override
  _EditDataDiriScreenState createState() => _EditDataDiriScreenState();
}

class _EditDataDiriScreenState extends State<EditDataDiriScreen> {
  String? selectedProfesi;
  final _namaController = TextEditingController();
  final _dateController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _alamatDomisiliController = TextEditingController();
  final _nikController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(widget.documentId).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        _namaController.text = data['nama'] ?? '';
        _dateController.text = data['tanggal_lahir'] ?? '';
        selectedProfesi = data['profesi'] ?? 'Profesi';
        _teleponController.text = data['telepon'] ?? '';
        _alamatController.text = data['alamat'] ?? '';
        _alamatDomisiliController.text = data['alamat_domisili'] ?? '';
        _nikController.text = data['nik'] ?? '';
      });
    }
  }

  Future<void> showConfirmationDialog() async {
  bool? confirm = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: KPrimaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        contentTextStyle: const TextStyle(
          color: Colors.black,
        ),
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda ingin mengedit data Anda?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Edit",
                style: TextStyle(
                  color: KPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    await editProfile();
  }
}

Future<void> editProfile() async {
  if (_formKey.currentState!.validate()) {
    // Tampilkan loading selama proses update
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.inkDrop(color: KPrimaryColor, size: 70),
            const SizedBox(height: 20),
            const Text(
              "Mengupdate Data...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.documentId).update({
        'nama': _namaController.text.trim(),
        'tanggal_lahir': _dateController.text.trim(),
        'profesi': selectedProfesi,
        'telepon': _teleponController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'alamat_domisili': _alamatDomisiliController.text.trim(),
        'nik': _nikController.text.trim(),
      });

      await Future.delayed(const Duration(seconds: 3));

      // Tutup loading
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil berhasil diperbarui")));
      Navigator.pushReplacementNamed(context, "/datadiri");
    } catch (e) {
      Navigator.pop(context); // Tutup loading kalau gagal
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan profil: $e")));
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
                    "Edit Data",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: KPrimaryColor,
                    ),
                ),
                Text(
                    "Lengkapi Profil kamu sebelum kamu bisa \n lanjutkan untuk konsultasi!",
                    style: TextStyle(color: KGray),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 35),
                          buildTextFormField(controller: _namaController, label: "Nama Lengkap", icon: "assets/icons/User Icon.svg"),
                          buildDatePicker(),
                          buildProfesiDropdown(),
                          buildTextFormField(controller: _teleponController, label: "Nomor Telepon", icon: "assets/icons/Telepon Icon.svg", keyboardType: TextInputType.phone),
                          buildTextFormField(controller: _alamatController, label: "Alamat KTP", icon: "assets/icons/Address Icon.svg"),
                          buildTextFormField(controller: _alamatDomisiliController, label: "Alamat Domisili", icon: "assets/icons/Domisili Icon.svg"),
                          buildTextFormField(controller: _nikController, label: "NIK", icon: "assets/icons/KTP Icon.svg", keyboardType: TextInputType.number),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                child: const Text("Batal Edit", style: TextStyle(color: Colors.red)),
                              ),
                              ElevatedButton(
                                onPressed: showConfirmationDialog,
                                style: ElevatedButton.styleFrom(backgroundColor: KPrimaryColor),
                                child: const Text("Simpan Profil", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfesiDropdown() {
    List<String> profesiList = [
      "Profesi", "Guru", "Dokter", "Perawat", "Insinyur", "Akuntan", "Pengacara", "Polisi", "Tentara", "PNS", "Arsitek", "Sales/Marketing", "Petani", "Nelayan", "Chef/Koki", "Pengusaha", "Customer Service", "Ahli IT", "Tukang Bangunan", "Pekerjaan lain"
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: selectedProfesi,
        decoration: InputDecoration(
          labelText: "Profesi",
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset("assets/icons/Profesi Icon.svg"),
          ),
        ),
        items: profesiList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedProfesi = newValue;
          });
        },
        validator: (value) => value == "Profesi" ? "Pilih profesi yang sesuai" : null,
      ),
    );
  }

  Widget buildTextFormField({required TextEditingController controller, required String label, required String icon, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child:TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(icon),
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? "$label tidak boleh kosong" : null,
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
          );
          if (pickedDate != null) {
            _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
        validator: (value) => value == null || value.isEmpty ? "Tanggal lahir tidak boleh kosong" : null,
      ),
    );
  }
}
