import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/Screen/terjadwalkan_screen.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';

class BantuanScreen extends StatefulWidget {
  static String routeName = "/bantuanScreen";
  const BantuanScreen({super.key});

  @override
  State<BantuanScreen> createState() => _BantuanScreenState();
}


class _BantuanScreenState extends State<BantuanScreen> {
  String? _days;
  String? _times;

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bantuan Hukum", style: TextStyle(
              fontSize: 24,
              color: KPrimaryColor,
              fontWeight: FontWeight.w700
             ),
            ),
            SizedBox(height: 7,),
            Text("Untuk melanjutkan ke layanan bantuan hukum, silahkan upload KTP dan SKTM (Surat Keterangan Tidak Mampu)"),
            SizedBox(height: 24,),
            GestureDetector(
              onTap: () {},
              child: Container(
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
            ),
            SizedBox(height: 16,),
            GestureDetector(
              onTap: () {},
              child: Container(
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
                      Text("Upload SKTM", style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                       ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16,),
            Text("Jadwalkan Janji Temu", style: TextStyle(
              fontSize: 24,
              color: KPrimaryColor,
              fontWeight: FontWeight.w700
             ),
            ),
            Text("Pilih hari dan waktu untuk janji temu bantuan hukum."),
            SizedBox(height: 20,),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      hintText: "Pilih Hari",
                    ),
                    items: ['Senin', 'Selasa','Rabu','Kamis', "Jum'at", 'Sabtu','Minggu'].map((day) => DropdownMenuItem(
                      value: day,
                    child: Text(day))).toList(), 
                    onChanged: (String? day){
                      setState(() {
                        _days = day;
                      });
                    }
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      hintText: "Pilih Jam",

                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      )
                    ),
                    items: ['09.00 - 11.00', '14.00 - 15.00'].map((time) => DropdownMenuItem(
                      value: time,
                    child: Text(time))).toList(), 
                    onChanged: (String? time){
                      setState(() {
                        _times = time;
                      });
                    }
                    ),
                  )
              ],
            ),
            SizedBox(height: 50,),
            DefaultButton(text: "Jadwalkan", press: (){
              Navigator.pushNamed(context, "/terjadwalkan");
            }, bgcolor: KPrimaryColor, textColor: Colors.white)
          ],
        ),
      ),
    );
  }
}