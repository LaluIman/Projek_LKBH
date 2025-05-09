import 'package:aplikasi_lkbh_unmul/Components/default_back_button.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/model.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/screen/consultation/chat_screen.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/screen/consultation/consultation.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/screen/consultation/consultation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class ConsultationHistoryScreen extends StatelessWidget {
  static String routeName = "/consultation_history";
  final ConsultationService _consultationService = ConsultationService();

  ConsultationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leadingWidth: 150,
          leading: DefaultBackButton(),
          actionsPadding: EdgeInsets.only(right: 10),
          actions: [
            Text(
              'Riwayat konsultasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
      body: StreamBuilder<List<Consultation>>(
        stream: _consultationService.getUserConsultations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final consultations = snapshot.data ?? [];
          if (consultations.isEmpty) {
            return Center(
              child: Text('Belum ada riwayat konsultasi'),
            );
          }

          final activeConsultations = consultations
              .where((consultation) =>
                  consultation.messages.isNotEmpty &&
                  consultation.problem.isNotEmpty)
              .toList();

          if (activeConsultations.isEmpty) {
            return Center(
              child: Text('Belum ada konsultasi yang berlangsung'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: activeConsultations.length,
                  itemBuilder: (context, index) {
                    final consultation = activeConsultations[index];
                    final String formattedDate = DateFormat('HH:mm')
                        .format(consultation.createdAt)
                        .toString();

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
                          previewText = previewText.substring(0, 30) + '...';
                        }
                      }
                    }

                    String? getIconForConsultationType(String name) {
                      final match =
                          ConsultationType.listConsultationType.firstWhere(
                        (type) => type.name.toLowerCase() == name.toLowerCase(),
                        orElse: () =>
                            ConsultationType(id: '', name: '', icon: ''),
                      );
                      return match.icon.isNotEmpty ? match.icon : null;
                    }

                    final iconPath = getIconForConsultationType(
                        consultation.consultationType);

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              consultationId: consultation.id,
                              consultationType: consultation.consultationType,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                                        height:30,
                                        width: 30,
                                      )
                                    : Icon(Icons.help_outline,
                                        color: Colors.red, size: 20),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          consultation.consultationType,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          'Kemarin, $formattedDate',
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
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
