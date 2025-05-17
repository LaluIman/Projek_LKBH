//
import 'package:aplikasi_lkbh_unmul/core/components/default_back_button.dart';
import 'package:aplikasi_lkbh_unmul/core/components/default_button.dart';
import 'package:aplikasi_lkbh_unmul/features/News/Model/news.dart';import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/link.dart';

class NewsDetailscreen extends StatelessWidget {
  static String routeName = "/news_detail";
  const NewsDetailscreen({super.key, required this.news});

  final Data news;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leadingWidth: 150,
          backgroundColor: Colors.white,
          leading: DefaultBackButton(),
          actions: [
            Padding(
              padding: EdgeInsets.only(left: 17),
              child: IconButton(
                icon: Icon(
                  Icons.ios_share,
                  color: KPrimaryColor,
                ),
                onPressed: () async {
                  final result = await Share.share('${news.link}',
                      subject: "Kirim berita ini");
                  if (result.status == ShareResultStatus.success) {
                    
                  }
                },
              ),
            )
          ],
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
                          news.isoDate!,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
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
                          "${news.title!}.",
                          style: TextTheme.of(context).titleLarge,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          height: 260,
                          child: SizedBox(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: news.image!,
                                fit: BoxFit.cover,
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
                          news.description!,
                          style:  TextTheme.of(context).bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Link(
            uri: Uri.parse(news.link!),
            builder: (context, followlink) {
              return DefaultButton(icon: "assets/icons/Read.svg", text: "Lihat selengkapnya", press: followlink, bgcolor: KPrimaryColor, textColor: Colors.white);
            },
          ),
        ));
  }
}
