import 'package:aplikasi_lkbh_unmul/Screen/Consultation/compenents/button_consulta.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/model.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';



class ConsultationScreen extends StatefulWidget {
  static String routeName = "/consultation";
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
       body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  Text("Jenis Konsultasi",style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                   ),
                  ),
                  Text("Pilih jenis konsultasi sesuai kebutuhan kamu",style: TextStyle(
                    color: KGray,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                   ),
                  ),
                  SizedBox(height: 30),
                  GridView.builder(
                        shrinkWrap: true,
                        physics:BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 10,
                          // mainAxisSpacing: 10,
                        ), 
                        itemCount: ConsultationType.listConsultationType.length,
                        itemBuilder: (context, index){
                          final consultationType = ConsultationType.listConsultationType[index];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context, 
                                    builder: (BuildContext context){
                                      return SizedBox(
                                        height: 400,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(topLeft:Radius.circular(20), topRight: Radius.circular(20)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              ButtonConsultan()
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 66,
                                      height: 66,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    ),
                                    Positioned(
                                      top: 9,
                                      left: 8,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: SvgPicture.asset(
                                        allowDrawingOutsideViewBox: true,
                                        errorBuilder: (context,error,StackTrace){
                                          print("SVG Loading error: $error");
                                          return Icon(Icons.error);
                                        },
                                      consultationType.icon,
                                      width: 30,
                                      fit: BoxFit.contain,
                                      placeholderBuilder: (context) => Icon(Icons.image),
                                      ),
                                    ),
                                    ),
                                    
                                  ],
                                ),
                              ),
                              SizedBox(height: 5,),
                              Text(consultationType.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.w600
                                ),
                                 overflow: TextOverflow.ellipsis,
                                 maxLines: 2,
                              )
                            ],
                          );
                        }
                      )
                ],
              ),
            )
          ),
        )
      )
    );
  }
}

