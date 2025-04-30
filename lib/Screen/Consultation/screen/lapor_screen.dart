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
  bool _isSubmitting = false;
  bool _isLoadingUserData = true; 

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
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
              _reporterController.text = doc['nama'] ?? '';
              _numberController.text = doc['telepon'] ?? '';
              _addressController.text = doc['alamat'] ?? '';
              _isLoadingUserData = false; 
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
        minWidth: 600, 
        minHeight: 600, 
        quality: 40, 
      );
      return result ?? await file.readAsBytes(); // fallback
    } catch (e) {
      print("❗Compress Error: $e");
      return await file.readAsBytes(); 
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
    final selected = Provider.of<ConsultationProvider>(context, listen: false).selectedConsultation;

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

    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Layanan belum dipilih."))
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ktpCompressed = await compressImage(File(_ktpImage!.path));
      final ktpBase64 = base64Encode(ktpCompressed);

      await FirebaseFirestore.instance.collection('laporan_kasus').add({
        'uid': user.uid,
        'nama_pelapor': _reporterController.text,
        'telepon': _numberController.text,
        'alamat': _addressController.text,
        'layanan': selected.name, 
        'nama_terlapor': _reportedController.text,
        'isi_laporan': _reportController.text,
        'ktp_image': ktpBase64,
        'timestamp': FieldValue.serverTimestamp()
      });

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        Navigator.pushNamed(context, "/terlaporkan");
      }
    } catch (e) {
      print("🔥 ERROR: $e");
      
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim laporan. Silakan coba lagi."))
        );
      }
    }
  }

  Widget buildLoadingTextField({
    required TextEditingController controller,
    required String label,
    required String iconPath,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return _isLoadingUserData
      ? TextFormField(
          enabled: false,
          decoration: InputDecoration(
            labelText: label,
            hintText: "Memuat data...",
            prefixIcon: Padding(
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(iconPath),
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            labelText: label,
            hintStyle: TextStyle(fontWeight: FontWeight.w500),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(iconPath),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final selected = Provider.of<ConsultationProvider>(context).selectedConsultation;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 150,
        leading: _isSubmitting ? SizedBox() : DefaultBackButton()
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
             Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Colors.grey.shade500)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("Jenis konsultasi: ", style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600
                          ),),
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
              Text("Isi semua formulir dibawah ini sepeti yang di minta."),
              SizedBox(height: 40,),
              buildLoadingTextField(
                controller: _reporterController,
                label: "Nama Lengkap Pelapor",
                iconPath: "assets/icons/User Icon.svg"
              ),
              
              SizedBox(height: 7,),
              buildLoadingTextField(
                controller: _numberController,
                label: "Nomor Telepon",
                iconPath: "assets/icons/Telepon Icon.svg",
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]
              ),
              
              SizedBox(height: 7,),
              buildLoadingTextField(
                controller: _addressController,
                label: "Alamat",
                iconPath: "assets/icons/Address Icon.svg"
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
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset("assets/icons/User Icon.svg"),
                  ),
                )
              ),
              SizedBox(height: 30,),
              TextField(
                controller: _reportController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: "Berikan Laporan Anda",
                  hintStyle: TextStyle(fontWeight: FontWeight.w500),
                  contentPadding: EdgeInsets.all(10)
                ),
              ),
              SizedBox(height: 30,),
              DefaultButton(
                text: "Kirim Laporan", 
                press: _submitReport, 
                bgcolor: KPrimaryColor, 
                textColor: Colors.white,
                isLoading: _isSubmitting,
              ),
              SizedBox(height: 70,),
            ],
          ),
        ),
      ),
    );
  }
}