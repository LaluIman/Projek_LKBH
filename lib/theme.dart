import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';

themeData(){
  return ThemeData(
    fontFamily: 'PlusJakartaSans',
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: KBg,
    //inputdecoration
    inputDecorationTheme: inputDecoration()
);
}

InputDecorationTheme inputDecoration(){
   var outlineInputBorder = const OutlineInputBorder(
          borderSide: BorderSide(width: 0, color: Colors.transparent),
          borderRadius: BorderRadius.all(Radius.circular(16)),
          gapPadding: 5
        );
    return InputDecorationTheme(
        fillColor: Color.fromARGB(255, 236, 236, 236),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 17
        ),
        labelStyle: TextStyle(
          color: Color(0xff909090),
          fontWeight: FontWeight.w600
        ),
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500
        ),
        hintFadeDuration: Durations.medium3,
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        border: outlineInputBorder,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 2
          ),
          borderRadius: BorderRadius.all(Radius.circular(16)),
          gapPadding: 5
        ),
      );
}


// Contoh TextFormField 
//  TextFormField(
//     decoration: InputDecoration(
//     labelText: "Masukan Gmail kamu",
//     hintText: "akun@gmail.com",
//     prefixIcon: Padding(
//     padding: const EdgeInsets.all(10),
//     child: SvgPicture.asset('assets/icons/Account Icon.svg',color: Colors.black,),
//  ))),