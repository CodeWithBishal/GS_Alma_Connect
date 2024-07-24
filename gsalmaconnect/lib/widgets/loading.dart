import 'package:flutter/material.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/image.dart';
import 'package:shimmer/shimmer.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: ColorDefination.blue,
      ),
    );
  }
}

class LoadingCards extends StatelessWidget {
  const LoadingCards({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: (Colors.grey[300])!,
                  highlightColor: (Colors.grey[100])!,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        child: Text(
                          "All",
                          style: TextStyle(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width / 50,
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "_________",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            "_____________",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Shimmer.fromColors(
                  baseColor: (Colors.grey[300])!,
                  highlightColor: (Colors.grey[100])!,
                  child: SizedBox(
                    width: width,
                    child: const Text(
                      "Dr Vikram Sarabhai founded ISRO in 1969. He is also considered the father of the Indian space program.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                imageErrorWidget(
                  width,
                  height,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
