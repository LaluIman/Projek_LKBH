import 'package:aplikasi_lkbh_unmul/Screen/News/Components/news_item.dart';
import 'package:aplikasi_lkbh_unmul/Screen/News/Components/shimmer.dart';
import 'package:aplikasi_lkbh_unmul/Screen/News/Model/news_response.dart';
import 'package:aplikasi_lkbh_unmul/Screen/News/Model/api_caller.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Berita Terkini",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "Lihat berita dan kegiata terbaru dari LKBH FH UNMUL \n atau dari berita hukum dan politik dari luar",
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
                            fontSize: 16, fontWeight: FontWeight.w600),
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
            return Stack(
              children: [
                Shimmer(
                  enabled: true,
                  gradient: LinearGradient(colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade300,
                    Colors.grey.shade200,
                    Colors.grey.shade300,
                    Colors.grey.shade200,
                    Colors.grey.shade300,
                    Colors.grey.shade200,
                  ]),
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: SizedBox(
                            width: double.infinity,
                            height: 100,
                            child: Row(
                              children: [
                                Container(
                                  width: 130,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: 240,
                                      height: 15,
                                      color: Colors.grey.shade300,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      width: 180,
                                      height: 11,
                                      color: Colors.grey.shade300,
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: 150,
                                      height: 11,
                                      color: Colors.grey.shade50,
                                    ),
                                    SizedBox(
                                      height: 25,
                                    ),
                                    Container(
                                      width: 70,
                                      height: 12,
                                      color: Colors.grey.shade50,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 200,
                  left: 110,
                  child: Column(
                  children: [
                    Icon(Icons.wifi_off, color: KPrimaryColor, size: 50,),
                    SizedBox(height: 10,),
                    Text("Tidak ada internet", style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600
                    ),)
                  ],
                )),
              ],
            );
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
