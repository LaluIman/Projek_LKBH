import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  final String id;
  final String senderID;
  final String receiverID;
  final String messages;
  final DateTime timestamp;
  bool? isRead;
  String? type;

  Message({
    required this.id,
    required this.senderID,
    required this.receiverID,
    required this.messages,
    required this.timestamp,
    this.isRead,
    this.type
  });
  Message.newMessage({
    required this.senderID,
    required this.receiverID,
    required this.messages,
    required this.timestamp,
    this.isRead = false,
  }) : id = ''; 

  factory Message.fromJson(Map<String, dynamic> json, String docId){
    return Message(
      id:docId,
      senderID: json['senderID'] as String, 
      receiverID: json['receiverID'] as String,
      messages: json['messages'] as String, 
      timestamp: json['timestamp'] != null 
      ? (json['timestamp'] as Timestamp).toDate()
      : DateTime.now(), 
      isRead: json['isRead'] ?? false
    );
  }
 
  Map<String, dynamic> toJson(){
    return{
      'senderID': senderID,
      'receiverID': receiverID,
      'messages': messages,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead
    };
  }
}