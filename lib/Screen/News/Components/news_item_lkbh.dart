import 'dart:convert';
import 'package:aplikasi_lkbh_unmul/Screen/News/news_detail_lkbh.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsItemLkbh extends StatelessWidget {
  final Map<String, dynamic> news;
  final String docId;

  const NewsItemLkbh({
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
    
    String formattedDate = '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return NewsDetailLkbh(
            news: news,
            docId: docId,
          );
        }));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 100,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: base64Img.isNotEmpty
                    ? Image.memory(
                        base64Decode(base64Img),
                        fit: BoxFit.cover,
                        width: 130,
                        height: 100,
                      )
                    : Container(
                        width: 130,
                        height: 100,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported),
                      ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      konten,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 13,
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
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
}