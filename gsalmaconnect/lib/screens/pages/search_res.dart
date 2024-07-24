import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/screens/pages/homepage.dart';
import 'package:gsconnect/screens/pages/profile.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/appbar.dart';
import 'package:gsconnect/widgets/badge.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:gsconnect/widgets/loading.dart';
import 'package:gsconnect/widgets/toast.dart';

class SearchResultPage extends StatefulWidget {
  final String queryString;
  const SearchResultPage({
    super.key,
    required this.queryString,
  });

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  User? user = FirebaseAuth.instance.currentUser;
  Future searchPost(String str, BuildContext context) async {
    DatabaseEvent databaseEvent2 = await feedPostsRTDB
        .orderByChild("Message")
        .startAt(str)
        .endAt("$str\uf8ff")
        .once();
    final databaseEventSnapshotValue2 = databaseEvent2.snapshot.value;
    //Check if data exists
    if (databaseEventSnapshotValue2 == null) {
      flutterToast("No data found");
      return;
    }

    Map allPostsQuery = {};
    final dataaa3 = jsonDecode(jsonEncode(databaseEventSnapshotValue2));
    allPostsQuery.addAll(dataaa3);
    return allPostsQuery;
  }

  Future userSearch(str) async {
    final databaseEvent1 = await publicUserDataRTDB
        .orderByChild("fullname")
        .startAt(str)
        .endAt("$str\uf8ff")
        .once();
    final databaseEvent3 = await publicUserDataRTDB
        .orderByChild("UserName")
        .startAt(str)
        .endAt("$str\uf8ff")
        .once();
    final databaseEventSnapshotValue = databaseEvent1.snapshot.value;
    final databaseEventSnapshotValue3 = databaseEvent3.snapshot.value;
    //Check if data exists
    if (databaseEventSnapshotValue == null &&
        databaseEventSnapshotValue3 == null) {
      flutterToast("No data found");
      return;
    } else {
      Map data = {};
      if (databaseEventSnapshotValue != null) {
        final dataaa3 = jsonDecode(jsonEncode(databaseEventSnapshotValue));
        data.addAll(dataaa3);
      }
      if (databaseEventSnapshotValue3 != null) {
        final dataaa3 = jsonDecode(jsonEncode(databaseEventSnapshotValue3));
        data.addAll(dataaa3);
      }
      return data;
    }
  }

  late bool isUserList = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: loggedInAppBar(
        context: context,
        isBack: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ColorDefination.blue,
        onPressed: () {
          setState(() {
            isUserList = !isUserList;
          });
        },
        label: Row(
          children: [
            Text(
              isUserList ? "Search Posts" : "Search Users",
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(
              width: 5,
            ),
            Icon(
              isUserList
                  ? Icons.newspaper
                  : Icons.supervised_user_circle_outlined,
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: isUserList
            ? userSearch(widget.queryString)
            : searchPost(widget.queryString, context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                final List keyss = snapshot.data.keys.toList();
                return isUserList
                    ? SizedBox(
                        height: 100,
                        child: Card(
                          elevation: 0,
                          color: ColorDefination.lightSecondaryColor,
                          child: Center(
                            child: ListTile(
                              leading: ClipOval(
                                child: Image.network(
                                  snapshot.data[keyss[index]]["imgURL"],
                                ),
                              ),
                              title: Text(
                                snapshot.data[keyss[index]]["fullname"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: BadgeWidget(
                                communityRole: snapshot.data[keyss[index]]
                                    ["communityRole"],
                                text:
                                    "@${snapshot.data[keyss[index]]["UserName"]}",
                                textStyle: null,
                              ),
                              trailing: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => MyProfile(
                                            isMyProfile: false,
                                            uid: snapshot.data[keyss[index]]
                                                ["UID"])),
                                  );
                                },
                                child: const Icon(
                                  Icons.message_outlined,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Cards(
                        userName: snapshot.data[keyss[index]]["userName"],
                        userPfp: snapshot.data[keyss[index]]["userPfp"],
                        name: snapshot.data[keyss[index]]["name"],
                        content: snapshot.data[keyss[index]]["Message"],
                        imgUrl: snapshot.data[keyss[index]]["imgUrl"] ?? "",
                        context: context,
                        isShowallContent: false,
                        isIndividual: false,
                        extURL: snapshot.data[keyss[index]]["extURL"],
                        likes: snapshot.data[keyss[index]]["Likes"],
                        cUID: user!.uid,
                        postID: snapshot.data[keyss[index]]["ID"],
                        isAllowDM: snapshot.data[keyss[index]]["isAllowDM"],
                        isOfficialUpdate: false,
                        shareID: snapshot.data[keyss[index]]["sharedID"],
                        userUid: snapshot.data[keyss[index]]["UID"],
                        tagsList: snapshot.data[keyss[index]]["tagsList"] ?? [],
                        views: snapshot.data[keyss[index]]["views"],
                        date: snapshot.data[keyss[index]]["dateTime"],
                        isLiked: snapshot.data[keyss[index]]["Likes"]
                            .contains(user!.uid),
                        noOfReports:
                            snapshot.data[keyss[index]]["isReported"] ?? [],
                        communityRole:
                            snapshot.data[keyss[index]]["communityRole"] ?? "",
                        fcmToken: snapshot.data[keyss[index]]["fcmToken"] ?? "",
                        isHidden:
                            snapshot.data[keyss[index]]["isHidden"] ?? false,
                      );
              },
            );
          } else {
            return const Center(
              child: Text("No Data Found! Search is case-sensitive"),
            );
          }
        },
      ),
    );
  }
}
