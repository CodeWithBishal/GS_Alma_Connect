import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ListChatsLoader extends StatelessWidget {
  const ListChatsLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10, // Adjust the number of shimmering items as needed
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
            ),
            title: Container(
              height: 20,
              color: Colors.white,
            ),
            subtitle: Container(
              height: 16,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}

class PlaceHolderListMessage extends StatelessWidget {
  const PlaceHolderListMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10, // Adjust the number of shimmering items as needed
        itemBuilder: (context, index) {
          return Align(
            alignment: index % 2 == 0 ? Alignment.topLeft : Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: index % 2 == 0
                    ? const BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                      )
                    : const BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        topLeft: Radius.circular(30),
                      ),
              ),
              margin: const EdgeInsets.only(top: 10, right: 10, left: 10),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: index % 2 == 0
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 30,
                    width: width / 2,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
