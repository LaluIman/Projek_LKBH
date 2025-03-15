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
        children: List.generate(errors.length, (index) => errorText(text: errors[index]))
      ),
    );
    
  }
}

Row errorText({required String text}) {
    return Row(
        children: [
          SvgPicture.asset(
            'assets/icons/Error.svg',
            height: 12,
            width: 12,
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12
              ),
              maxLines: 2,
            ),
          )
        ],
      );
  }