import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String message;
  final String? attachment;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.message,
    this.attachment,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      message: map['message'] ?? '',
      attachment: map['attachment'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'message': message,
      'attachment': attachment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}