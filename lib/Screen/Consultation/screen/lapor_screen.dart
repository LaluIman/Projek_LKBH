import 'dart:convert';
import 'dart:io';
import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LaporScreen extends StatefulWidget {
  static String routeName = "/laporScreen";
  const LaporScreen({super.key});

  @override
  State<LaporScreen> createState() => _LaporScreenState();
}

class _LaporScreenState extends State<LaporScreen> {
  final TextEditingController _reporterController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reportedController = TextEditingController();
  final TextEditingController _reportController = TextEditingController();
  
  XFile? _ktpImage;

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
            _reporterController.text = doc['nama'] ?? '';
            _numberController.text = doc['telepon'] ?? '';
            _addressController.text = doc['alamat'] ?? '';
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
      return await file.readAsBytes(); // if failed, use original file
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _ktpImage = XFile(pickedFile.path);
      });
    }
  }

  Future<void> _submitReport() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || _ktpImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Mohon lengkapi semua data dan upload KTP.")));
      return;
    }

    if (_reporterController.text.isEmpty || _numberController.text.isEmpty ||
        _addressController.text.isEmpty || _reportedController.text.isEmpty ||
        _reportController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Mohon lengkapi semua data formulir.")));
      return;
    }

    try {
      // Compress image before encoding to base64
      final ktpCompressed = await compressImage(File(_ktpImage!.path));
      final ktpBase64 = base64Encode(ktpCompressed);

      await FirebaseFirestore.instance.collection('laporan_kasus').add({
        'uid': user.uid,
        'nama_pelapor': _reporterController.text,
        'telepon': _numberController.text,
        'alamat': _addressController.text,
        'nama_terlapor': _reportedController.text,
        'isi_laporan': _reportController.text,
        'ktp_image': ktpBase64,
        'timestamp': FieldValue.serverTimestamp()
      });

      // Show loading for 3 seconds
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
                "Memproses laporan...",
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

      // Close loading dialog and navigate
      Navigator.pop(context);

      Navigator.pushNamed(context, "/terlaporkan");
    } catch (e) {
      print("🔥 ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim laporan. Silakan coba lagi.")));
    }
  }

  @override
  Widget build(BuildContext context) {
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
              SizedBox(width: 6,),
              Icon(Icons.arrow_back_ios_new, color: KPrimaryColor, size: 25,),
              Text("Kembali", style: TextStyle(color: KPrimaryColor, fontWeight: FontWeight.w600),),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              Text("Laporan Kasus Hukum", style: TextStyle(
                fontSize: 24,
                color: KPrimaryColor,
                fontWeight: FontWeight.w600,
              ),),
              Text("Isi semua formulir dibawah ini sepeti yang di minta."),
              SizedBox(height: 40,),
              TextFormField(
                controller: _reporterController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap Pelapor",
                  hintStyle: TextStyle(fontWeight: FontWeight.w500),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset("assets/icons/User Icon.svg"),
                  )
                )
              ),
              SizedBox(height: 7,),
              TextFormField(
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _numberController,
                decoration: InputDecoration(
                  labelText: "Nomor Telepon",
                  hintStyle: TextStyle(fontWeight: FontWeight.w500),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset("assets/icons/Telepon Icon.svg"),
                  )
                )
              ),
              SizedBox(height: 7,),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Alamat",
                  hintStyle: TextStyle(fontWeight: FontWeight.w500),
                  prefixIcon: Icon(Icons.location_on_rounded)
                )
              ),
              SizedBox(height: 20,),
              Text(
                "Upload KTP",
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.black, 
                  fontWeight: FontWeight.w600
                ),
              ),
              SizedBox(height: 12,),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 235, 235, 235),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: _ktpImage == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/KTP.png"),
                            SizedBox(height: 10),
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
                            Image.asset("assets/images/KTP true.png"),
                            SizedBox(height: 10),
                            Text(
                              "Foto telah diupload!",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Upload ulang?",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
              ),
              SizedBox(height: 40,),
              TextFormField(
                controller: _reportedController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap Yang di lapor",
                  hintStyle: TextStyle(fontWeight: FontWeight.w500),
                  prefixIcon: Icon(Icons.person)
                )
              ),
              SizedBox(height: 30,),
              TextField(
                controller: _reportController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: "Berikan Laporan Anda",
                  contentPadding: EdgeInsets.all(16)
                ),
              ),
              SizedBox(height: 30,),
              DefaultButton(
                text: "Kirim Laporan", 
                press: _submitReport, 
                bgcolor: KPrimaryColor, 
                textColor: Colors.white
              ),
              SizedBox(height: 70,),
            ],
          ),
        ),
      ),
    );
  }
}