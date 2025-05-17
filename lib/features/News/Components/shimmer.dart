import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
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
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Container(
                      width: 130,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 240,
                            height: (11),
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
                            height: (11),
                            color: Colors.grey.shade50,
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Container(
                            width: 70,
                            height: 11,
                            color: Colors.grey.shade50,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
