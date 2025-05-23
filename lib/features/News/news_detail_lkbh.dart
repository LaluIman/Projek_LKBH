import 'dart:convert';
import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NewsDetailLkbh extends StatelessWidget {
  static String routeName = "/_NewsDetailLkbh";
  final Map<String, dynamic> news;
  final String docId;

  const NewsDetailLkbh({
    super.key, 
    required this.news,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    String judul = news['judul'] ?? 'No Title';
    String konten = news['konten'] ?? 'No Content';
    Timestamp timestamp = news['tanggal'] ?? Timestamp.now();
    String base64Img = news['gambar'] ?? '';
    
    String formattedDate = DateFormat('dd/MM/yyyy').format(timestamp.toDate());

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 150,
        backgroundColor: Colors.white,
        leading: DefaultBackButton()
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_alarm, size: 20,),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$judul.",
                        style: TextTheme.of(context).titleLarge,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 260,
                        child: SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: base64Img.isNotEmpty
                                ? Image.memory(
                                    base64Decode(base64Img),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        color: Colors.grey.shade300,
                      ),
                      Text(
                        konten,
                        style: TextTheme.of(context).bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}