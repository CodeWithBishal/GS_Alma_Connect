import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/models/hive/hive_user.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/backend/update_profile.dart';
import 'package:gsconnect/screens/chat/chat_screen.dart';
import 'package:gsconnect/screens/chat/user_list.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/badge.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:gsconnect/widgets/encryptdecrypt.dart';
import 'package:gsconnect/widgets/loading_messages.dart';

class ChatPageWidget extends StatefulWidget {
  const ChatPageWidget({super.key});

  @override
  State<ChatPageWidget> createState() => _ChatPageWidgetState();
}

class _ChatPageWidgetState extends State<ChatPageWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  final UserProfileData? myUserInHive = userHiveData.getAt(0);
  @override
  void initState() {
    publicUserDataRTDB.keepSynced(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 10),
        child: FloatingActionButton(
          heroTag: "unique30",
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const ListOfUsersForMessaging(),
              ),
            );
          },
          backgroundColor: ColorDefination.yellow,
          child: const Icon(
            Icons.add_comment_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream: publicUserDataRTDB
                .child(myUserInHive!.userName)
                .child("conversationIDs")
                .onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListChatsLoader();
              } else if (snapshot.hasData &&
                  snapshot.data!.snapshot.value == null) {
                return const Center(
                  child: Text("No Recent Chats found"),
                );
              } else if (snapshot.hasData) {
                Map<dynamic, dynamic> userMessagesMap =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<dynamic> userMessageList = userMessagesMap.values.toList();
                userMessageList.sort(
                    (a, b) => b['lastTimeStamp'].compareTo(a['lastTimeStamp']));
                return ListView.builder(
                  itemCount: userMessageList.length,
                  padding: EdgeInsets.only(
                    top: height * 0.009,
                    bottom: kBottomNavigationBarHeight + 10,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    String getOpponentUID = userMessageList[index]["chatID"]
                        .toString()
                        .replaceAll(user!.uid, "")
                        .replaceAll("+", "");
                    return FutureBuilder(
                      future: publicUserDataRTDB
                          .orderByChild("UID")
                          .equalTo(getOpponentUID)
                          .once(),
                      builder: (context, futureSnap) {
                        if (futureSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        } else if (futureSnap.hasData &&
                            futureSnap.data != null) {
                          //Opponent Data
                          final profileData =
                              futureSnap.data!.snapshot.children.first;
                          final String communityRole = profileData
                              .child("communityRole")
                              .value
                              .toString();
                          return Card(
                            elevation: 0,
                            margin:
                                EdgeInsets.symmetric(vertical: width * 0.005),
                            color: ColorDefination.blueBg,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ChatScreenPage(
                                      chatID: userMessageList[index]["chatID"],
                                      userDP: profileData
                                          .child("imgURL")
                                          .value
                                          .toString(),
                                      name: profileData
                                          .child("fullname")
                                          .value
                                          .toString(),
                                      userName: profileData
                                          .child("UserName")
                                          .value
                                          .toString(),
                                      oppoUID: getOpponentUID,
                                      fcmToken: profileData
                                          .child("fcmToken")
                                          .value
                                          .toString(),
                                      isNewMessage: userMessageList[index]
                                          ["isNewMessage"],
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                tileColor: ColorDefination.blueBg,
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    profileData
                                        .child("imgURL")
                                        .value
                                        .toString(),
                                  ),
                                ),
                                title: BadgeWidget(
                                  communityRole: communityRole,
                                  text: profileData
                                      .child("fullname")
                                      .value
                                      .toString(),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  EncryptDecrypt.decrypt(userMessageList[index]
                                          ["lastMessage"]
                                      .toString()),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: userMessageList[index]
                                            ["isNewMessage"] ==
                                        true
                                    ? const Badge(
                                        backgroundColor: Colors.green,
                                        label: Text("New"),
                                      )
                                    : Text(
                                        getFormattedDate(
                                          userMessageList[index]
                                                  ["lastTimeStamp"]
                                              .toString(),
                                        ),
                                      ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text("No Recent Chats found"),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
