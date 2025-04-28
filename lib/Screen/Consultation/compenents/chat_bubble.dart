import 'dart:convert';
import 'dart:typed_data';

import 'package:aplikasi_lkbh_unmul/Screen/Consultation/service/message.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  final Message message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    if(message.type == 'ktp'){
      Uint8List imageBytes = base64Decode(message.messages);
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 180,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(imageBytes, fit: BoxFit.cover),
          ),
        ),
      );
    }
      return Container(
      margin: isCurrentUser
          ? EdgeInsets.only(left: 70, right: 10, bottom: 10)
          : EdgeInsets.only(right: 70, left: 10, bottom: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.red.shade600 : Colors.grey.shade300,
        borderRadius: BorderRadius.only(
          topLeft: isCurrentUser ? Radius.circular(16) : Radius.circular(1),
          topRight: isCurrentUser ? Radius.circular(1) : Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          message.messages,
          style: TextStyle(
            color: isCurrentUser ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
