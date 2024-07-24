import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:gsconnect/screens/individual.dart';
import 'package:gsconnect/screens/pages/profile.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:gsconnect/widgets/snacbar.dart';
import 'package:gsconnect/widgets/toast.dart';

handleSearchUsername(String str, BuildContext context) async {
  if (str.contains("@")) {
    //search for usernames from dynamic links
    DatabaseEvent databaseEvent = await publicUserDataRTDB
        .orderByChild("UserName")
        .equalTo(str.replaceAll("@", ""))
        .once();
    if ((databaseEvent.snapshot.value == null && context.mounted) ||
        (databaseEvent.snapshot
                    .child(str.replaceAll("@", ""))
                    .child("isVerified")
                    .value
                    .toString() ==
                "false" &&
            context.mounted)) {
      customSnacBar(context, "Username Not Found");
    } else if (context.mounted) {
      final uid = databaseEvent.snapshot
          .child(str.replaceAll("@", ""))
          .child("UID")
          .value
          .toString();
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => MyProfile(
            isMyProfile: false,
            uid: uid,
          ),
        ),
      );
    }
  }
}

handlePostDynamicShareLink(
    String str, BuildContext context, bool isOfficial) async {
  String cUserUID = FirebaseAuth.instance.currentUser?.uid ?? "";
  final rtdb = isOfficial
      ? await officialUpdateRTDB.orderByChild("sharedID").equalTo(str).once()
      : await feedPostsRTDB.orderByChild("sharedID").equalTo(str).once();
  if (rtdb.snapshot.value == null) {
    flutterToast("Invalid Link!");
  } else {
    Map<dynamic, dynamic> values = rtdb.snapshot.value as Map<dynamic, dynamic>;
    final data = rtdb.snapshot.child(values.keys.first);

    final String userUid = data.child("UID").value.toString();
    final String postID = data.child("ID").value.toString();
    final String content = data.child("Message").value.toString();
    final String imgUrl = data.child("imgURL").value.toString();
    final String extURL = data.child("extURL").value.toString();
    final String sharedID = data.child("sharedID").value.toString();
    final bool isHidden = bool.parse(data.child("isHidden").value.toString());
    final String userName = data.child("userName").value.toString();
    final String userPfp = data.child("userPfp").value.toString();
    final String name = data.child("name").value.toString();
    final String dateTime = data.child("dateTime").value.toString();
    final int views = int.parse(data.child("views").value.toString());
    final bool isAllowDM = bool.parse(data.child("isAllowDM").value.toString());
    final String likesSnapshot = jsonEncode(data.child("Likes").value);
    final String communityRole = data.child("communityRole").value.toString();
    final String fcmToken = data.child("fcmToken").value.toString();
    final String noOfReports = data.child("isReported").value.toString();
    late List reports = [];
    if (noOfReports != "" && noOfReports.isNotEmpty && noOfReports != "null") {
      reports = List.from(jsonDecode(noOfReports));
    }
    late List likes = [];
    if (likesSnapshot != "" || likesSnapshot.isNotEmpty) {
      likes = List.from(jsonDecode(likesSnapshot));
    }
    final String tagsSnapshot = jsonEncode(data.child("tags").value);
    late List<String> listOfTags = [];
    if (tagsSnapshot != "" &&
        tagsSnapshot.isNotEmpty &&
        tagsSnapshot != "null") {
      listOfTags = List.from(jsonDecode(tagsSnapshot));
    }

    bool isLiked = likes.contains(cUserUID);
    if (isHidden) {
      flutterToast("Post is archived and not allowed to open");
    } else {
      if (!context.mounted) return;
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => IndividualPost(
            content: content,
            imgUrl: imgUrl,
            name: name,
            userName: userName,
            userPfp: userPfp,
            extURL: extURL,
            likes: likes,
            cUID: cUserUID,
            postID: postID,
            isAllowDM: isAllowDM,
            userUid: userUid,
            shareID: sharedID,
            tagsList: listOfTags,
            views: views,
            date: dateTime,
            isOfficialUpdate: false,
            isLiked: isLiked,
            communityRole: communityRole,
            fcmToken: fcmToken,
            noOfReports: reports,
            isHidden: isHidden,
          ),
        ),
      );
    }
  }
}
