import 'package:aplikasi_lkbh_unmul/Screen/User/News/Components/news_item.dart';
import 'package:aplikasi_lkbh_unmul/Screen/User/News/Components/shimmer.dart';
import 'package:aplikasi_lkbh_unmul/Screen/User/News/Model/news_response.dart';
import 'package:aplikasi_lkbh_unmul/Screen/User/News/Model/api_caller.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';

class NewsScreen extends StatefulWidget {
  static String routeName = "/news";
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _selectedColor = KPrimaryColor;
  final _unselectedColor = Color(0xff5f6368);
  final _tabs = [
    Tab(
      text: "Berita LKBH",
    ),
    Tab(
      text: "Berita Luar",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Berita Terkini",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "Lihat berita terbaru tentang Hukum dan Politik",
                    style: TextStyle(
                        color: KGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TabBar(
                        tabs: _tabs,
                        labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                        ),
                        labelColor: _selectedColor,
                        indicatorColor: _selectedColor,
                        indicatorSize: TabBarIndicatorSize.label,
                        unselectedLabelColor: _unselectedColor,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - 200,
                          child: TabBarView(children: [
                            NewsOutside(),
                            NewsOutside(),
                          ]),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }
}

class NewsOutside extends StatelessWidget {
  const NewsOutside({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NewsResponse>(
        future: ApiCaller().fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerEffect();
          } else if (snapshot.hasError) {
            return Text("Error");
          } else {
            final news = snapshot.data!.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemCount: news.length,
              itemBuilder: (context, index) {
                return NewsItem(news: news[index]);
              },
            );
          }
        });
  }
}
