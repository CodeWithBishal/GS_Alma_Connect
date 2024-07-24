import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/models/hive/hive_user.dart';
import 'package:gsconnect/screens/auth/redirect.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:gsconnect/widgets/verify_dialog.dart';
import 'package:hive_flutter/hive_flutter.dart';

final userHiveData = Hive.box<UserProfileData>(HiveBoxes.userProfileData);

class HiveBoxes {
  static String get userProfileData {
    return "user_profile_date";
  }
}

//AHandle HIVE

Future addToHive(
  String uid,
  String fullname,
  String phoneNumber,
  String email,
  String userName,
  String dateTime,
  bool isVerified,
  String imgURL,
  String enrollmentNo,
  String lastProfileUpdateTime,
  List domain,
  String communityRole,
  int noOfPosts,
  String branch,
  String enrollmentYear,
  String profileHeadline,
  String researchBrief,
  String course,
  List otherUserData,
  String fcmToken,
) async {
  if (userHiveData.length > 0) {
    await userHiveData.clear();
    await userHiveData.deleteAll(userHiveData.keys);
  }
  userHiveData.add(
    UserProfileData(
      uid: uid,
      fullname: fullname,
      phoneNumber: phoneNumber,
      email: email,
      userName: userName,
      dateTime: dateTime,
      isVerified: isVerified,
      imgURL: imgURL,
      enrollmentNo: enrollmentNo,
      domain: domain,
      communityRole: communityRole,
      lastProfileUpdateTime: lastProfileUpdateTime,
      noOfPosts: noOfPosts,
      branch: branch,
      enrollmentYear: enrollmentYear,
      profileHeadline: profileHeadline,
      researchBrief: researchBrief,
      otherUserData: otherUserData,
      course: course,
      fcmToken: fcmToken,
    ),
  );
}

Future checkHiveDatabase() async {
  User? user = FirebaseAuth.instance.currentUser;
  String uid = user?.uid ?? "";

  //Fetch userData from realtimedatabse for once
  Future fetchAndAdd() async {
    String uid = FirebaseAuth.instance.currentUser!.uid.toString();
    final DataSnapshot userData = await userDataRTDB.child(uid).get();

    userHiveData.add(
      UserProfileData(
        uid: userData.child("uid").value.toString(),
        fullname: userData.child("fullname").value.toString(),
        phoneNumber: userData.child("phoneNumber").value.toString(),
        email: userData.child("email").value.toString(),
        userName: userData.child("userName").value.toString(),
        dateTime: userData.child("dateTime").value.toString(),
        isVerified: bool.parse(
          userData.child("isVerified").value.toString(),
        ),
        imgURL: userData.child("imgURL").value.toString(),
        enrollmentNo: userData.child("enrollmentNo").value.toString(),
        domain: userData.child("domain").value.toString() != "null"
            ? json.decode(
                userData.child("domain").value.toString(),
              )
            : [],
        communityRole: userData.child("communityRole").value.toString(),
        lastProfileUpdateTime:
            userData.child("lastProfileUpdateTime").value.toString(),
        noOfPosts: int.parse(userData.child("noOfPosts").value.toString()),
        branch: userData.child("branch").value.toString(),
        enrollmentYear: userData.child("enrollmentYear").value.toString(),
        profileHeadline: userData.child("profileHeadline").value.toString(),
        researchBrief: userData.child("researchBrief").value.toString(),
        otherUserData:
            userData.child("otherUserData").value.toString() != "null"
                ? json.decode(
                    userData.child("otherUserData").value.toString(),
                  )
                : [],
        course: userData.child("course").value.toString(),
        fcmToken: userData.child("fcmToken").value.toString(),
      ),
    );
  }

  if (userHiveData.length != 1 || userHiveData.getAt(0)!.uid != uid) {
    await userHiveData.clear();
    await userHiveData.deleteAll(userHiveData.keys);
    await fetchAndAdd();
  }
}

//For verified pages
bool isHiveExist() {
  User? user = FirebaseAuth.instance.currentUser;
  String uid = user?.uid ?? "";
  if (userHiveData.length == 0) {
    return false;
  } else if (userHiveData.length > 0 && userHiveData.getAt(0)!.uid != uid) {
    return false;
  } else {
    return true;
  }
}

bool notVerified() {
  if (isHiveExist()) {
    //if not verified return true
    return !userHiveData.getAt(0)!.isVerified;
  } else {
    return true;
  }
}

Future handleVerify(BuildContext context) async {
  //True means keep the loading screen on
  Completer<bool> completer = Completer<bool>();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    late bool boolReturn = true;
    if (isHiveExist() && notVerified() && context.mounted) {
      verifyBottomSheet(context);
    } else if (notVerified() == false) {
      //User is verified Allow perform all actions
      boolReturn = false;
    } else {
      await checkHiveDatabase();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const RedirectUser(),
        ),
        (route) => false,
      );
    }
    completer.complete(boolReturn);
  });
  return completer.future;
}

/// E.g. after updating DP, after linking enrollment no.
Future deleteHiveAndRefetch() async {
  await userHiveData.clear();
  await userHiveData.deleteAll(userHiveData.keys);
  await checkHiveDatabase();
}

Future onlyDeleteHive() async {
  await userHiveData.clear();
  await userHiveData.deleteAll(userHiveData.keys);
}
