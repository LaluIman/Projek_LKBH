import 'package:aplikasi_lkbh_unmul/features/Consultation/layanan/layanan_konsultasi/services/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Consultation {
  final String id;
  final String userId;
  final String consultationType;
  final String ktpImage;
  final String problem;
  final DateTime createdAt;
  final List<Message> messages;

  Consultation({
    required this.id,
    required this.userId,
    required this.consultationType,
    required this.ktpImage,
    required this.problem,
    required this.createdAt,
    required this.messages,
  });

  factory Consultation.fromMap(Map<String, dynamic> map, String docId) {
    return Consultation(
      id: docId,
      userId: map['userId'] ?? '',
      consultationType: map['consultationType'] ?? '',
      ktpImage: map['ktpImage'] ?? '',
      problem: map['problem'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      messages: (map['messages'] as List<dynamic>?)
              ?.map((message) => Message.fromMap(message))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'consultationType': consultationType,
      'ktpImage': ktpImage,
      'problem': problem,
      'createdAt': Timestamp.fromDate(createdAt),
      'messages': messages.map((message) => message.toMap()).toList(),
    };
  }
}