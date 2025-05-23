import 'package:flutter/material.dart';
import 'package:flutter_easy_faq/flutter_easy_faq.dart';

class CardFAQ extends StatelessWidget {
  const CardFAQ({
    super.key,
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EasyFaq(
            questionTextStyle:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            anserTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            borderRadius: BorderRadius.circular(5),
            backgroundColor: Colors.white,
            question: question,
            answer: answer),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
