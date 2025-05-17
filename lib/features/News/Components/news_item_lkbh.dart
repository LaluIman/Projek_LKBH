import 'dart:convert';
import 'dart:typed_data';
import 'package:aplikasi_lkbh_unmul/features/News/news_detail_lkbh.dart';
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
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
    String judul = news['judul'] ?? 'Judul tidak tersedia';
    String konten = news['konten'] ?? 'Konten tidak tersedia';
    Timestamp timestamp = news['tanggal'] ?? Timestamp.now();
    String base64Img = news['gambar'] ?? '';

    String formattedDate = _formatDate(timestamp);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailLkbh(
              news: news,
              docId: docId,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 110,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 130,
                  height: 100,
                  child: _buildImage(base64Img),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        judul,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          _stripHtmlTags(konten),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 4),
                      SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextTheme.of(context).labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String base64Img) {
    if (base64Img.isEmpty) {
      return _buildImageError();
    }

    try {
      Uint8List imageBytes = base64Decode(base64Img);
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: 130,
        height: 100,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return _buildImageError();
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                color: KPrimaryColor,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error decoding base64 image: $e');
      return _buildImageError();
    }
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey[400],
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              'Gambar\ntidak tersedia',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    try {
      DateTime date = timestamp.toDate();
      List<String> bulan = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${bulan[date.month - 1]} ${date.year}';
    } catch (e) {
      print('Error formatting date: $e');
      return 'Tanggal tidak valid';
    }
  }

  String _stripHtmlTags(String htmlString) {
    // Remove HTML tags from content for better display
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);
    return htmlString.replaceAll(exp, '').trim();
  }
}