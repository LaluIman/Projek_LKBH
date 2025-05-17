
import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:aplikasi_lkbh_unmul/features/News/Model/news.dart';
import 'package:aplikasi_lkbh_unmul/features/News/news_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NewsItem extends StatelessWidget {
  const NewsItem({
    super.key,
    required this.news,
  });

  final Data news;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return NewsDetailscreen(
            news: news,
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
                child: SizedBox(
                  width: 130,
                  height: 100,
                  child: news.image?.isNotEmpty == true 
                    ? CachedNetworkImage(
                        fadeInCurve: Curves.easeIn,
                        fadeOutCurve: Curves.easeOut,
                        fadeInDuration: Duration(milliseconds: 300),
                        fadeOutDuration: Duration(milliseconds: 300),
                        imageUrl: news.image!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              color: KPrimaryColor,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => _buildImageError(),
                      )
                    : _buildImageError(),
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
                    news.title!,
                    style: TextTheme.of(context).bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    news.description!,
                    style: TextTheme.of(context).bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    news.isoDate!,
                    style: TextTheme.of(context).labelSmall,)
                ],
              ))
            ],
          ),
        ),
      ),
    );
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

