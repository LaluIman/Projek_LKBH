import 'package:aplikasi_lkbh_unmul/core/components/custom_tooltip.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/model.dart';import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LayananButton extends StatelessWidget {
  final Function()? onStartConsultation;

  const LayananButton({
    super.key,
    this.onStartConsultation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pilih layanan", style: TextTheme.of(context).titleSmall?.copyWith(
                  fontWeight: FontWeight.w700
                ),),
                CustomTooltip(message: "Layanan Bantuan hukum dan lapor kasus hukum hanya bisa bagi pengguna berdomisili Kalimantan Timur.", child: Icon(Icons.info_outline, color: KPrimaryColor,))
              ],
            ),
            
            ...List.generate(
            LayananButtontChoises.listLayananButtontChoises.length, 
            (index) {
              final choice = LayananButtontChoises.listLayananButtontChoises[index];
              return ButtonContainer(
                buttonName: choice.buttonName, 
                buttonIcon: choice.buttonIcon, 
                buttonDesc: choice.buttonDesc, 
                click: choice.click,
                onStartConsultation: onStartConsultation,
              );
            }),
          ],
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
    this.onStartConsultation,
  });

  final String buttonName;
  final String buttonIcon;
  final String buttonDesc;
  final Function(BuildContext) click;
  final Function()? onStartConsultation;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (onStartConsultation != null) {
          onStartConsultation!();
        }
        
        Navigator.of(context).pop();
        
        click(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: KBg,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: 
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(buttonIcon),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(buttonName, style: TextTheme.of(context).titleMedium?.copyWith(
                        color: KPrimaryColor,
                        fontWeight: FontWeight.w700
                      )
                      ),
                      Text(buttonDesc, style: TextTheme.of(context).bodyMedium
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}