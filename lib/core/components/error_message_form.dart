import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ErrorMessageForm extends StatelessWidget {
  const ErrorMessageForm({super.key, required this.errors});

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: List.generate(errors.length, (index) => errorText(text: errors[index], context: context))
      ),
    );
    
  }
}

Row errorText({required String text, required BuildContext context}) {
    return Row(
        children: [
          SvgPicture.asset(
            'assets/icons/error.svg',
            height: 12,
            width: 12,
            color: KError,
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              text,
              style: TextTheme.of(context).bodySmall?.copyWith(
                color: KError
              ),
              maxLines: 2,
            ),
          )
        ],
      );
  }