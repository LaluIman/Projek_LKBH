import 'package:aplikasi_lkbh_unmul/Screen/Consultation/compenents/button_consulta.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/compenents/consultation_provider.dart';
import 'package:aplikasi_lkbh_unmul/Screen/Consultation/model.dart';
import 'package:aplikasi_lkbh_unmul/Screen/News/Components/news_item.dart';
import 'package:aplikasi_lkbh_unmul/Screen/News/Components/shimmer.dart';
import 'package:aplikasi_lkbh_unmul/Screen/News/Model/api_caller.dart';
import 'package:aplikasi_lkbh_unmul/Screen/News/Model/news_response.dart';
import 'package:aplikasi_lkbh_unmul/styling.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  int _currentIndex = 0;
  Future<void>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _checkProfileAndLoadData();
  }

  Future<void> _checkProfileAndLoadData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        Navigator.pushReplacementNamed(context, '/complete_profile');
      } else {
        // Cast the data to Map<String, dynamic>
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        if (!_isProfileComplete(data)) {
          Navigator.pushReplacementNamed(context, '/complete_profile');
        } else {
          if (mounted) {
            setState(() {
              userName = data['nama'];
            });
          }
        }
      }
    } catch (e) {
      print('Error checking profile: $e');
    }
  }

  bool _isProfileComplete(Map<String, dynamic> data) {
    return data['nama'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _profileFuture,
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return HomeShimmer();
          // }

          return SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selamat datang 👋",
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                    color: KPrimaryColor,
                                  ),
                                ),
                                Text(
                                  userName ?? "User",
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.notifications,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.chat_bubble,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Banner
                    CarouselSlider(
                      items: [
                        Image.asset("assets/images/Banner.png"),
                        Image.asset(
                          "assets/images/banner 2.png",
                        ),
                        // Image.asset("assets/images/Banner.png"),
                      ],
                      options: CarouselOptions(
                        height: 200,
                        viewportFraction: 0.9,
                        padEnds: true,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                        enableInfiniteScroll: false,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 1000),
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [0, 1].map((index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.ease,
                          width: _currentIndex == index ? 25 : 9,
                          height: 9,
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: KPrimaryColor.withOpacity(
                                _currentIndex == index ? 0.9 : 0.4),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 25),
                    // Consultation
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Jenis Konsultasi",
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 1,
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              final consultationType =
                                  ConsultationType.listConsultationType[index];
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Simpan pilihan ke Provider
                                      Provider.of<ConsultationProvider>(context,
                                              listen: false)
                                          .setSelectedConsultation(
                                              consultationType);
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SizedBox(
                                            width: double.infinity,
                                            height: 400,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [ButtonConsultan()],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 66,
                                          height: 66,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        Positioned(
                                          top: 9,
                                          left: 8,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: SvgPicture.asset(
                                              consultationType.icon,
                                              width: 30,
                                              fit: BoxFit.contain,
                                              allowDrawingOutsideViewBox: true,
                                              errorBuilder:
                                                  (context, error, StackTrace) {
                                                print(
                                                    "SVG Loading error: $error");
                                                return Icon(Icons.error);
                                              },
                                              placeholderBuilder: (context) =>
                                                  Icon(Icons.image),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    consultationType.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  )
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    // News
                    HomeNewsSection()
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          FutureBuilder<NewsResponse>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ShimmerEffect();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data?.data == null) {
                  return Text("No news available");
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

// class HomeShimmer extends StatelessWidget {
//   const HomeShimmer({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SizedBox(
//         width: double.infinity,
//         child: Shimmer.fromColors(
//           baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade200,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 25),
//                   SizedBox(
//                     width: double.infinity,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: 200,
//                           height: 25,
//                           decoration: BoxDecoration(
//                               color: Colors.grey.shade200,
//                               borderRadius: BorderRadius.circular(10)),
//                         ),
//                         SizedBox(
//                           height: 5,
//                         ),
//                         Container(
//                           width: 300,
//                           height: 40,
//                           decoration: BoxDecoration(
//                               color: Colors.grey.shade200,
//                               borderRadius: BorderRadius.circular(10)),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     height: 30,
//                   ),
//                   Container(
//                     height: 150,
//                     decoration: BoxDecoration(
//                         color: Colors.grey.shade200,
//                         borderRadius: BorderRadius.circular(10)),
//                   ),
//                   SizedBox(
//                     height: 30,
//                   ),
//                   Container(
//                           width: 250,
//                           height: 30,
//                           decoration: BoxDecoration(
//                               color: Colors.grey.shade200,
//                               borderRadius: BorderRadius.circular(10)),
//                         ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   GridView.count(
//                     shrinkWrap: true,
//                     crossAxisCount: 4,
//                     crossAxisSpacing: 20,
//                     mainAxisSpacing: 20,
//                     padding: const EdgeInsets.all(10),
//                     children: List.generate(
//                         8,
//                         (index) => Container(
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                   color: Colors.grey.shade100,
//                                   borderRadius: BorderRadius.circular(10)),
//                             )),
//                   ),
//                   SizedBox(
//                     height: 25,
//                   ), 
//                   Container(
//                           width: 250,
//                           height: 30,
//                           decoration: BoxDecoration(
//                               color: Colors.grey.shade200,
//                               borderRadius: BorderRadius.circular(10)),
//                         ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Container(
//                     height: 120,
//                     decoration: BoxDecoration(
//                         color: Colors.grey.shade200,
//                         borderRadius: BorderRadius.circular(10)),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Container(
//                     height: 120,
//                     decoration: BoxDecoration(
//                         color: Colors.grey.shade200,
//                         borderRadius: BorderRadius.circular(10)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }