import 'package:aplikasi_lkbh_unmul/Screen/Consultation/model.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/screen/consultation/consultation.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/screen/consultation/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class ConsultationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String adminId = "f1TnmpabMmVdMCjFK7GPCfxGrPz1";
  final Uuid _uuid = Uuid();

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String?> getUserName() async {
    try {
      if (currentUserId == null) return null;
      
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUserId).get();
      
      if (userDoc.exists) {
        return userDoc['nama'];
      } else {
        print('User tidak ditemukan di Firestore');
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<String> createConsultation(
      ConsultationType consultationType, String ktpImage) async {
    try {
      final docRef = await _firestore.collection('consultations').add({
        'userId': currentUserId,
        'consultationType': consultationType.name,
        'consultationTypeId': consultationType.id,
        'ktpImage': ktpImage,
        'problem': '',
        'createdAt': FieldValue.serverTimestamp(),
        'messages': [],
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create consultation: $e');
    }
  }

  Future<void> deleteConsultation(String consultationId) async {
    try {
      await _firestore.collection('consultations').doc(consultationId).delete();
      // print('Consultation deleted: $consultationId');
    } catch (e) {
      print('Failed to delete consultation: $e');
    }
  }

  Future<void> updateProblem(String consultationId, String problem) async {
    try {
      await _firestore.collection('consultations').doc(consultationId).update({
        'problem': problem,
      });

      await addDefaultMessages(consultationId, problem);
    } catch (e) {
      throw Exception('Failed to update problem: $e');
    }
  }

  Future<void> addDefaultMessages(
      String consultationId, String problem) async {
    try {
      final consultation = await _firestore
          .collection('consultations')
          .doc(consultationId)
          .get();
      
      final data = consultation.data();
      if (data == null) return;
      
      final consultationType = data['consultationType'];
      final ktpImage = data['ktpImage'];
      String? userName = await getUserName();
      final displayName = userName ?? _auth.currentUser?.displayName ?? 'User';
      final List<Message> defaultMessages = [
        // Introduction message
        Message(
          id: _uuid.v4(),
          senderId: currentUserId!,
          message: "Halo! nama saya $displayName ingin konsultasi tentang $consultationType",
          timestamp: DateTime.now(),
          isRead: false,
        ),
        // KTP Image attachment
        Message(
          id: _uuid.v4(),
          senderId: currentUserId!,
          message: "KTP.png",
          attachment: ktpImage,
          timestamp: DateTime.now().add(Duration(milliseconds: 100)),
          isRead: false,
        ),
        // Problem statement
        Message(
          id: _uuid.v4(),
          senderId: currentUserId!,
          message: problem,
          timestamp: DateTime.now().add(Duration(milliseconds: 200)),
          isRead: false,
        ),
        // Welcome message from admin
        Message(
          id: _uuid.v4(),
          senderId: adminId,
          message: "Selamat datang di LKBH! 👋\nTerima kasih telah menghubungi kami. Saya Admin, siap membantu Anda dalam konsultasi hukum. Kami akan segera merespons masalah anda",
          timestamp: DateTime.now().add(Duration(milliseconds: 300)),
          isRead: false,
        ),
      ];

      await _firestore.collection('consultations').doc(consultationId).update({
        'messages': FieldValue.arrayUnion(
            defaultMessages.map((message) => message.toMap()).toList()),
      });
    } catch (e) {
      throw Exception('Failed to add default messages: $e');
    }
  }

  // Send a message
  Future<void> sendMessage(String consultationId, String message,
      {String? attachment}) async {
    try {
      final newMessage = Message(
        id: _uuid.v4(),
        senderId: currentUserId!,
        message: message,
        attachment: attachment,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _firestore.collection('consultations').doc(consultationId).update({
        'messages': FieldValue.arrayUnion([newMessage.toMap()]),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(String consultationId, String messageId) async {
    try {
      // Get the current consultation
      DocumentSnapshot consultationDoc = await _firestore
          .collection('consultations')
          .doc(consultationId)
          .get();
      
      if (!consultationDoc.exists) {
        throw Exception('Consultation not found');
      }
      
      Map<String, dynamic> consultationData = consultationDoc.data() as Map<String, dynamic>;
      List<dynamic> messages = consultationData['messages'] ?? [];
      
      int messageIndex = messages.indexWhere((message) => 
        message['id'] == messageId && message['senderId'] == currentUserId);
      
      if (messageIndex == -1) {
        throw Exception('Message not found or not authorized to delete');
      }
      
      messages.removeAt(messageIndex);
      
      await _firestore.collection('consultations').doc(consultationId).update({
        'messages': messages,
      });
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  Stream<List<Consultation>> getUserConsultations() {
    return _firestore
        .collection('consultations')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs;
          docs.sort((a, b) {
            final aData = a.data();
            final bData = b.data();
            
            final aTimestamp = aData['createdAt'] as Timestamp?;
            final bTimestamp = bData['createdAt'] as Timestamp?;
            
            if (aTimestamp == null && bTimestamp == null) return 0;
            if (aTimestamp == null) return 1;
            if (bTimestamp == null) return -1;
            
            return bTimestamp.compareTo(aTimestamp);
          });
          
          return docs
              .map((doc) => Consultation.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<Consultation?> getConsultationById(String consultationId) {
    return _firestore
        .collection('consultations')
        .doc(consultationId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Consultation.fromMap(snapshot.data()!, snapshot.id);
      } else {
        return null;
      }
    });
  }
}