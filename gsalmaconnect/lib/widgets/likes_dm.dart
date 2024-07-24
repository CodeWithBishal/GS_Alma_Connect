import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/chat/chat_screen.dart';
import 'package:gsconnect/screens/pages/homepage.dart';
import 'package:gsconnect/theme/whitelabel.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

String formatLikes(int likes) {
  if (likes >= 1000) {
    return '${(likes / 1000).toStringAsFixed(1)}k';
  } else {
    return likes.toString();
  }
}

class LikesDM extends StatefulWidget {
  final bool isLiked;
  final bool isOfficialUpdate;
  final List likes;
  final int views;
  final String cUID;
  final String postID;
  final bool isAllowDM;
  final bool onlyLikes;
  final String shareID;
  final String postUserUID;
  final String userDP;
  final bool isIndividual;
  final Function(dynamic) cmtBtn;
  final String fullName;
  final String userName;
  final String fcmToken;
  const LikesDM({
    super.key,
    required this.isLiked,
    required this.likes,
    required this.cUID,
    required this.postID,
    required this.isAllowDM,
    required this.onlyLikes,
    required this.shareID,
    required this.isIndividual,
    required this.views,
    required this.cmtBtn,
    required this.isOfficialUpdate,
    required this.postUserUID,
    required this.userDP,
    required this.fullName,
    required this.userName,
    required this.fcmToken,
  });

  @override
  State<LikesDM> createState() => _LikesDMState();
}

class _LikesDMState extends State<LikesDM> {
  bool isLiked = false;
  List likes = [];
  @override
  void initState() {
    isLiked = widget.isLiked;
    likes = widget.likes;
    super.initState();
  }

  Future handleLikes() async {
    if (isLiked == true) {
      setState(() {
        likes.remove(widget.cUID);
      });
    } else {
      setState(() {
        likes.add(widget.cUID);
      });
    }
    setState(() {
      isLiked = !isLiked;
    });

    final ref = widget.isOfficialUpdate
        ? officialUpdateRTDB.child(widget.postID)
        : feedPostsRTDB.child(widget.postID);
    await ref.child("Likes").set(likes);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              color: isLiked ? Colors.red : Colors.black,
              style: transparentButtonStyle,
              onPressed: () async {
                await handleLikes();
              },
              icon: isLiked
                  ? const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    )
                  : const LineIcon(
                      LineIcons.heart,
                      size: 20,
                    ),
            ),
            Text(
              widget.onlyLikes ? "" : formatLikes(likes.length - 1),
            ),
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        !widget.isIndividual
            ? IconButton(
                // if user is not verified; if widget is not individual
                onPressed: !notVerified() && !widget.isIndividual
                    ? () {
                        widget.cmtBtn(
                          widget.isOfficialUpdate
                              ? "OfficialUpdate"
                              : "FeedPosts",
                        );
                      }
                    : null,
                tooltip: "Comments",
                style: transparentButtonStyle,
                icon: const LineIcon(
                  LineIcons.commentAlt,
                  size: 20,
                ),
              )
            : const Text(
                "0  💬",
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
        const SizedBox(
          width: 10,
        ),
        Transform.rotate(
          angle: -30 * pi / 180,
          child: IconButton(
            style: transparentButtonStyle,
            onPressed: widget.isAllowDM && !notVerified()
                ? () {
                    final List chatIDList = [];
                    chatIDList.add(
                      widget.postUserUID,
                    );
                    chatIDList.add(
                      widget.cUID,
                    );
                    chatIDList.sort();
                    final String chatID = "${chatIDList[0]}+${chatIDList[1]}";
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => ChatScreenPage(
                          chatID: chatID,
                          userDP: widget.userDP,
                          name: widget.fullName,
                          userName: widget.userName,
                          oppoUID: widget.postUserUID,
                          fcmToken: widget.fcmToken,
                          isNewMessage: false,
                          initialMessage:
                              "Hello! I'd like to discuss about your recent post: ${shareLink(widget.isOfficialUpdate, widget.shareID)}",
                        ),
                      ),
                    );
                  }
                : null,
            tooltip: widget.isAllowDM && !notVerified()
                ? "Direct Message"
                : "Direct Message has been disabled by the User",
            icon: const LineIcon(
              LineIcons.paperPlane,
              size: 20,
            ),
          ),
        ),
        Row(
          children: [
            const IconButton(
              onPressed: null,
              tooltip: "Views",
              style: transparentButtonStyle,
              icon: LineIcon(
                LineIcons.eye,
                size: 20,
              ),
            ),
            Text(
              formatLikes(
                widget.views,
              ),
            )
          ],
        ),
        shareLinkWidget(
          isText: false,
          shareID: widget.shareID,
          isOfficial: widget.isOfficialUpdate,
        )
      ],
    );
  }
}
