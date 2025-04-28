import 'package:another_flushbar/flushbar.dart';
import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/Components/flushbar_notif.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/model.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/screen/chat_screen.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class UploadKtpScreen extends StatefulWidget {
  static String routeName = "/uploadKtpScreen";
  const UploadKtpScreen({super.key});
  

  @override
  State<UploadKtpScreen> createState() => _UploadKtpScreenState();
}
  
class _UploadKtpScreenState extends State<UploadKtpScreen> {
  
  XFile? _selectedImage;
  String? _base64Image;
  bool _isKtpUploaded = false;
  String? problemUser;
  String? selectedFileName;
  String displayNameFile(String name){
    if(name.length > 20){
      return name.substring(0, 17) + "...";
    }
    return name;
  }
  bool isLoading = false;
  bool hasUploadKtp = false;
  TextEditingController _problemController = TextEditingController();

  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('chat_konsultasi');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _checkKtpUploaded() async{
    final String currentUserId = _auth.currentUser!.uid;
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('chat_konsultasi')
    .doc(currentUserId)
    .collection('ktp_user')
    .get();

    if(snapshot.docs.isNotEmpty){
      setState(() {
        hasUploadKtp = true;
        _isKtpUploaded = true;
      });
    }
    if(context.mounted){
       Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(receiverID: "f1TnmpabMmVdMCjFK7GPCfxGrPz1")));
    }

  }

  Future<void> _pickImageFromGalery() async{
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 60
    );
    final String currentUserId = _auth.currentUser!.uid;
    
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    setState(() {
      selectedFileName = pickedFile.name;
      _base64Image = base64Image;
    });

  }
  
  Future<void> _sendProblemToFirebase(String? problemUser) async {
    final String currentUserId = _auth.currentUser!.uid;

    if(_base64Image == null){
      return;
    }else if(_problemController.text.isEmpty){
      return;
    }else{
      setState(() {
        isLoading = true;
      });
    }
   
   BuildContext? dialogContext;
    showModalBottomSheet(
        context: context, 
        isDismissible: false,
        enableDrag: false,
        builder: (ctx){
          dialogContext = ctx;
           return Center(
            child: LoadingAnimationWidget.inkDrop(color: KPrimaryColor,size:70)
        );
      }
    );


    try{
    await FirebaseFirestore.instance
        .collection('chat_konsultasi')
        .doc(currentUserId)
        .collection('ktp_user')
        .add({
      'ktp': _base64Image,
      'uploadAt': FieldValue.serverTimestamp(),
    });
    
    await FirebaseFirestore.instance
    .collection('chat_konsultasi')
    .doc(currentUserId)
    .collection('problem_user')
    .add({
      'problem_user': problemUser,
      'uploadAt': FieldValue.serverTimestamp(),
    });
    if(dialogContext != null){
      Navigator.pop(dialogContext!);
    }
    FlushbarNotif.show(
      context,
      "Berhasil terkirim!",
      "assets/icons/Success Icon.svg",
      KSuccess
      );
      await Future.delayed(Duration(seconds: 5));
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(receiverID: "f1TnmpabMmVdMCjFK7GPCfxGrPz1")));
      setState(() {
        isLoading = true;
      });
    }catch(e){
      if(dialogContext != null){
      Navigator.pop(dialogContext!);
    }
      FlushbarNotif.show(
          context, 
          "Ups...gagal, coba kirim lagi!", 
          'assets/images/error.svg', 
          KPrimaryColor
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkKtpUploaded();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             SizedBox(height: 20,),
                  Text("Kamu memilih konsultasi", style: TextStyle(
                    fontSize: 24,
                    color: KPrimaryColor,
                    fontWeight: FontWeight.w700
                  ),),
                  SizedBox(height: 13,),
                  Text("Sebelum kamu bisa lanjut ke tahap\nkonsultasi kamu upload KTP dulu ya!", textAlign: TextAlign.center,),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SvgPicture.asset('assets/images/kartu.svg', height: 180, width: 199,),
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: 383,
                      height: 139,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: 
                      GestureDetector(
                        onTap: () {
                          _pickImageFromGalery();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 10,),
                            SvgPicture.asset('assets/images/add_ktp_image.svg', height: 80, width: 80,),
                            if(selectedFileName == null)
                             Text(
                             "format png, jpg, jpeg" ,style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color.fromARGB(255, 141, 141, 141),
                             ),
                            ),
                            if(selectedFileName != null)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "KTP berhasil diupload!", style: TextStyle(
                                     fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: KSuccess
                                  ),
                                ),
                                Text(
                                  "Upload ulang?", style: TextStyle(
                                     fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color.fromARGB(0, 9, 140, 240)
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: 383,
                height: 112,
                decoration: BoxDecoration(
                   color: Colors.grey.shade200,
                   borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                     SvgPicture.asset("assets/icons/bi_megaphone-fill.svg"),
                     SizedBox(width: 7,),
                     Expanded(
                      child: TextField(
                        controller: _problemController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Apa masalahmu?",
                        )
                      )
                    )
                  ],
                ),
              )
            ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 20),
                    child: hasUploadKtp 
                    ? SizedBox.shrink()
                    : DefaultButton(text: "Lanjutkan", 
                      press: (){
                       _sendProblemToFirebase(_problemController.text);
                      }, 
                  bgcolor: KPrimaryColor, textColor: Colors.white
              ),
          )
        ],
      ),
    );
  }
}