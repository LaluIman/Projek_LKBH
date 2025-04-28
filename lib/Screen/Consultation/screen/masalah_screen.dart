import 'package:aplikasi_lkbh_unmul/Components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/model.dart';



class MasalahScreen extends StatefulWidget {
  static String routeName = '/masalah';
  const MasalahScreen({super.key});

  @override
  State<MasalahScreen> createState() => _MasalahScreenState();
}

class _MasalahScreenState extends State<MasalahScreen> {
  TextEditingController _problemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Beritahu apa masalahmu\nterkait waris?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: KPrimaryColor,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 60,),
            SvgPicture.asset("assets/images/tell_your_problem_icon.svg"),
            SizedBox(height: 60,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: 383,
                height: 125,
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
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DefaultButton(text: "Kirim masalah !", press: (){}, bgcolor: KPrimaryColor, textColor: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}