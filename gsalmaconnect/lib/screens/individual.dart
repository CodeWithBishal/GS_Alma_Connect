import 'package:flutter/material.dart';
import 'package:gsconnect/screens/pages/homepage.dart';
import 'package:gsconnect/widgets/appbar.dart';

class IndividualPost extends StatefulWidget {
  final String content;
  final String imgUrl;
  final String name;
  final String userName;
  final String extURL;
  final String userPfp;
  final List likes;
  final String cUID;
  final String postID;
  final bool isAllowDM;
  final String userUid;
  final String shareID;
  final bool isOfficialUpdate;
  final int views;
  final String date;
  final List<String> tagsList;
  final bool isLiked;
  final String communityRole;
  final String fcmToken;
  final List noOfReports;
  final bool isHidden;

  const IndividualPost({
    super.key,
    required this.content,
    required this.imgUrl,
    required this.name,
    required this.userName,
    required this.userPfp,
    required this.extURL,
    required this.likes,
    required this.cUID,
    required this.postID,
    required this.isAllowDM,
    required this.userUid,
    required this.shareID,
    required this.tagsList,
    required this.views,
    required this.date,
    required this.isOfficialUpdate,
    required this.isLiked,
    required this.communityRole,
    required this.fcmToken,
    required this.noOfReports,
    required this.isHidden,
  });

  @override
  State<IndividualPost> createState() => _IndividualPostState();
}

class _IndividualPostState extends State<IndividualPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: loggedInAppBar(
        context: context,
        isBack: true,
      ),
      body: ListView(
        children: [
          Cards(
            fcmToken: widget.fcmToken,
            userName: widget.userName,
            userPfp: widget.userPfp,
            name: widget.name,
            content: widget.content,
            imgUrl: widget.imgUrl,
            context: context,
            isShowallContent: true,
            isIndividual: true,
            extURL: widget.extURL,
            likes: widget.likes,
            cUID: widget.cUID,
            postID: widget.postID,
            isAllowDM: widget.isAllowDM,
            isOfficialUpdate: widget.isOfficialUpdate,
            userUid: widget.userUid,
            shareID: widget.shareID,
            tagsList: widget.tagsList,
            views: widget.views,
            date: widget.date,
            isLiked: widget.isLiked,
            noOfReports: widget.noOfReports,
            isHidden: widget.isHidden,
            communityRole: widget.communityRole,
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text("Comments are Coming Soon"),
          )
        ],
      ),
    );
  }
}
