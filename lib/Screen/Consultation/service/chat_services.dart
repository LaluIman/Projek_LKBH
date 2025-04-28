import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/service/message.dart';


class ChatServices {
  final FirebaseFirestore dataCollection = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String adminID = "f1TnmpabMmVdMCjFK7GPCfxGrPz1";

  // generate ID unique for converstaion
  String getConversation(String userId,String adminID){
    return userId.hashCode <= adminID.hashCode
    ? "${userId}_$adminID"
    : "${adminID}_$userId";
  }

  Future<void> sendMessageToAdmin(String messages, receiverID) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    final Message message = Message.newMessage(
      senderID: currentUserId,
      receiverID: adminID,
      messages: messages,
      timestamp: DateTime.now(), 

    );
    final String conversationID = getConversation(currentUserId, receiverID);

    await dataCollection
    .collection("chat_konsultasi")
    .doc(conversationID)
    .collection("messages")
    .add(message.toJson());
    //  print("Pesan terkirim ke $receiverID");
  }

  Stream<List<Message>> getChatStreamWithAdmin(String receiverID){
    final String currentUserId = _auth.currentUser!.uid;
    final String conversationID = getConversation(currentUserId, receiverID);

    return dataCollection
    .collection("chat_konsultasi")
    .doc(conversationID)
    .collection("messages")
    .orderBy("timestamp", descending: false)
    .snapshots()
    .map((snapshot) => snapshot.docs
    .map((doc) => Message.fromJson(doc.data(), doc.id))
    .toList());
  }

  Future<void> deleteMessage(String messageID, String receiverID) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String conversationID = getConversation(currentUserId, receiverID);
    
    try{
      await FirebaseFirestore.instance
      .collection("chat_konsultasi")
      .doc(conversationID)
      .collection("messages")
      .doc(messageID)
      .delete();
    }catch(e){
      print("Error deleting message: $e");
    }

  }
}
