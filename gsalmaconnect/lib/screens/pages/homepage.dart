import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/models/hive/hive_user.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/backend/notification.dart';
import 'package:gsconnect/screens/individual.dart';
import 'package:gsconnect/screens/pages/profile.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/theme/whitelabel.dart';
import 'package:gsconnect/widgets/badge.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:gsconnect/widgets/image.dart';
import 'package:gsconnect/widgets/image_dialog.dart';
import 'package:gsconnect/widgets/likes_dm.dart';
import 'package:gsconnect/widgets/loading.dart';
import 'package:gsconnect/widgets/toast.dart';
import 'package:gsconnect/widgets/url_launcher.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final bool isMyPost;
  final bool isOfficialUpdate;
  const HomePage({
    super.key,
    required this.isMyPost,
    required this.isOfficialUpdate,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String cUserUID = FirebaseAuth.instance.currentUser?.uid ?? "";
  late UserProfileData hiveData = UserProfileData(
      uid: "",
      fullname: "",
      phoneNumber: "",
      email: "",
      userName: "",
      dateTime: "",
      isVerified: false,
      imgURL: "",
      enrollmentNo: "",
      domain: [],
      communityRole: "",
      lastProfileUpdateTime: "",
      noOfPosts: 0,
      branch: "",
      enrollmentYear: "",
      profileHeadline: "",
      researchBrief: "",
      course: "",
      otherUserData: [],
      fcmToken: "");
  @override
  void initState() {
    checkHiveDatabase().then((value) {
      hiveData = userHiveData.getAt(0)!;
    });
    NotificationFirebase.handleFirebaseMessagingToken(context);
    feedPostsRTDB.keepSynced(false);
    FirebaseCrashlytics.instance.setUserIdentifier(cUserUID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    handleVerify(context);
    final query = widget.isOfficialUpdate ? officialUpdateRTDB : feedPostsRTDB;
    final bool isHiddenHide = widget.isMyPost ? false : true;
    return SafeArea(
      child: RealtimeDBPagination(
        limit: widget.isOfficialUpdate ? 3 : 5,
        query: query,
        descending: true,
        //DO NOT TURN ON ISLIVE
        isLive: false,
        orderBy: null,
        myPosts: widget.isMyPost,
        myPostsUID: cUserUID,
        onEmpty: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            widget.isMyPost
                ? "You haven't posted any content Yet, Start Posting content and it will showup here."
                : "No Content to show! Please try again after some time",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        initialLoader: SizedBox(
          height: height,
          width: width,
          child: const LoadingCards(),
        ),
        itemBuilder: (context, snapshot, index) {
          final String userUid = snapshot.child("UID").value.toString();
          final String postID = snapshot.child("ID").value.toString();
          final String content = snapshot.child("Message").value.toString();
          final String imgUrl = snapshot.child("imgURL").value.toString();
          final String extURL = snapshot.child("extURL").value.toString();
          final String sharedID = snapshot.child("sharedID").value.toString();
          final bool isHidden =
              bool.parse(snapshot.child("isHidden").value.toString());
          final String userName = snapshot.child("userName").value.toString();
          final String userPfp = snapshot.child("userPfp").value.toString();
          final String name = snapshot.child("name").value.toString();
          final String dateTime = snapshot.child("dateTime").value.toString();
          final int views = int.parse(snapshot.child("views").value.toString());
          final bool isAllowDM =
              bool.parse(snapshot.child("isAllowDM").value.toString());
          final String likesSnapshot =
              jsonEncode(snapshot.child("Likes").value);
          final String noOfReports =
              jsonEncode(snapshot.child("isReported").value);
          late List reports = [];
          if (noOfReports != "" &&
              noOfReports.isNotEmpty &&
              noOfReports != "null") {
            reports = List.from(jsonDecode(noOfReports));
          }
          late List likes = [];
          if (likesSnapshot != "" || likesSnapshot.isNotEmpty) {
            likes = List.from(jsonDecode(likesSnapshot));
          }
          final String communityRole =
              snapshot.child("communityRole").value.toString();
          final String fcmToken = snapshot.child("fcmToken").value.toString();
          final String tagsSnapshot = jsonEncode(snapshot.child("tags").value);
          late List<String> listOfTags = [];
          if (tagsSnapshot != "" &&
              tagsSnapshot.isNotEmpty &&
              tagsSnapshot != "null") {
            listOfTags = List.from(jsonDecode(tagsSnapshot));
          }
          bool isLiked = likes.contains(cUserUID);
          if (isHiddenHide &&
              !isHidden &&
              widget.isOfficialUpdate &&
              (listOfTags.toString().contains(
                      (int.parse(hiveData.enrollmentYear) + 4).toString()) ||
                  listOfTags.toString().contains(hiveData.communityRole) ||
                  listOfTags.toString().contains("Announcement For All") ||
                  listOfTags.toString().contains(hiveData.course))) {
            return Cards(
              userName: userName,
              userPfp: userPfp,
              name: name,
              content: content,
              imgUrl: imgUrl,
              context: context,
              isShowallContent: false,
              isIndividual: false,
              extURL: extURL,
              likes: likes,
              cUID: cUserUID,
              postID: postID,
              isAllowDM: isAllowDM,
              isOfficialUpdate: widget.isOfficialUpdate,
              userUid: userUid,
              shareID: sharedID,
              tagsList: listOfTags,
              views: views,
              date: dateTime,
              isLiked: isLiked,
              communityRole: communityRole,
              noOfReports: reports,
              isHidden: isHidden,
              fcmToken: fcmToken,
            );
          } else if (isHiddenHide && !isHidden && !widget.isOfficialUpdate) {
            return Cards(
              userName: userName,
              userPfp: userPfp,
              name: name,
              content: content,
              imgUrl: imgUrl,
              context: context,
              isShowallContent: false,
              isIndividual: false,
              extURL: extURL,
              likes: likes,
              cUID: cUserUID,
              postID: postID,
              isAllowDM: isAllowDM,
              isOfficialUpdate: widget.isOfficialUpdate,
              userUid: userUid,
              shareID: sharedID,
              tagsList: listOfTags,
              views: views,
              date: dateTime,
              isLiked: isLiked,
              communityRole: communityRole,
              noOfReports: reports,
              isHidden: isHidden,
              fcmToken: fcmToken,
            );
          } else if (!isHiddenHide) {
            // MyProfile
            if (isHidden) {
              listOfTags.add("THIS POST HAS BEEN REMOVED");
            }
            return Cards(
              userName: userName,
              userPfp: userPfp,
              name: name,
              content: content,
              imgUrl: imgUrl,
              context: context,
              isShowallContent: false,
              isIndividual: false,
              extURL: extURL,
              likes: likes,
              cUID: cUserUID,
              postID: postID,
              isAllowDM: isAllowDM,
              isOfficialUpdate: widget.isOfficialUpdate,
              userUid: userUid,
              shareID: sharedID,
              tagsList: listOfTags,
              views: views,
              date: dateTime,
              isLiked: isLiked,
              communityRole: communityRole,
              fcmToken: fcmToken,
              noOfReports: reports,
              isHidden: isHidden,
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}

class Cards extends StatefulWidget {
  final String userName;
  final String userPfp;
  final String communityRole;
  final String name;
  final String content;
  final String imgUrl;
  final bool isHidden;
  final BuildContext context;
  final bool isShowallContent;
  final bool isIndividual;
  final String extURL;
  final List likes;
  final String cUID;
  final String postID;
  final bool isAllowDM;
  final bool isOfficialUpdate;
  final String shareID;
  final String userUid;
  final int views;
  final String date;
  final List<String> tagsList;
  final bool isLiked;
  final String fcmToken;
  final List noOfReports;
  const Cards({
    super.key,
    required this.userName,
    required this.userPfp,
    required this.name,
    required this.content,
    required this.imgUrl,
    required this.context,
    required this.isShowallContent,
    required this.isIndividual,
    required this.extURL,
    required this.likes,
    required this.cUID,
    required this.postID,
    required this.isAllowDM,
    required this.isOfficialUpdate,
    required this.shareID,
    required this.userUid,
    required this.tagsList,
    required this.views,
    required this.date,
    required this.isLiked,
    required this.communityRole,
    required this.fcmToken,
    required this.noOfReports,
    required this.isHidden,
  });

  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  Widget myPostsDrawer(height, width) {
    return FittedBox(
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                child: TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await feedPostsRTDB
                        .child(widget.postID)
                        .child("isHidden")
                        .set(true);
                    flutterToast("Post has been removed successfully!");
                  },
                  style: transparentButtonStyle,
                  icon: const LineIcon(
                    LineIcons.trash,
                    size: 20,
                  ),
                  label: Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget postsDrawer(height, width) {
    return FittedBox(
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                child: TextButton.icon(
                  onPressed: !widget.isOfficialUpdate
                      ? () async {
                          Navigator.pop(context);
                          if (widget.noOfReports.contains(widget.cUID)) {
                            flutterToast(
                              "Already reported, can't report again!",
                            );
                          } else {
                            widget.noOfReports.add(widget.cUID.toString());
                            await feedPostsRTDB
                                .child(widget.postID)
                                .child("isReported")
                                .set(widget.noOfReports);
                            flutterToast(
                                "Post reported successfully and your data has been sent!");
                          }
                        }
                      : () {
                          Navigator.pop(context);
                          flutterToast("Post Can't be reported");
                        },
                  style: transparentButtonStyle,
                  icon: const LineIcon(
                    LineIcons.flag,
                    size: 20,
                  ),
                  label: Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Report",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void individualRedirect(query) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => IndividualPost(
          content: widget.content,
          imgUrl: widget.imgUrl,
          name: widget.name,
          userName: widget.userName,
          userPfp: widget.userPfp,
          extURL: widget.extURL,
          likes: widget.likes,
          cUID: widget.cUID,
          postID: widget.postID,
          isAllowDM: widget.isAllowDM,
          userUid: widget.userUid,
          shareID: widget.shareID,
          tagsList: widget.tagsList,
          views: widget.views,
          date: widget.date,
          isOfficialUpdate: widget.isOfficialUpdate,
          isLiked: widget.isLiked,
          communityRole: widget.communityRole,
          fcmToken: widget.fcmToken,
          noOfReports: widget.noOfReports,
          isHidden: widget.isHidden,
        ),
      ),
    ).then(
      (value) =>
          query.child(widget.postID).child("views").set(widget.views + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final query = widget.isOfficialUpdate ? officialUpdateRTDB : feedPostsRTDB;
    return GestureDetector(
      onTap: widget.userName != "" && widget.isIndividual == false
          ? () {
              //if user is defined and the current page is not individual; redirect
              individualRedirect(query);
            }
          : null,
      child: Column(
        children: [
          Material(
            color: ColorDefination.blueBg,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              //only verified users can view other's profile
                              onTap: !notVerified()
                                  ? () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => MyProfile(
                                            isMyProfile: false,
                                            uid: widget.userUid,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: widget.userPfp != ""
                                  ? CachedImageNetworkimage(
                                      url: widget.userPfp,
                                      width: 50,
                                      isBorder: false,
                                      height: 0,
                                      isCircle: true,
                                      isMaxHeight: true,
                                    )
                                  : const SizedBox(
                                      width: 50,
                                    ),
                            ),
                            SizedBox(
                              width: width / 50,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${widget.name} ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    widget.isOfficialUpdate
                                        ? const Icon(
                                            Icons.verified,
                                            color: Colors.green,
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                                SizedBox(
                                  width: width / 1.7,
                                  child: BadgeWidget(
                                    communityRole: widget.communityRole,
                                    text: "@${widget.userName}",
                                    textStyle: null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        !notVerified() && !widget.isHidden
                            ? IconButton(
                                style: transparentButtonStyle,
                                onPressed: () async {
                                  // same row as of user DP and Name
                                  await showModalBottomSheet(
                                    backgroundColor: ColorDefination.bgColor,
                                    context: context,
                                    builder: (context) {
                                      return widget.userUid == widget.cUID
                                          ? myPostsDrawer(height, width)
                                          : postsDrawer(height, width);
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.more_horiz,
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                    SizedBox(
                      height: widget.tagsList.isEmpty ? 0 : height / 20,
                      child: ListView.builder(
                        itemCount: widget.tagsList.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.elliptical(15, 15),
                                  ),
                                  color: ColorDefination.blueBg,
                                ),
                                child: Text(
                                  widget.tagsList[index],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: ReadMoreText(
                            "${widget.content} ",
                            isExpandable:
                                widget.isShowallContent ? false : true,
                            isCollapsed: widget.isShowallContent
                                ? ValueNotifier(false)
                                : ValueNotifier(true),
                            trimMode: TrimMode.Line,
                            trimLines: 3,
                            style: TextStyle(
                              fontSize: widget.isIndividual ? 18 : 14,
                            ),
                            colorClickableText: Colors.black,
                            trimCollapsedText: 'Show more',
                            trimExpandedText:
                                !widget.isShowallContent ? 'Show less' : "",
                            moreStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            lessStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            annotations: [
                              Annotation(
                                regExp: RegExp(r'#([a-zA-Z0-9_]+)'),
                                spanBuilder: (
                                        {required String text,
                                        TextStyle? textStyle}) =>
                                    TextSpan(
                                  text: text,
                                  style:
                                      textStyle?.copyWith(color: Colors.blue),
                                ),
                              ),
                              Annotation(
                                regExp: RegExp(r'@([a-zA-Z0-9_]+)'),
                                spanBuilder: (
                                        {required String text,
                                        TextStyle? textStyle}) =>
                                    TextSpan(
                                  text: text,
                                  style: textStyle?.copyWith(
                                    color: Colors.blue,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      LaunchUrl.openLink(
                                        url: "https://gsconnect.web.app/@$text",
                                        context: context,
                                        launchMode: LaunchMode
                                            .externalNonBrowserApplication,
                                      );
                                    },
                                ),
                              ),
                              Annotation(
                                regExp: RegExp(r'https:\/\/\S+'),
                                spanBuilder: (
                                        {required String text,
                                        TextStyle? textStyle}) =>
                                    TextSpan(
                                  text: text,
                                  style: textStyle?.copyWith(
                                    color: Colors.blue,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      LaunchUrl.openLink(
                                        url: text,
                                        context: context,
                                        launchMode: LaunchMode
                                            .externalNonBrowserApplication,
                                      );
                                    },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    widget.extURL != "" && widget.extURL != "null"
                        ? Container(
                            padding: const EdgeInsets.all(10),
                            width: width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: ColorDefination.blueBg,
                            ),
                            child: GestureDetector(
                              onTap: !notVerified()
                                  ? () {
                                      final bool isHttpReq =
                                          widget.extURL.contains("http");
                                      LaunchUrl.openLink(
                                        url: isHttpReq
                                            ? widget.extURL
                                            : "https://${widget.extURL}",
                                        context: context,
                                        launchMode:
                                            LaunchMode.externalApplication,
                                      );
                                    }
                                  : () {
                                      flutterToast(
                                        "Verify Your Profile to open the link.",
                                      );
                                    },
                              child: Text(
                                !notVerified()
                                    ? widget.extURL
                                    : "Verify Your Profile to open the link.",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 10,
                    ),
                    widget.imgUrl != "" && widget.imgUrl.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      ImageDialog(imgUrl: widget.imgUrl),
                                ),
                              );
                            },
                            child: CachedImageNetworkimage(
                              url: widget.imgUrl,
                              width: width,
                              isBorder: true,
                              height: height,
                              isCircle: false,
                              isMaxHeight: true,
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 10,
                    ),
                    widget.isIndividual
                        ? SizedBox(
                            width: width,
                            child: Text(
                              widget.date,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          )
                        : const SizedBox(),
                    widget.isOfficialUpdate || !widget.isIndividual
                        ? const SizedBox()
                        : const Divider(), //Divider
                    LikesDM(
                      isLiked: widget.isLiked,
                      likes: widget.likes,
                      cUID: widget.cUID,
                      postID: widget.postID,
                      isAllowDM: widget.isAllowDM,
                      onlyLikes: false,
                      shareID: widget.shareID,
                      isIndividual: widget.isIndividual,
                      views: widget.views,
                      cmtBtn: (val) {
                        individualRedirect(query);
                      },
                      isOfficialUpdate: widget.isOfficialUpdate,
                      postUserUID: widget.userUid,
                      userDP: widget.userPfp,
                      fullName: widget.name,
                      userName: widget.userName,
                      fcmToken: widget.fcmToken,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

String shareLink(bool isOfficial, String shareID) {
  return isOfficial ? "${domain}announcement/$shareID" : "${domain}p/$shareID";
}

Widget shareLinkWidget(
    {required bool isText, required String shareID, required bool isOfficial}) {
  return isText
      ? TextButton.icon(
          onPressed: () {
            Share.share(
              shareLink(
                isOfficial,
                shareID,
              ),
            );
          },
          icon: const LineIcon(
            LineIcons.share,
            size: 20,
          ),
          label: const Text(
            "Share",
          ),
        )
      : IconButton(
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              Colors.transparent,
            ),
          ),
          onPressed: () {
            Share.share(
              shareLink(
                isOfficial,
                shareID,
              ),
            );
          },
          icon: LineIcon(
            Icons.share,
            color: ColorDefination.blue,
            size: 20,
          ),
        );
}
