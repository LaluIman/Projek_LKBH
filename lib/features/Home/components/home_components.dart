import 'package:aplikasi_lkbh_unmul/features/News/Components/news_item.dart';
import 'package:aplikasi_lkbh_unmul/features/News/Components/shimmer.dart';
import 'package:aplikasi_lkbh_unmul/features/News/Model/api_caller.dart';
import 'package:aplikasi_lkbh_unmul/features/News/Model/news_response.dart';import 'package:aplikasi_lkbh_unmul/core/constant/theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

class NameShimmer extends StatelessWidget {
  const NameShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 210,
        height: 23,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
  
  
class Carousel extends StatefulWidget {
  const Carousel({super.key});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        CarouselSlider(
          items: [
            Image.asset("assets/images/Banner.png"),
            Image.asset("assets/images/banner 2.png"),
            Image.asset("assets/images/Banner 3.png"),
          ],
          options: CarouselOptions(
            height: 160,
            viewportFraction: 0.9,
            padEnds: true,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            enableInfiniteScroll: false,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 1000),
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [0, 1, 2].map((index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.ease,
              width: _currentIndex == index ? 25 : 9,
              height: 9,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: KPrimaryColor.withOpacity(
                    _currentIndex == index ? 0.9 : 0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class HomeHeaderButton extends StatelessWidget {
  const HomeHeaderButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, "/notificationScreen");
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SvgPicture.asset(
                "assets/icons/Notif.svg",
                width: 17,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, "/consultation_history");
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SvgPicture.asset(
                "assets/icons/List Chat.svg",
                width: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeNewsSection extends StatefulWidget {
  const HomeNewsSection({super.key});

  @override
  State<HomeNewsSection> createState() => _HomeNewsSectionState();
}

class _HomeNewsSectionState extends State<HomeNewsSection> {
  late Future<NewsResponse> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = ApiCaller().fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Berita terbaru",
            style: TextTheme.of(context).titleMedium?.copyWith(
              fontWeight: FontWeight.w700
            )
          ),
          SizedBox(height: 10),
          FutureBuilder<NewsResponse>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ShimmerEffect();
                } else if (snapshot.hasError) {
                  return ShimmerEffect();
                } else if (!snapshot.hasData || snapshot.data?.data == null) {
                  return Center(child: Text("Tidak ada berita tersedia"));
                } else {
                  final news = snapshot.data!.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: news.length > 5 ? 5 : news.length,
                    itemBuilder: (context, index) {
                      return NewsItem(news: news[index]);
                    },
                  );
                }
              })
        ],
      ),
    );
  }
}