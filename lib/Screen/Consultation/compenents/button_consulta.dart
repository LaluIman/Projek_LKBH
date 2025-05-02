import 'package:aplikasi_lkbh_unmul/Screen/Consultation/model.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';

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
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: KBg,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: 
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(buttonIcon, 
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(buttonName, style: TextStyle(
                      color: KPrimaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w700
                      ),
                    ),
                    Text(buttonDesc, style: TextStyle(
                       fontSize: 12.5,
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

