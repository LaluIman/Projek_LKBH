import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shimmer/shimmer.dart';

class NotificationScreen extends StatefulWidget {
  static String routeName = "/notificationScreen";

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  List<NotificationItem> _notifications = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLocaleInitialized = false;

  Image? image1;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    image1 = Image.asset(
      "assets/images/Notifikasi page.png",
      width: 200,
    );
  }

  @override
  void didChangeDependencies() {
    if (image1 != null) {
      precacheImage(image1!.image, context);
    }
    super.didChangeDependencies();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    if (mounted) {
      setState(() {
        _isLocaleInitialized = true;
      });
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final queryReports = _firestore
          .collection('laporan_kasus')
          .where('uid', isEqualTo: currentUser.uid);
      final reportsSnapshot = await queryReports.get();

      final queryAppointments = _firestore
          .collection('bantuan_hukum')
          .where('uid', isEqualTo: currentUser.uid);
      final appointmentsSnapshot = await queryAppointments.get();

      final queryCompletedConsultations = _firestore
          .collection('konsultasi_selesai')
          .where('userId', isEqualTo: currentUser.uid);
      final completedConsultationsSnapshot =
          await queryCompletedConsultations.get();

      final List<NotificationItem> allNotifications = [];

      for (var doc in reportsSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;

        final isCompleted =
            data['status'] == 'selesai' || data['kesimpulan'] != null;

        if (isCompleted) {
          allNotifications.add(
            NotificationItem(
              id: doc.id,
              title: 'Laporan kasus selesai',
              description:
                  'Laporan ${data['layanan'] ?? 'pencegahan'} telah diselesaikan',
              time: timestamp,
              type: NotificationType.reportCompleted,
              details: data['kesimpulan'] ?? data['isi_laporan'] ?? '',
              collectionName: 'laporan_kasus',
              service: data['layanan'],
            ),
          );
        } else {
          allNotifications.add(
            NotificationItem(
              id: doc.id,
              title: 'Kasus terlaporkan',
              description:
                  'Dilaporkan kasus ${data['layanan'] ?? 'pencegahan'}',
              time: timestamp,
              type: NotificationType.reportSubmitted,
              details: data['isi_laporan'] ?? '',
              collectionName: 'laporan_kasus',
              service: data['layanan'],
            ),
          );
        }
      }

      // Process appointments
      for (var doc in appointmentsSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        final day = data['hari'] as String?;
        final time = data['waktu'] as String?;

        // Check if appointment is completed
        final isCompleted =
            data['status'] == 'selesai' || data['kesimpulan'] != null;

        if (isCompleted) {
          allNotifications.add(
            NotificationItem(
              id: doc.id,
              title: 'Bantuan hukum selesai',
              description:
                  'Bantuan hukum ${data['layanan'] ?? ''} telah diselesaikan',
              time: timestamp,
              type: NotificationType.legalAssistanceCompleted,
              details: data['kesimpulan'] ?? data['hasil'] ?? '',
              collectionName: 'bantuan_hukum',
              service: data['layanan'],
            ),
          );
        } else {
          allNotifications.add(
            NotificationItem(
              id: doc.id,
              title: 'Menjadwalkan janji temu',
              description:
                  'Ingat janji temu pada hari ${day ?? 'senin'} jam ${time ?? '11'}!',
              time: timestamp,
              type: NotificationType.appointment,
              details: '${data['layanan'] ?? ''}',
              collectionName: 'bantuan_hukum',
              service: data['layanan'],
            ),
          );
        }
      }

      // Process completed consultations
      for (var doc in completedConsultationsSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        final consultationType = data['consultationType'] as String?;
        final conclusion = data['conclusion'] as String?;

        allNotifications.add(
          NotificationItem(
            id: doc.id,
            title: 'Konsultasi selesai',
            description:
                'Konsultasi ${consultationType ?? 'hukum'} telah selesai',
            time: timestamp,
            type: NotificationType.consultationCompleted,
            details: conclusion ?? '',
            collectionName: 'konsultasi_selesai',
            service: consultationType,
          ),
        );
      }

      // Sort notifications by time (newest first)
      allNotifications.sort((a, b) => (b.time?.millisecondsSinceEpoch ?? 0)
          .compareTo(a.time?.millisecondsSinceEpoch ?? 0));

      if (mounted) {
        setState(() {
          _notifications = allNotifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leadingWidth: 150,
          leading: DefaultBackButton(),
          actionsPadding: EdgeInsets.only(right: 20),
          actions: [
            Text(
              'Notifikasi',
              style: TextTheme.of(context)
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ]),
      body: _isLoading
          ? _buildShimmerLoading()
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (image1 != null) image1!,
                    Text(
                      'Tidak ada notifikasi',
                      style: TextTheme.of(context).titleMedium,
                    ),
                  ],
                ))
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return _buildNotificationTile(notification);
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade200,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem notification) {
    final timeString =
        notification.time != null ? _formatTimestamp(notification.time!) : '';

    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    switch (notification.type) {
      case NotificationType.reportCompleted:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.1);
        break;
      case NotificationType.consultationCompleted:
        iconData = Icons.task_alt;
        iconColor = Colors.blue;
        backgroundColor = Colors.blue.withOpacity(0.1);
        break;
      case NotificationType.legalAssistanceCompleted:
        iconData = Icons.verified;
        iconColor = Colors.purple;
        backgroundColor = Colors.purple.withOpacity(0.1);
        break;
      case NotificationType.appointment:
        iconData = Icons.people;
        iconColor = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.1);
        break;
      case NotificationType.reportSubmitted:
        iconData = Icons.campaign;
        iconColor = Colors.red;
        backgroundColor = Colors.red.withOpacity(0.1);
        break;
    }

    return GestureDetector(
        onTap: () => _showNotificationDetails(notification),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: 30,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextTheme.of(context)
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        notification.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                      ),
                      if (notification.service != null) ...[
                        SizedBox(height: 4),
                        Text(
                          'Layanan: ${notification.service}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade800,
                                    height: 1.3,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _showNotificationDetails(NotificationItem notification) {
    final timeString =
        notification.time != null ? _formatTimestamp(notification.time!) : '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(height: 30),
              Text(
                'Pesan:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                notification.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              if (notification.service != null) ...[
                Text(
                  'Layanan:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  notification.service!,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
              ],
              if (notification.details.isNotEmpty) ...[
                Text(
                  _getDetailsLabel(notification.type),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      notification.details,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getDetailsLabel(NotificationType type) {
    switch (type) {
      case NotificationType.reportCompleted:
        return 'Kesimpulan:';
      case NotificationType.consultationCompleted:
        return 'Hasil Konsultasi:';
      case NotificationType.legalAssistanceCompleted:
        return 'Hasil Bantuan Hukum:';
      case NotificationType.appointment:
        return 'Jenis Konsultasi:';
      case NotificationType.reportSubmitted:
        return 'Isi Laporan:';
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    if (!_isLocaleInitialized) {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
    }

    final date = timestamp.toDate();
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return DateFormat('HH:mm').format(date);
    }
    final yesterday = now.subtract(Duration(days: 1));
    if (date.day == yesterday.day &&
        date.month == yesterday.month &&
        date.year == yesterday.year) {
      return 'Kemarin, ${DateFormat('HH:mm').format(date)}';
    }
    if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE, HH:mm', 'id_ID').format(date);
    }
    return DateFormat('dd MMM, HH:mm', 'id_ID').format(date);
  }
}

enum NotificationType {
  reportSubmitted,
  reportCompleted,
  appointment,
  consultationCompleted,
  legalAssistanceCompleted,
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final Timestamp? time;
  final NotificationType type;
  final String details;
  final String collectionName;
  final String? service;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    this.time,
    required this.type,
    this.details = '',
    required this.collectionName,
    this.service,
  });
}
