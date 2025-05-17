import 'dart:async';
import 'dart:convert';
import 'package:aplikasi_lkbh_unmul/core/components/custom_alertdialog.dart';
import 'package:aplikasi_lkbh_unmul/core/components/custom_snackbar.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/components/consultation_provider.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/layanan/layanan_konsultasi/services/consultation.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/layanan/layanan_konsultasi/services/consultation_service.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/layanan/layanan_konsultasi/services/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

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
  final DateFormat _timeFormat = DateFormat('HH:mm');

  // State variables
  bool _isProblemSubmitted = false;
  bool _isLoading = false;
  bool _shouldDeleteOnExit = true;
  bool _isInitialized = false;

  // Streams
  StreamSubscription? _consultationSubscription;
  late Stream<Consultation?> _consultationStream;

  // Cache for consultation type
  late String? _consultationTypeName;

  @override
  void initState() {
    super.initState();
    _initializeConsultationStream();
    _getCachedConsultationType();
  }

  void _initializeConsultationStream() {
    _consultationStream = _consultationService
        .getConsultationById(widget.consultationId)
        .asBroadcastStream(); // Cache the stream to prevent multiple subscriptions
  }

  void _getCachedConsultationType() {
    final consultationProvider =
        Provider.of<ConsultationProvider>(context, listen: false);
    _consultationTypeName = consultationProvider.selectedConsultation?.name;
  }

  Future<void> _initializeConsultation() async {
    if (_isInitialized) return;

    try {
      final consultation = await _consultationService
          .getConsultationById(widget.consultationId)
          .first;

      if (consultation != null && mounted) {
        setState(() {
          _isProblemSubmitted = consultation.problem.isNotEmpty;
          _shouldDeleteOnExit = !_isProblemSubmitted;
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing consultation: $e');
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    _messageController.clear();

    setState(() {
      _isLoading = true;
    });

    try {
      if (!_isProblemSubmitted) {
        await _consultationService.updateProblem(
            widget.consultationId, message);
        setState(() {
          _isProblemSubmitted = true;
          _shouldDeleteOnExit = false;
        });
      } else {
        await _consultationService.sendMessage(widget.consultationId, message);
      }
    } catch (e) {
      if (mounted) {
        DefaultCustomSnackbar.buildSnackbar(
            context, "Gagal mengirim: $e", KError);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showKTPImage(String base64Image) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: 400,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                Expanded(
                  child: Image.memory(
                    base64Decode(base64Image),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
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
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            'Hapus Pesan',
            style: TextStyle(
              color: KPrimaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus pesan ini?',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              child: Text('Batal', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              onPressed: () => _deleteMessage(messageId),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  color: KPrimaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Hapus pesan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    Navigator.of(context).pop();

    setState(() {
      _isLoading = true;
    });

    try {
      await _consultationService.deleteMessage(
          widget.consultationId, messageId);
    } catch (e) {
      print('Gagal menghapus pesan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessageMenu(BuildContext context, Offset position, message) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        MediaQuery.of(context).size.width - position.dx,
        MediaQuery.of(context).size.height - position.dy,
      ),
      color: KBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: [
        PopupMenuItem(
          value: 'salin',
          child: Row(
            children: [
              Icon(Icons.copy, size: 25),
              SizedBox(width: 15),
              Text(
                'Salin text',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'hapus',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 25, color: KError),
              SizedBox(width: 15),
              Text(
                'Hapus pesan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: KError,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleMenuAction(value, message);
      }
    });
  }

  void _handleMenuAction(String action, message) {
    switch (action) {
      case 'salin':
        Clipboard.setData(ClipboardData(text: message.message));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.grey.shade800,
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            duration: Duration(seconds: 2),
            content: Text(
              "Tulisan disalin di clipboard!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
        break;
      case 'hapus':
        _showDeleteConfirmation(message.id);
        break;
    }
  }

  Future<bool> _onWillPop() async {
    if (!_shouldDeleteOnExit) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAlertdialog(
        title: "Keluar?",
        content:
            "Anda belum mengirim masalah, Jika anda keluar konsultasi tidak akan dilanjutkan.",
        actions: [
          AlertDialogAction(
            child: TextButton(
              child: Text('Batal', style: TextStyle(color: Colors.black)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
          AlertDialogAction(
            child: TextButton(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  color: KPrimaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Keluar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          )
        ],
      ),
    );

    if (result == true) {
      await _consultationService.deleteConsultation(widget.consultationId);
    }

    return result ?? false;
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final isKTP = message.message == 'KTP.png' && message.attachment != null;

    return GestureDetector(
      onLongPressStart: isMe
          ? (details) =>
              _showMessageMenu(context, details.globalPosition, message)
          : null,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? KPrimaryColor : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: isMe ? Radius.circular(10) : Radius.circular(1),
            topRight: isMe ? Radius.circular(1) : Radius.circular(10),
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
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red.shade500,
                ),
                child: GestureDetector(
                  onTap: () => _showKTPImage(message.attachment!),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Foto KTP saya',
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.open_in_new,
                        size: 20,
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ],
                  ),
                ),
              )
            else
              Text(
                message.message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            SizedBox(height: 5),
            Text(
              _timeFormat.format(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isMe ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                  ? 'Silakan jelaskan masalah hukum Anda \n secara detail tentang masalah ${_consultationTypeName ?? "hukum"}'
                  : 'Konsultasi telah selesai!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.inkDrop(
            color: KPrimaryColor,
            size: 50,
          ),
          SizedBox(height: 10),
          Text('Memuat percakapan...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Error: $error',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _initializeConsultationStream();
              });
            },
            child: Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          if (await _onWillPop()) {
            Navigator.pushReplacementNamed(context, "/custom_navigation_bar");
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Column(
              children: [
                if (!_isProblemSubmitted) _buildInfoBanner(),
                Expanded(child: _buildChatContent()),
                _buildMessageInput(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      shape: Border(bottom: BorderSide(color: Colors.grey.shade400, width: 1)),
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.red),
        onPressed: () async {
          if (_shouldDeleteOnExit) {
            bool confirm = await _onWillPop();
            if (confirm) {
              Navigator.pushReplacementNamed(context, "/custom_navigation_bar");
            }
          } else {
            Navigator.pushReplacementNamed(context, "/custom_navigation_bar");
          }
        },
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/logo.png'),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tim LKBH Mulawarman',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Kami akan segera respon masalah kamu!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: KPrimaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Silakan ceritakan masalah hukum Anda secara detail pada kotak pesan di bawah, lalu tekan tombol kirim.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatContent() {
    return StreamBuilder<Consultation?>(
      stream: _consultationStream,
      builder: (context, snapshot) {
        if (!_isInitialized) {
          _initializeConsultation();
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !_isInitialized) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final consultation = snapshot.data;
        if (consultation == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/icons/Chat Icon.svg", width: 100, color: KPrimaryColor,),
                SizedBox(height: 16),
                Text(
                  'Konsultasi telah selesai!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        final messages = consultation.messages;
        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: messages.length,
          reverse: true,
          itemBuilder: (context, index) {
            final message = messages[messages.length - 1 - index];
            final isMe = message.senderId == _consultationService.currentUserId;

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: _buildMessageBubble(message, isMe),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: !_isProblemSubmitted ? 3 : 1,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: !_isProblemSubmitted
                      ? 'Ceritakan masalah hukum Anda secara detail...'
                      : 'Kirim pesan...',
                  hintStyle: TextStyle(fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
            ),
            SizedBox(width: 8.0),
            Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: KPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ),
          ],
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
