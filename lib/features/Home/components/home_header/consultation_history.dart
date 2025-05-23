import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/model.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/layanan/layanan_konsultasi/chat_screen.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/layanan/layanan_konsultasi/services/consultation.dart';
import 'package:aplikasi_lkbh_unmul/features/Consultation/layanan/layanan_konsultasi/services/consultation_service.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

class ConsultationHistoryScreen extends StatefulWidget {
  static String routeName = "/consultation_history";

  const ConsultationHistoryScreen({super.key});

  @override
  State<ConsultationHistoryScreen> createState() =>
      _ConsultationHistoryScreenState();
}

class _ConsultationHistoryScreenState extends State<ConsultationHistoryScreen> {
  final ConsultationService _consultationService = ConsultationService();
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
    setState(() {
      _isLocaleInitialized = true;
    });
  }

  String _formatTimestamp(DateTime dateTime) {
    if (!_isLocaleInitialized) {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }

    final now = DateTime.now();

    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return 'Hari ini, ${DateFormat('HH:mm').format(dateTime)}';
    }

    final yesterday = now.subtract(Duration(days: 1));
    if (dateTime.day == yesterday.day &&
        dateTime.month == yesterday.month &&
        dateTime.year == yesterday.year) {
      return 'Kemarin, ${DateFormat('HH:mm').format(dateTime)}';
    }

    if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEEE, HH:mm', 'id_ID').format(dateTime);
    }

    return DateFormat('dd MMM, HH:mm', 'id_ID').format(dateTime);
  }

  Stream<List<CompletedConsultation>> _getCompletedConsultations() {
    final userId = _consultationService.currentUserId;
    return FirebaseFirestore.instance
        .collection('konsultasi_selesai')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CompletedConsultation(
          id: doc.id,
          problem: data['problem'] ?? '',
          consultationType: data['layanan'] ?? '',
          conclusion: data['kesimpulan'] ?? '',
          startDate: data['startDate']?.toDate() ?? DateTime.now(),
          endDate: data['endDate']?.toDate() ?? DateTime.now(),
          userName: data['userName'] ?? '',
        );
      }).toList();
    });
  }

  Widget _buildConsultationItem({
    required String title,
    required String previewText,
    required String date,
    required String consultationType,
    required VoidCallback onTap,
    String? iconPath,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(5)),
                child: iconPath != null
                    ? SvgPicture.asset(
                        iconPath,
                        height: 30,
                        width: 30,
                      )
                    : Icon(Icons.help_outline, color: Colors.red, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Spacer(),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      previewText,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getIconForConsultationType(String name) {
    final match = ConsultationType.listConsultationType.firstWhere(
      (type) => type.name.toLowerCase() == name.toLowerCase(),
      orElse: () => ConsultationType(id: '', name: '', icon: ''),
    );
    return match.icon.isNotEmpty ? match.icon : null;
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
              'Riwayat konsultasi',
              style: TextTheme.of(context).titleMedium?.copyWith(
                fontWeight: FontWeight.w600
              ),
            ),
          ]),
      body: StreamBuilder<List<Consultation>>(
        stream: _consultationService.getUserConsultations(),
        builder: (context, activeSnapshot) {
          return StreamBuilder<List<CompletedConsultation>>(
            stream: _getCompletedConsultations(),
            builder: (context, completedSnapshot) {
              if (activeSnapshot.connectionState == ConnectionState.waiting ||
                  completedSnapshot.connectionState ==
                      ConnectionState.waiting) {
                return _buildShimmerLoading();
              }

              if (activeSnapshot.hasError) {
                return Center(
                  child: Text('Error: ${activeSnapshot.error}'),
                );
              }

              if (completedSnapshot.hasError) {
                return Center(
                  child: Text('Error: ${completedSnapshot.error}'),
                );
              }

              final activeConsultations = activeSnapshot.data ?? [];
              final completedConsultations = completedSnapshot.data ?? [];

              final filteredActiveConsultations = activeConsultations
                  .where((consultation) =>
                      consultation.messages.isNotEmpty &&
                      consultation.problem.isNotEmpty)
                  .toList();

              if (filteredActiveConsultations.isEmpty &&
                  completedConsultations.isEmpty) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (image1 != null) image1!,
                    Text(
                      'Belum ada konsultasi',
                      style: TextTheme.of(context).titleMedium,
                    ),
                  ],
                ));
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (filteredActiveConsultations.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.cell_tower,
                                  color: KPrimaryColor,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Konsultasi yang sedang berlangsung',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Divider()
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: filteredActiveConsultations.length,
                        itemBuilder: (context, index) {
                          final consultation =
                              filteredActiveConsultations[index];
                          final String formattedDate =
                              _formatTimestamp(consultation.createdAt);

                          String previewText = 'Lorem ipsum dolor sit amet';
                          if (consultation.messages.isNotEmpty) {
                            final lastUserMessage = consultation.messages
                                .where((message) =>
                                    message.senderId ==
                                    _consultationService.currentUserId)
                                .lastOrNull;
                            if (lastUserMessage != null) {
                              previewText = lastUserMessage.message;
                              if (previewText.length > 30) {
                                previewText =
                                    '${previewText.substring(0, 30)}...';
                              }
                            }
                          }

                          final iconPath = _getIconForConsultationType(
                              consultation.consultationType);

                          return _buildConsultationItem(
                            title: consultation.consultationType,
                            previewText: previewText,
                            date: formattedDate,
                            consultationType: consultation.consultationType,
                            iconPath: iconPath,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    consultationId: consultation.id,
                                    consultationType:
                                        consultation.consultationType,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                    if (completedConsultations.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.done_all,
                                  color: KPrimaryColor,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Konsultasi yang selesai',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Divider()
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: completedConsultations.length,
                        itemBuilder: (context, index) {
                          final completedConsultation =
                              completedConsultations[index];
                          final String formattedDate =
                              _formatTimestamp(completedConsultation.endDate);

                          String previewText = completedConsultation.problem;
                          if (previewText.length > 30) {
                            previewText = '${previewText.substring(0, 30)}...';
                          }

                          final iconPath = _getIconForConsultationType(
                              completedConsultation.consultationType);

                          return _buildConsultationItem(
                            title: completedConsultation.consultationType,
                            previewText: previewText,
                            date: formattedDate,
                            consultationType:
                                completedConsultation.consultationType,
                            iconPath: iconPath,
                            onTap: () {
                              _showCompletedConsultationDetails(
                                  context, completedConsultation);
                            },
                          );
                        },
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCompletedConsultationDetails(
      BuildContext context, CompletedConsultation consultation) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    consultation.consultationType,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              _buildInfoRow(
                  'Mulai:',
                  DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
                      .format(consultation.startDate)),
              _buildInfoRow(
                  'Selesai:',
                  DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
                      .format(consultation.endDate)),
              SizedBox(height: 15),
              Text(
                'Masalah:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              SingleChildScrollView(
                child: Text(
                  consultation.problem,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Kesimpulan:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                consultation.conclusion,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 120,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildShimmerItem();
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) {
              return _buildShimmerItem();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompletedConsultation {
  final String id;
  final String problem;
  final String consultationType;
  final String conclusion;
  final DateTime startDate;
  final DateTime endDate;
  final String userName;

  CompletedConsultation({
    required this.id,
    required this.problem,
    required this.consultationType,
    required this.conclusion,
    required this.startDate,
    required this.endDate,
    required this.userName,
  });
}
