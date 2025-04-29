import 'dart:convert';
import 'dart:io';
import 'package:aplikasi_lkbh_unmul/Components/default_back_button.dart';
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
  bool _isSubmitting = false;
  bool _isLoadingUserData = true; // New state variable for loading user data

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    // Set loading state to true when starting to fetch
    setState(() {
      _isLoadingUserData = true;
    });
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          if (mounted) {
            setState(() {
              _namaController.text = doc['nama'] ?? '';
              _teleponController.text = doc['telepon'] ?? '';
              _isLoadingUserData = false; // Set loading to false when done
            });
          }
        } else {
          // Document doesn't exist
          if (mounted) {
            setState(() {
              _isLoadingUserData = false;
            });
          }
        }
      } catch (e) {
        // Handle any errors
        if (mounted) {
          setState(() {
            _isLoadingUserData = false;
          });
          print("Error fetching user data: $e");
        }
      }
    } else {
      // No user signed in
      if (mounted) {
        setState(() {
          _isLoadingUserData = false;
        });
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

  Future<bool> _onWillPop() async {
    if (!_isSubmitting) {
      return true;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          titleTextStyle: TextStyle(
              color: KPrimaryColor, fontWeight: FontWeight.w600, fontSize: 20),
          contentTextStyle: TextStyle(
            color: Colors.black,
          ),
          title: Text("Konfirmasi"),
          content: Text(
              "Apakah Anda yakin ingin keluar? Proses pengajuan akan dibatalkan."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Batal",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  "Keluar",
                  style: TextStyle(
                      color: KPrimaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );

    return shouldPop ?? false;
  }

  Future<void> _submitData() async {
    final user = FirebaseAuth.instance.currentUser;
    final selected = Provider.of<ConsultationProvider>(context, listen: false)
        .selectedConsultation;

    if (user == null || _ktpImage == null || _sktmImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Mohon lengkapi semua data dan upload dokumen.")));
      return;
    }

    if (_days == null || _times == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Silakan pilih hari dan waktu janji temu.")));
      return;
    }

    if (_namaController.text.isEmpty || _teleponController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nama dan nomor telepon wajib diisi.")));
      return;
    }

    if (selected == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Layanan belum dipilih.")));
      return;
    }

    // Set loading state to true
    setState(() {
      _isSubmitting = true;
    });

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
        'layanan': selected.name,
        'ktp_image': ktpBase64,
        'sktm_image': sktmBase64,
        'timestamp': FieldValue.serverTimestamp()
      });
      // Reset loading state and navigate
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        Navigator.pushNamed(context, "/terjadwalkan");
      }
    } catch (e) {
      print("🔥 ERROR: $e");

      // Reset loading state
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal mengirim data. Silakan coba lagi.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected =
        Provider.of<ConsultationProvider>(context).selectedConsultation;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
            leadingWidth: 150,
            automaticallyImplyLeading: false, 
            leading: _isSubmitting
                ? SizedBox()
                : DefaultBackButton()),
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
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(width: 1, color: Colors.grey.shade500)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "Jenis konsultasi: ",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            selected!.name,
                            style: TextStyle(
                              fontSize: 18,
                              color: KPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    icon: "assets/icons/User Icon.svg",
                    isLoading: _isLoadingUserData),
                SizedBox(
                  height: 7,
                ),
                buildTextFormField(
                    controller: _teleponController,
                    label: "Nomor Telepon",
                    icon: "assets/icons/Telepon Icon.svg",
                    keyboardType: TextInputType.phone,
                    isLoading: _isLoadingUserData),
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
                        borderRadius: BorderRadius.circular(10),
                          dropdownColor: Colors.white,
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
                              .map((day) => DropdownMenuItem(
                                  value: day, child: Text(day)))
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
                          borderRadius: BorderRadius.circular(10),
                          dropdownColor: Colors.white,
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
                  textColor: Colors.white,
                  isLoading: _isSubmitting,
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
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

  Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String icon,
    TextInputType keyboardType = TextInputType.text,
    bool isLoading = false, 
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: isLoading
          ? TextFormField(
              enabled: false, // Disable the field while loading
              decoration: InputDecoration(
                labelText: label,
                hintText: "Memuat data...",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(icon),
                ),
                suffixIcon: SizedBox(
                  width: 20, 
                  height: 20,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(KPrimaryColor),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : TextFormField(
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