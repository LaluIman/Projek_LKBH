import 'dart:convert';
import 'dart:io';
import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/compenents/consultation_provider.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class BantuanScreen extends StatefulWidget {
  static String routeName = "/bantuanScreen";
  const BantuanScreen({
    super.key,
  });


  @override
  State<BantuanScreen> createState() => _BantuanScreenState();
}

class _BantuanScreenState extends State<BantuanScreen> {
  XFile? _ktpImage;
  XFile? _sktmImage;
  String? _days;
  String? _times;
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        if (mounted) {
          setState(() {
            _namaController.text = doc['nama'] ?? '';
            _teleponController.text = doc['telepon'] ?? '';
          });
        }
      }
    }
  }

  Future<Uint8List> compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 800,
        minHeight: 800,
        quality: 50,
      );
      return result ?? await file.readAsBytes(); // fallback
    } catch (e) {
      print("❗Compress Error: $e");
      return await file.readAsBytes(); // jika gagal, tetap pakai file asli
    }
  }

  Future<void> _pickImage(bool isKTP) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isKTP) {
          _ktpImage = XFile(pickedFile.path);
        } else {
          _sktmImage = XFile(pickedFile.path);
        }
      });
    }
  }

  Future<void> _submitData() async {
    final user = FirebaseAuth.instance.currentUser;
    final selected = Provider.of<ConsultationProvider>(context, listen: false).selectedConsultation;

    if (user == null || _ktpImage == null || _sktmImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mohon lengkapi semua data dan upload dokumen."))
      );
      return;
    }

    if (_days == null || _times == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Silakan pilih hari dan waktu janji temu."))
      );
      return;
    }

    if (_namaController.text.isEmpty || _teleponController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nama dan nomor telepon wajib diisi."))
      );
      return;
    }

    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Layanan belum dipilih."))
      );
      return;
    }

    try {
      // Kompres gambar sebelum encode base64
      final ktpCompressed = await compressImage(File(_ktpImage!.path));
      final sktmCompressed = await compressImage(File(_sktmImage!.path));

      final ktpBase64 = base64Encode(ktpCompressed);
      final sktmBase64 = base64Encode(sktmCompressed);

      await FirebaseFirestore.instance.collection('bantuan_hukum').add({
        'uid': user.uid,
        'nama': _namaController.text,
        'telepon': _teleponController.text,
        'hari': _days,
        'waktu': _times,
        'layanan': selected.name, // ✅ Tambahkan nama layanan di sini
        'ktp_image': ktpBase64,
        'sktm_image': sktmBase64,
        'timestamp': FieldValue.serverTimestamp()
      });

      // Tampilkan loading selama 3 detik
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.inkDrop(color: KPrimaryColor, size: 70),
              SizedBox(height: 30),
              Text(
                "Tunggu sebentar...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none),
              ),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 3));

      // Tutup loading dan navigasi ke halaman berikutnya
      Navigator.pop(context);
      Navigator.pushNamed(context, "/terjadwalkan");
    } catch (e) {
      print("🔥 ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim data. Silakan coba lagi."))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = Provider.of<ConsultationProvider>(context).selectedConsultation;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 6,
              ),
              Icon(
                Icons.arrow_back_ios_new,
                color: KPrimaryColor,
                size: 25,
              ),
              Text(
                "Kembali",
                style: TextStyle(
                    color: KPrimaryColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 17,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bantuan Hukum",
                style: TextStyle(
                    fontSize: 24,
                    color: KPrimaryColor,
                    fontWeight: FontWeight.w700
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                selected!.name,
                style: TextStyle(
                  fontSize: 18,
                  color: kUnselectedColor,
                  fontWeight: FontWeight.w600
                ),
              ),
              SizedBox(
                height: 7,
              ),
              Text(
                  "Untuk melanjutkan ke layanan bantuan hukum, silahkan upload KTP dan SKTM (Surat Keterangan Tidak Mampu)"),
              SizedBox(
                height: 24,
              ),
              buildTextFormField(
                  controller: _namaController,
                  label: "Nama Lengkap",
                  icon: "assets/icons/User Icon.svg"),
              SizedBox(
                height: 7,
              ),
              buildTextFormField(
                  controller: _teleponController,
                  label: "Nomor Telepon",
                  icon: "assets/icons/Telepon Icon.svg",
                  keyboardType: TextInputType.phone),
              SizedBox(
                height: 12,
              ),
              uploadFile(
                uploadName: "Upload KTP",
                img: "assets/images/KTP.png",
                imgTrue: 'assets/images/KTP true.png',
                isKTP: true,
              ),
              SizedBox(
                height: 16,
              ),
              //ini bagian sktm
              uploadFile(
                  uploadName: "Upload SKTM",
                  img: "assets/images/SKTM.png",
                  imgTrue: 'assets/images/SKTM true.png',
                  isKTP: false),
              SizedBox(
                height: 16,
              ),
              Text(
                "Jadwalkan Janji Temu",
                style: TextStyle(
                    fontSize: 24,
                    color: KPrimaryColor,
                    fontWeight: FontWeight.w700),
              ),
              Text("Pilih hari dan waktu untuk janji temu bantuan hukum."),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                        decoration: InputDecoration(
                            hintText: "Pilih Hari",
                            contentPadding: EdgeInsets.only(left: 10)),
                        items: [
                          'Senin',
                          'Selasa',
                          'Rabu',
                          'Kamis',
                          "Jum'at",
                        ]
                            .map((day) =>
                                DropdownMenuItem(value: day, child: Text(day)))
                            .toList(),
                        onChanged: (String? day) {
                          setState(() {
                            _days = day;
                          });
                        }),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          hintText: "Pilih Waktu",
                          contentPadding: EdgeInsets.only(left: 10),
                        ),
                        items: ['09.00 - 11.00', '14.00 - 15.00']
                            .map((time) => DropdownMenuItem(
                                value: time, child: Text(time)))
                            .toList(),
                        onChanged: (String? time) {
                          setState(() {
                            _times = time;
                          });
                        }),
                  )
                ],
              ),
              SizedBox(
                height: 50,
              ),
              DefaultButton(
                  text: "Jadwalkan",
                  press: () => _submitData(),
                  bgcolor: KPrimaryColor,
                  textColor: Colors.white),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget uploadFile(
      {required String uploadName,
      required String img,
      required String imgTrue,
      required bool isKTP}) {
    final selectedImage = isKTP ? _ktpImage : _sktmImage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          uploadName,
          style: TextStyle(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 12,
        ),
        //bagian ktp
        GestureDetector(
          onTap: () => _pickImage(isKTP),
          child: Container(
              width: 400,
              height: 150,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 235, 235, 235),
                  borderRadius: BorderRadius.circular(20)),
              child: selectedImage == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(img),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Format png, jpg, jpeg",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(imgTrue),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Foto telah diupload!",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            "Upload ulang?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    )),
        ),
      ],
    );
  }

  Widget buildTextFormField(
      {required TextEditingController controller,
      required String label,
      required String icon,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
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
}
