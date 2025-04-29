import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String receiverID;
  final String messages;
  final DateTime timestamp;
  final String type;
  final String? id;
  final String? fileName;
  final String? thumbnail;
  final bool seen;

  Message({
    required this.senderID,
    required this.receiverID,
    required this.messages,
    required this.timestamp,
    this.type = 'text',
    this.id,
    this.fileName,
    this.thumbnail,
    this.seen = false,
  });

  // Factory method for creating a new message
  factory Message.newMessage({
    required String senderID,
    required String receiverID,
    required String messages,
    required DateTime timestamp,
    String type = 'text',
    String? fileName,
    String? thumbnail,
  }) {
    return Message(
      senderID: senderID,
      receiverID: receiverID,
      messages: messages,
      timestamp: timestamp,
      type: type,
      fileName: fileName,
      thumbnail: thumbnail,
      seen: false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'senderID': senderID,
      'receiverID': receiverID,
      'messages': messages,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'fileName': fileName,
      'thumbnail': thumbnail,
      'seen': seen,
    };
  }

  // Create Message from JSON
  factory Message.fromJson(Map<String, dynamic> json, [String? documentId]) {
    Timestamp timestamp = json['timestamp'] as Timestamp;
    return Message(
      senderID: json['senderID'] ?? '',
      receiverID: json['receiverID'] ?? '',
      messages: json['messages'] ?? '',
      timestamp: timestamp.toDate(),
      type: json['type'] ?? 'text',
      id: documentId,
      fileName: json['fileName'],
      thumbnail: json['thumbnail'],
      seen: json['seen'] ?? false,
    );
  }
}