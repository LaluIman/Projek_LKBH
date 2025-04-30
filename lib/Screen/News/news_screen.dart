import 'package:aplikasi_lkbh_unmul/Screen/News/Components/news_item.dart';
import 'package:aplikasi_lkbh_unmul/Screen/News/Components/news_item_lkbh.dart';
import 'package:aplikasi_lkbh_unmul/Screen/News/Components/shimmer.dart';
import 'package:aplikasi_lkbh_unmul/Screen/News/Model/news_response.dart';
import 'package:aplikasi_lkbh_unmul/Screen/News/Model/api_caller.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                Expanded(
                  child: Column(
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
                        height: 10,
                      ),
                      Expanded(
                        child: TabBarView(children: [
                          NewsLKBH(), 
                          NewsOutside(),
                        ]),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}

class NewsLKBH extends StatelessWidget {
  const NewsLKBH({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('berita')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerEffect();
        } else if (snapshot.hasError) {
          return ShimmerEffect();
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  color: KPrimaryColor,
                  size: 50,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Belum ada berita tersedia",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                )
              ],
            ),
          );
        } else {
          final beritaList = snapshot.data!.docs;
          return ListView.builder(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: beritaList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = beritaList[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return NewsItemLkbh(news: data, docId: doc.id);
            },
          );
        }
      },
    );
  }
}


class NewsOutside extends StatefulWidget {
  const NewsOutside({Key? key}) : super(key: key);

  @override
  State<NewsOutside> createState() => _NewsOutsideState();
}

class _NewsOutsideState extends State<NewsOutside> {
  late Future<NewsResponse> _newsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future only once
    _newsFuture = ApiCaller().fetchNews();
  }

  Future<void> _refreshNews() async {
    // Force the widget to rebuild with a new future
    setState(() {
      _newsFuture = ApiCaller().fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshNews,
      child: FutureBuilder<NewsResponse>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerEffect();
          } else if (snapshot.hasError) {
            return ShimmerEffect();
          } else if (!snapshot.hasData || snapshot.data?.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    color: KPrimaryColor,
                    size: 50,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Belum ada berita tersedia",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            );
          } else {
            final news = snapshot.data!.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: news.length,
              itemBuilder: (context, index) {
                return NewsItem(news: news[index]);
              },
            );
          }
        },
      ),
    );
  }
}