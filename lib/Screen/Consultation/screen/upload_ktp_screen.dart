import 'package:aplikasi_lkbh_unmul/Components/default_back_button.dart';
import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/screen/chat_screen.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class UploadKtpScreen extends StatefulWidget {
  static String routeName = "/uploadKtpScreen";
  const UploadKtpScreen({super.key});

  @override
  State<UploadKtpScreen> createState() => _UploadKtpScreenState();
}

class _UploadKtpScreenState extends State<UploadKtpScreen> {
  XFile? _selectedImage;
  String? _base64Image;
  String? selectedFileName;
  String? problemUser;
  bool isLoading = false;

  TextEditingController _problemController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String displayNameFile(String name) {
    if (name.length > 20) {
      return name.substring(0, 17) + "...";
    }
    return name;
  }

  Future<void> _pickImageFromGalery() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 60);

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    setState(() {
      selectedFileName = pickedFile.name;
      _base64Image = base64Image;
      _selectedImage = pickedFile;
    });
  }

  Future<void> _sendProblemToFirebase(String? problemUser) async {
    final String currentUserId = _auth.currentUser!.uid;

    if (_base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Silakan upload KTP terlebih dahulu")));
      return;
    } else if (_problemController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Silakan isi masalah Anda")));
      return;
    } else {
      setState(() {
        isLoading = true;
      });
    }

    try {
      await FirebaseFirestore.instance
          .collection('chat_konsultasi')
          .doc(currentUserId)
          .collection('ktp_user')
          .doc('current')
          .set({
        'ktp': _base64Image,
        'uploadAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('chat_konsultasi')
          .doc(currentUserId)
          .collection('problem_user')
          .doc('current')
          .set({
        'problem': _problemController.text,
        'uploadAt': FieldValue.serverTimestamp(),
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(receiverID: "f1TnmpabMmVdMCjFK7GPCfxGrPz1")));
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ups...gagal, coba kirim lagi!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leadingWidth: 150, leading: DefaultBackButton()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
            "Kamu memilih konsultasi",
            style: TextStyle(
                fontSize: 24,
                color: KPrimaryColor,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Sebelum kamu bisa lanjut ke tahap\nkonsultasi kamu upload KTP dulu ya!",
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SvgPicture.asset(
              'assets/icons/kartu.svg',
              height: 180,
              width: 199,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: 383,
              height: 140,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 235, 235, 235),
                  borderRadius: BorderRadius.circular(10)),
              child: GestureDetector(
                onTap: () {
                  _pickImageFromGalery();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    _selectedImage == null
                        ? Image.asset(
                            "assets/images/KTP.png",
                            height: 80,
                            width: 80,
                          )
                        : Image.asset(
                            "assets/images/KTP true.png",
                            height: 80,
                            width: 80,
                          ),
                    if (selectedFileName == null)
                      Text(
                        "format png, jpg, jpeg",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 141, 141, 141),
                        ),
                      ),
                    if (selectedFileName != null)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                      )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: 383,
                height: 112,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 235, 235, 235),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                    controller: _problemController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Apa masalahmu?",
                    )),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 20),
            child: DefaultButton(
                text: "Lanjutkan",
                press: () {
                  _sendProblemToFirebase(_problemController.text);
                },
                bgcolor: KPrimaryColor,
                textColor: Colors.white,
                isLoading: isLoading),
          )
        ],
      ),
    );
  }
}
