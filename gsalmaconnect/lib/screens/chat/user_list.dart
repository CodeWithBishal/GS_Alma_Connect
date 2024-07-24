import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/screens/chat/chat_screen.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/appbar.dart';
import 'package:gsconnect/widgets/badge.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:gsconnect/widgets/loading_messages.dart';

class ListOfUsersForMessaging extends StatefulWidget {
  const ListOfUsersForMessaging({super.key});

  @override
  State<ListOfUsersForMessaging> createState() =>
      _ListOfUsersForMessagingState();
}

class _ListOfUsersForMessagingState extends State<ListOfUsersForMessaging> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    publicUserDataRTDB.keepSynced(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: onlyleading(context: context),
        scrolledUnderElevation: 0.0,
        title: const Text(
          "Search & Message Users",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: RealtimeDBPagination(
        query: publicUserDataRTDB,
        limit: 11,
        orderBy: null,
        descending: true,
        isAllowDMCheck: true,
        initialLoader: const ListChatsLoader(),
        itemBuilder: (p0, snapShotData, p2) {
          if (snapShotData.child("isAllowDM").value == true &&
              snapShotData.child("UID").value != user!.uid &&
              snapShotData.child("isVerified").value == true) {
            final String role =
                snapShotData.child("communityRole").value.toString();
            return SizedBox(
              height: 100,
              child: Card(
                elevation: 0,
                color: ColorDefination.lightSecondaryColor,
                child: Center(
                  child: ListTile(
                    leading: ClipOval(
                      child: Image.network(
                        snapShotData.child("imgURL").value.toString(),
                      ),
                    ),
                    title: Text(
                      snapShotData.child("fullname").value.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: BadgeWidget(
                      communityRole: role,
                      text:
                          "@${snapShotData.child("UserName").value.toString()}",
                      textStyle: null,
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        final List tableName = [];
                        tableName.add(user!.uid);
                        tableName.add(
                          snapShotData.child("UID").value.toString(),
                        );
                        tableName.sort();
                        final String chatID = "${tableName[0]}+${tableName[1]}";
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ChatScreenPage(
                              chatID: chatID,
                              userDP:
                                  snapShotData.child("imgURL").value.toString(),
                              name: snapShotData
                                  .child("fullname")
                                  .value
                                  .toString(),
                              userName: snapShotData
                                  .child("UserName")
                                  .value
                                  .toString(),
                              oppoUID:
                                  snapShotData.child("UID").value.toString(),
                              fcmToken: snapShotData
                                  .child("fcmToken")
                                  .value
                                  .toString(),
                              isNewMessage: false,
                            ),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.message_outlined,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
