import 'dart:convert';
import 'dart:typed_data';

import 'package:aplikasi_lkbh_unmul/Screen/Consultation/compenents/chat_bubble.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/compenents/consultation_provider.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/service/chat_services.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/service/message.dart';
import 'package:aplikasi_lkbh_unmul/Screen/bottom_navbar.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  // static String routeName = "/chatScreen";
  final String receiverID;
  // final String? receiverEmail;

  ChatScreen({super.key, required this.receiverID});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String _userName = "";
  Uint8List? ktpUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? getCurrentUser(){
    return _auth.currentUser;
  }
  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('chat_konsultasi');
  final ChatServices _chatServices = ChatServices();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _getUserNameFromFirebase() async {
    final String currentUserId = _auth.currentUser!.uid;
    final DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
    .collection("users")
    .doc(currentUserId)
    .get();

    if(userDoc.exists){
      final String userName = userDoc.data()?['nama'] ?? 'Nama tidak tersedia';
      setState(() {
        _userName = userName;
      });
    }
  }

  Future<void> _getKtpUserFromFirebase() async {
    final String currentUserId = _auth.currentUser!.uid;

    final QuerySnapshot<Map<String, dynamic>> ktpUser = await FirebaseFirestore.instance
    .collection("chat_konsultasi")
    .doc(currentUserId)
    .collection("ktp_user")
    .get();

    if(ktpUser.docs.isNotEmpty){
      final Map<String, dynamic> data = ktpUser.docs.first.data();
      final String base64Image = data['ktp'] ?? 'Anda belum upload ktp';

     if(base64Image.isNotEmpty){
      Uint8List imagesBytes = base64Decode(base64Image);

      showModalBottomSheet(
        context: context, 
        builder: (BuildContext context){
          return SizedBox(
            height: 400,
            width: 400,
            child: Container(
              height: 400,
              width: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft:Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.memory(imagesBytes),
              )));
        }
      );
     } else {
        _showError("Anda belum upload KTP");
     } 
    } else {
      _showError("KTP tidak ditemukan");
    }
    
  }
  void _showError(String message){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
      );
    }

  void _sendMessage() async {
    if(_messageController.text.trim().isNotEmpty){
     await _chatServices.sendMessageToAdmin(_messageController.text.trim(), widget.receiverID );
      _messageController.clear();
    }
  }

  void _showPopDeleteMessage(String messageID) {
   showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Hapus pesan",style: TextStyle(fontWeight: FontWeight.w600),),
        content: const Text("Apa anda yakin ingin menghapus pesan ini?",style: TextStyle(fontSize: 15),),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text("Kembali",style: TextStyle(color: Colors.blue, fontSize: 20),)),
          TextButton(
            onPressed: () async{
              Navigator.of(context).pop();
              await _chatServices.deleteMessage(messageID, widget.receiverID);
              setState(() {});     
            },
            child: const Text("Hapus",style: TextStyle(color: Colors.red, fontSize: 20),
          ),
          )
        ],
      )
    );
  }

  Future<void> sendKtpMessageIfNeeded(String receiverID) async {
    String getConversation(String userId,String adminID){
    return userId.hashCode <= adminID.hashCode
    ? "${userId}_$adminID"
    : "${adminID}_$userId";
  }
    final String currentUserId = _auth.currentUser!.uid;
     final String conversationID = getConversation(currentUserId, receiverID);
    
    final CollectionReference messageCollection = FirebaseFirestore.instance
    .collection("chat_konsultasi")
    .doc(conversationID)
    .collection("intro");

    // is ktp already sent
    final QuerySnapshot snapshot = await messageCollection
    .where('type', isEqualTo: 'ktp')
    .where('senderID', isEqualTo: currentUserId)
    .get();

    if(snapshot.docs.isEmpty){
      // take username & ktp
          final selected = Provider.of<ConsultationProvider>(context, listen: false).selectedConsultation;

          final userDoc = await FirebaseFirestore.instance.collection("users").doc(currentUserId).get();
          final String userName = userDoc.data()?['nama'] ?? "Pengguna";

          final QuerySnapshot<Map<String, dynamic>> ktpUserSnapshot = await FirebaseFirestore.instance
          .collection("chat_konsultasi")
          .doc(currentUserId)
          .collection("ktp_user")
          .get();

          if(ktpUserSnapshot.docs.isNotEmpty){
            final Map<String, dynamic> data = ktpUserSnapshot.docs.first.data();
            final String base64Image = data['ktp'];

            // send intro chat
            await messageCollection.add({
              'senderID': currentUserId,
              'receiverID': widget.receiverID,
              'messages': 'Halo! saya $_userName ingin berkonsultasi ${selected!.name}',
              'timestamp': Timestamp.now(),
              'type': 'intro'
            });

            // send ktp user
            await messageCollection.add({
              'senderID': currentUserId,
              'receiverID': widget.receiverID,
              'messages': base64Image,
              'timestamp': Timestamp.now(),
              'type': 'ktp'
            });
          }else{
             _showError("KTP belum ditemukan, silakan upload terlebih dahulu");
          }
    }
  }
  FocusNode myFocusNode = FocusNode();
  // scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
    _scrollController.position.maxScrollExtent, 
    duration: const Duration(seconds: 1), 
    curve: Curves.fastOutSlowIn);
  }

  @override
  void initState() {
    // TODO: implement initState
    myFocusNode.addListener((){
      if(myFocusNode.hasFocus){
        Future.delayed(
           const Duration(milliseconds: 500),
           () => scrollDown()
        );
      }
    });
    super.initState();
    _getUserNameFromFirebase();
    WidgetsBinding.instance.addPostFrameCallback((_){
      sendKtpMessageIfNeeded(widget.receiverID);
    });
     Future.delayed(
        const Duration(milliseconds: 500),
        () => scrollDown(),
      );
  }
  
  @override
  void dispose(){
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Custom AppBar
            Container(
              decoration: BoxDecoration(
                // color: Colors.white60
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CustomBottomNavbar()),
                        );
                      },
                      icon: Icon(Icons.arrow_back_ios, color: KPrimaryColor),
                    ),
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/images/logo.png'),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tim LKBH Mulawarman",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Kami akan segera respon masalah kamu!",
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bubble Chat (Placeholder)
            SizedBox(height: 30,),
            Expanded(
              child: _buildMessageList(),
            ),
            SizedBox(height: 5,),
            // Send Message (Placeholder)
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  StreamBuilder<Object> _buildMessageList() {
    return StreamBuilder<List<Message>>(
              stream: _chatServices.getChatStreamWithAdmin(widget.receiverID),
              builder: (context, snapshot) {
                if(snapshot.hasError){
                   return Center(child: Text('Something went wrong: ${snapshot.error}'));

                }
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: LoadingAnimationWidget.inkDrop(color:KPrimaryColor, size: 70),);
                }
                final messages = snapshot.data ?? [];
                
                return ListView(
                  controller: _scrollController,
                  children: [
                    _buildKtpMessage(),
                    ...messages.map((msg) => _buildMessageItem(msg, msg.id ?? "")).toList()
                  ],
                );
              }
            );
  }

  Container _buildMessageItem(Message message, String messageID) { 

    bool isCurrentUser = message.senderID == _auth.currentUser!.uid;
    var aligment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: aligment,
    child: Column(
      children: [
        GestureDetector(
          onLongPress: (){
            if(isCurrentUser){
              _showPopDeleteMessage(messageID);
            }
          },
          child: ChatBubble(message: message, isCurrentUser: isCurrentUser,)),
      ],
    ),
  );
  }

  Container _buildKtpMessage() {
     final selected = Provider.of<ConsultationProvider>(context, listen: false).selectedConsultation;
    return Container(
                    
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                         margin: EdgeInsets.only(left: 70, right: 10, bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                             borderRadius: BorderRadius.only(
                             topLeft: Radius.circular(16),
                             topRight: Radius.circular(1),
                             bottomLeft: Radius.circular(16),
                             bottomRight: Radius.circular(16),
                            )
                           ),
                          child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Halo! saya $_userName ingin berkonsultasi ${selected!.name}',
                               style: TextStyle(
                                 color: Colors.white,
                                 fontSize: 16,
                                 fontWeight: FontWeight.w500
                            ),
                           ),
                         ),
                        ),
                        GestureDetector(
              onTap: () {
                _getKtpUserFromFirebase();
              },
              child: Container(
                margin: EdgeInsets.only( right: 10,bottom: 10),
                width: 140,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.only(
                     topLeft: Radius.circular(16),
                     topRight: Radius.circular(1),
                     bottomLeft: Radius.circular(16),
                     bottomRight: Radius.circular(16),
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      borderRadius: BorderRadius.circular(10)
                       ),
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                           children: [
                               Text(
                               'foto KTP',
                                  style: TextStyle(
                                     color: Colors.white,
                                     fontSize: 16,
                                     fontWeight: FontWeight.w500
                                  ),
                                ),
                                SizedBox(width: 5,),
                                SvgPicture.asset('assets/icons/link_out.svg')
                               ],
                               ),
                              ),
                            ),
                           ),
                          ),
                         ), 
                      ],
                    ),
                  );
  }

  Padding _buildMessageInput() {
    return Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: myFocusNode,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      suffixIcon: SvgPicture.asset('assets/icons/attacment.svg'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.black45
                        )
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.black45
                        )
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          width: 1,
                          color: Colors.black45
                        )
                      ),
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: KPrimaryColor,
                    shape: BoxShape.circle
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
  }
}
