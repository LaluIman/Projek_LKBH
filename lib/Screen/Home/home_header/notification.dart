import 'package:aplikasi_lkbh_unmul/Components/default_back_button.dart';
import 'package:aplikasi_lkbh_unmul/size_config.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import for locale initialization
import 'package:shimmer/shimmer.dart'; // Import shimmer package

class NotificationScreen extends StatefulWidget {
  static String routeName = "/notificationScreen";

  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  List<NotificationItem> _notifications = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      _isLocaleInitialized = true;
    });
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final reportsSnapshot = await _firestore
          .collection('laporan_kasus')
          .where('uid', isEqualTo: currentUser.uid)
          .get();
      final appointmentsSnapshot = await _firestore
          .collection('bantuan_hukum')
          .where('uid', isEqualTo: currentUser.uid)
          .get();

      final List<NotificationItem> allNotifications = [];

      for (var doc in reportsSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;

        allNotifications.add(
          NotificationItem(
            id: doc.id,
            title: 'Kasus terlaporkan',
            description: 'Dilaporkan kasus ${data['layanan'] ?? 'pencepatan'}',
            time: timestamp,
            isAppointment: false,
            details: data['isi_laporan'] ?? '',
            collectionName: 'laporan_kasus',
          ),
        );
      }

      for (var doc in appointmentsSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        final day = data['hari'] as String?;
        final time = data['waktu'] as String?;

        allNotifications.add(
          NotificationItem(
            id: doc.id,
            title: 'Menjadwalkan janji temu',
            description:
                'Ingat janji temu pada hari ${day ?? 'senin'} jam ${time ?? '11'}!',
            time: timestamp,
            isAppointment: true,
            details: '${data['layanan'] ?? ''}',
            collectionName: 'bantuan_hukum',
          ),
        );
      }

      allNotifications.sort((a, b) => (b.time?.millisecondsSinceEpoch ?? 0)
          .compareTo(a.time?.millisecondsSinceEpoch ?? 0));

      setState(() {
        _notifications = allNotifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Notifikasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          leadingWidth: 150,
          leading: DefaultBackButton()),
      body: _isLoading
          ? _buildShimmerLoading()
          : _notifications.isEmpty
              ? Center(child: Text('Tidak ada notifikasi'))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationTile(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: getPropScreenWidth(5), horizontal: getPropScreenHeight(10)),
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

    return GestureDetector(
        onTap: () => _showNotificationDetails(notification),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: getPropScreenWidth(5), horizontal: getPropScreenHeight(10)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      notification.isAppointment
                          ? Icons.people
                          : Icons.campaign,
                      color: Colors.red,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        notification.description,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
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
                  Container(
                    width:40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        notification.isAppointment
                            ? Icons.people
                            : Icons.campaign,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
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
                ],
              ),
              Divider(height: 30),
              Text(
                'Detail:',
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
              if (notification.details.isNotEmpty) ...[
                Text(
                  notification.isAppointment
                      ? 'Jenis Konsultasi:'
                      : 'Isi Laporan:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  notification.details,
                  style: TextStyle(fontSize: 16),
                ),
              ],
              Spacer(),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KPrimaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
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

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final Timestamp? time;
  final bool isAppointment;
  final String details;
  final String collectionName;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    this.time,
    required this.isAppointment,
    this.details = '',
    required this.collectionName,
  });
}
