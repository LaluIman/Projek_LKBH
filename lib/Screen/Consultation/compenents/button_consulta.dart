import 'package:aplikasi_lkbh_unmul/Screen/Consultation/model.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ButtonConsultan extends StatelessWidget {
  const ButtonConsultan({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(
          ButtonConsultantChoises.listButtonConsultantChoises.length, 
          (index) {
            final choice = ButtonConsultantChoises.listButtonConsultantChoises[index];
            return ButtonContainer(
            buttonName:choice.buttonName, 
            buttonIcon: choice.buttonIcon, 
            buttonDesc: choice.buttonDesc, 
            click: choice.click,
            );
          }),
        )
      );
  }
}

class ButtonContainer extends StatelessWidget {
  const ButtonContainer({
    super.key, 
    required this.buttonName, 
    required this.buttonIcon, 
    required this.buttonDesc, 
    required this.click,
  });

  final String buttonName;
  final String buttonIcon;
  final String buttonDesc;
  final Function(BuildContext) click;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        click(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 98,
        width: 380,
        decoration: BoxDecoration(
          color: KBg,
          borderRadius: BorderRadius.circular(16)
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(233, 233, 233, 1),
                  borderRadius: BorderRadius.circular(16)
                ),
                child: 
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset(buttonIcon, 
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(buttonName, style: TextStyle(
                      color: KPrimaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w900
                      ),
                    ),
                
                    Text(buttonDesc, style: TextStyle(
                       fontSize: 11,
                       fontWeight: FontWeight.w500
                      ),
                     
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

