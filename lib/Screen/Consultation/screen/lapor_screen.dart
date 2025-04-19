import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LaporScreen extends StatefulWidget {
  static String routeName = "/laporScreen";
  const LaporScreen({super.key});

  @override
  State<LaporScreen> createState() => _LaporScreenState();
}

class _LaporScreenState extends State<LaporScreen> {

  TextEditingController _reporterController = TextEditingController();
  TextEditingController _numberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _reportedController = TextEditingController();
  TextEditingController _reportController = TextEditingController();

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
                  hintText: "Nama Lengkap Pelapor",
                  hintStyle: TextStyle(fontWeight: FontWeight.w500),
                  prefixIcon: Icon(Icons.person)
                )
              ),
              SizedBox(height: 7,),
              TextFormField(
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _numberController,
                decoration: InputDecoration(
                  hintText: "Nomor Telepon",
                  hintStyle: TextStyle(fontWeight: FontWeight.w500),
                  prefixIcon: Icon(Icons.phone)
                )
              ),
              SizedBox(height: 7,),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: "Alamat",
                  hintStyle: TextStyle(fontWeight: FontWeight.w500),
                  prefixIcon: Icon(Icons.location_on_rounded)
                )
              ),
              SizedBox(height: 7,),
              Container(
                width: 383,
                height: 108,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 235, 235, 235),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, color: Colors.black, size: 40,),
                      Text("Upload KTP", style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                       ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40,),
              TextFormField(
                controller: _reportedController,
                decoration: InputDecoration(
                  hintText: "Nama Lengkap Yang di lapor",
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
              DefaultButton(text: "Kirim Laporan", press: (){
                Navigator.pushNamed(context, "/terlaporkan");
              }, bgcolor: KPrimaryColor, textColor: Colors.white),
              SizedBox(height: 70,),

            ],
          ),
        ),
      ),
    );
  }
}