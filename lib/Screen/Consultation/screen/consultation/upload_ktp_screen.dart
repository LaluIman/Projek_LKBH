import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:aplikasi_lkbh_unmul/Components/default_back_button.dart';
import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/compenents/consultation_provider.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/screen/consultation/consultation_service.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';

class UploadKTPScreen extends StatefulWidget {
  static String routeName = "/uploadKtp";
  const UploadKTPScreen({super.key});

  @override
  _UploadKTPScreenState createState() => _UploadKTPScreenState();
}

class _UploadKTPScreenState extends State<UploadKTPScreen> {
  XFile? _ktpImage;
  bool _isLoading = false;
  final ConsultationService _consultationService = ConsultationService();
  final ImagePicker _picker = ImagePicker();

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
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _ktpImage = XFile(pickedFile.path);
      });
    }
  }

  Future<void> _uploadKTP() async {
  if (_ktpImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silakan pilih gambar KTP terlebih dahulu')),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final compressedImage = await compressImage(File(_ktpImage!.path));
    final base64Image = base64Encode(compressedImage);

    final consultationType = Provider.of<ConsultationProvider>(context, listen: false).selectedConsultation!;
    
    if (consultationType.name.isEmpty) {
      throw Exception("Jenis konsultasi tidak valid");
    }
    
    print("Image size after compression: ${compressedImage.length} bytes");
    
    // Perbaikan: Tambahkan timeout untuk permintaan
    final consultationId = await _consultationService.createConsultation(
      consultationType,
      base64Image,
    ).timeout(const Duration(seconds: 30), onTimeout: () {
      throw Exception("Koneksi timeout, coba lagi nanti");
    });

    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          consultationId: consultationId,
          consultationType: consultationType.name,
        ),
      ),
    );
  } catch (e) {
    if (mounted) {
      print("❗Upload Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupload KTP: ${e.toString().contains("cloud_firestore") ? "Data tidak valid, periksa kembali informasi Anda" : e}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final consultationProvider = Provider.of<ConsultationProvider>(context);
    final consultationType = consultationProvider.selectedConsultation;
    
    if (consultationType == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return Container();
    }
    
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 150,
        leading: _isLoading ? SizedBox() : DefaultBackButton(),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konsultasi Hukum',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: KPrimaryColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Sebelum kamu bisa lanjut ke tahap konsultasi kamu upload KTP dan jelaskan permasalahanmu dulu ya',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
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
                            consultationType.name,
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
                SizedBox(height: 20),
                Text(
                  "Upload KTP",
                  style: TextStyle(
                    fontSize: 18, 
                    color: Colors.black, 
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
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
                SizedBox(height: 40),
                DefaultButton(
                  text: "Lanjutkan", 
                  press: _uploadKTP, 
                  bgcolor: KPrimaryColor, 
                  textColor: Colors.white,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}