import 'dart:async';
import 'dart:convert';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/screen/consultation/consultation.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/screen/consultation/consultation_service.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatScreen extends StatefulWidget {
  final String consultationId;
  final String consultationType;

  const ChatScreen({
    super.key,
    required this.consultationId,
    required this.consultationType,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ConsultationService _consultationService = ConsultationService();
  bool _isProblemSubmitted = false;
  bool _isLoading = false;
  StreamSubscription? _consultationSubscription;
  bool _shouldDeleteOnExit = true; // Flag to control deletion on exit

  @override
  void initState() {
    super.initState();
    _checkProblemStatus();
  }

  void _checkProblemStatus() {
    _consultationSubscription = _consultationService
        .getConsultationById(widget.consultationId)
        .listen((consultation) {
      if (consultation != null && mounted) {
        setState(() {
          _isProblemSubmitted = consultation.problem.isNotEmpty;
          // If problem is submitted, we shouldn't delete on exit
          if (_isProblemSubmitted) {
            _shouldDeleteOnExit = false;
          }
        });
      }
    });
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      if (!_isProblemSubmitted) {
        await _consultationService.updateProblem(
            widget.consultationId, message);
        if (!mounted) return;
        setState(() {
          _isProblemSubmitted = true;
          _shouldDeleteOnExit = false; // Problem submitted, don't delete on exit
        });
      } else {
        await _consultationService.sendMessage(widget.consultationId, message);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showKTPImage(String base64Image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: MemoryImage(base64Decode(base64Image)),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Pesan'),
          content: Text('Apakah Anda yakin ingin menghapus pesan ini?'),
          actions: [
            TextButton(
              child: Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }

                try {
                  await _consultationService.deleteMessage(
                      widget.consultationId, messageId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pesan berhasil dihapus')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus pesan: $e')),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Show confirmation dialog before exiting if problem not submitted
  Future<bool> _onWillPop() async {
    if (!_shouldDeleteOnExit) {
      return true; // Allow exit without confirmation if problem submitted
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Keluar dari konsultasi?'),
        content: Text(
            'Anda belum mengirimkan masalah. Jika keluar sekarang, konsultasi ini akan dihapus.'),
        actions: [
          TextButton(
            child: Text('Batal', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Keluar', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (result == true) {
      // User confirmed exit, delete the consultation
      await _consultationService.deleteConsultation(widget.consultationId);
    }

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leadingWidth: double.infinity,
          leading: Row(
            children: [
              IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.red),
                  onPressed: () async {
                    if (_shouldDeleteOnExit) {
                      bool confirm = await _onWillPop();
                      if (confirm) {
                        Navigator.pushReplacementNamed(
                            context, "/custom_navigation_bar");
                      }
                    } else {
                      Navigator.pushReplacementNamed(
                          context, "/custom_navigation_bar");
                    }
                  }),
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tim LKBH Mulawarman',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Kami akan segera respon masalah kamu!',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            if (!_isProblemSubmitted)
              Container(
                margin: EdgeInsets.all(10),
                width: double.infinity,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: KPrimaryColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Silakan ceritakan masalah hukum Anda secara detail pada kotak pesan di bawah, lalu tekan tombol kirim.',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: StreamBuilder<Consultation?>(
                stream: _consultationService
                    .getConsultationById(widget.consultationId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading chat: ${snapshot.error}'),
                    );
                  }

                  final consultation = snapshot.data;
                  if (consultation == null) {
                    return Center(child: Text('Consultation not found'));
                  }

                  final messages = consultation.messages;
                  if (messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/Berikan masalah.png",
                              fit: BoxFit.cover,
                              width: 300,
                            ),
                            SizedBox(height: 20),
                            Text(
                              !_isProblemSubmitted
                                  ? 'Silakan jelaskan masalah hukum \n Anda secara detail'
                                  : 'Belum ada pesan, mulailah konsultasi',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final isMe =
                          message.senderId == _consultationService.currentUserId;
                      final isKTP = message.message == 'KTP.png' &&
                          message.attachment != null;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: GestureDetector(
                          onLongPress: isMe
                              ? () => _showDeleteConfirmation(message.id)
                              : null,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? KPrimaryColor : Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: isMe
                                    ? Radius.circular(10)
                                    : Radius.circular(1),
                                topRight: isMe
                                    ? Radius.circular(1)
                                    : Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isKTP)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.red.shade500),
                                    child: GestureDetector(
                                      onTap: () =>
                                          _showKTPImage(message.attachment!),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Foto KTP saya',
                                            style: TextStyle(
                                                color: isMe
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Icon(Icons.open_in_new,
                                              size: 20,
                                              color: isMe
                                                  ? Colors.white
                                                  : Colors.black),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    message.message,
                                    style: TextStyle(
                                        color: isMe ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('HH:mm')
                                          .format(message.timestamp)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isMe
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                    if (isMe) ...[
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.done_all,
                                        size: 12,
                                        color: message.isRead
                                            ? Colors.white
                                            : Colors.white70,
                                      )
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: !_isProblemSubmitted ? 3 : 1,
                        decoration: InputDecoration(
                          hintText: !_isProblemSubmitted
                              ? 'Ceritakan masalah hukum Anda secara detail...'
                              : 'Kirim pesan...',
                          hintStyle: TextStyle(fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          suffixIcon: !_isProblemSubmitted
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                      'assets/icons/attacment.svg'),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                          color: KPrimaryColor, shape: BoxShape.circle),
                      child: _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: LoadingAnimationWidget.inkDrop(
                                  color: Colors.white, size: 30),
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _sendMessage,
                            ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_shouldDeleteOnExit) {
      _consultationService.deleteConsultation(widget.consultationId);
    }
    
    _consultationSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }
}