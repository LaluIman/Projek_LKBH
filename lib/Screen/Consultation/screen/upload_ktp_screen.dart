import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class UploadKtpScreen extends StatefulWidget {
  static String routeName = "/uploadKtpScreen";
  const UploadKtpScreen({super.key});
  

  @override
  State<UploadKtpScreen> createState() => _UploadKtpScreenState();
}
  
class _UploadKtpScreenState extends State<UploadKtpScreen> {
  XFile? _selectedImage;

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
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: SvgPicture.asset('assets/icons/KTP Boi.svg'),
                  ),
                  // SizedBox(height: 40,),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 8),
                    child: DefaultButton(text: "Upload KTP", press: (){
                      _pickImageFromGalery();
                    }, bgcolor: KPrimaryColor, textColor: Colors.white),
          )
        ],
      ),
    );
  }

  Future<void> _pickImageFromGalery() async{
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = XFile(pickedFile!.path);
    });
  }
}