import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/models/chat_model.dart';
import 'package:gsconnect/models/hive/hive_user.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/backend/notification.dart';
import 'package:gsconnect/screens/backend/update_profile.dart';
import 'package:gsconnect/screens/chat/chat_bubble.dart';
import 'package:gsconnect/screens/pages/profile.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/appbar.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:gsconnect/widgets/encryptdecrypt.dart';
import 'package:gsconnect/widgets/loading_messages.dart';
import 'package:gsconnect/widgets/pick_upload_image.dart';

class ChatScreenPage extends StatefulWidget {
  final String chatID;
  final String userDP;
  final String name;
  final String userName;
  final String oppoUID;
  final String fcmToken;
  final bool isNewMessage;
  final String? initialMessage;
  const ChatScreenPage({
    super.key,
    required this.chatID,
    required this.userDP,
    required this.name,
    required this.userName,
    required this.oppoUID,
    required this.fcmToken,
    required this.isNewMessage,
    this.initialMessage,
  });

  @override
  State<ChatScreenPage> createState() => _ChatScreenPageState();
}

class _ChatScreenPageState extends State<ChatScreenPage>
    with WidgetsBindingObserver {
  late bool isFirstMessage = false;
  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final ScrollController scrollController = ScrollController();
  late String imagePath = "";
  late String extensionImg = "";
  late String downloadURL = "";
  // late bool hasSeenMessage = false;
  ValueNotifier<bool> hasSeenMessage = ValueNotifier(false);
  // late EdgeInsets viewpadding = EdgeInsets.zero;
  ValueNotifier<EdgeInsets> viewPadding = ValueNotifier(EdgeInsets.zero);
  ValueNotifier<bool> sendBtnActive = ValueNotifier(true);
  ValueNotifier<bool> focusNodeHasFocus = ValueNotifier(true);
  User? currentUSER = FirebaseAuth.instance.currentUser;
  final UserProfileData? myCurrentHive = userHiveData.getAt(0);
  //used to check if new data is pushed
  late String lastMsgTimestamp = "";

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        focusNode.unfocus();
        viewPadding.value = EdgeInsets.zero;
        focusNodeHasFocus.value = focusNode.hasFocus;
        break;
      case AppLifecycleState.inactive:
        focusNode.unfocus();
        viewPadding.value = EdgeInsets.zero;
        focusNodeHasFocus.value = focusNode.hasFocus;
        break;
      case AppLifecycleState.paused:
        focusNode.unfocus();
        viewPadding.value = EdgeInsets.zero;
        focusNodeHasFocus.value = focusNode.hasFocus;
        break;
      case AppLifecycleState.detached:
        focusNode.unfocus();
        viewPadding.value = EdgeInsets.zero;
        focusNodeHasFocus.value = focusNode.hasFocus;
        break;
      case AppLifecycleState.hidden:
        focusNode.unfocus();
        viewPadding.value = EdgeInsets.zero;
        focusNodeHasFocus.value = focusNode.hasFocus;
        break;
    }
  }

  @override
  void initState() {
    if (scrollController.hasClients) {
      _scrollToBottom();
    }
    chatDataRTDB.keepSynced(true);
    if (widget.isNewMessage) {
      publicUserDataRTDB
          .child(myCurrentHive!.userName)
          .child("conversationIDs")
          .child(widget.chatID)
          .child("isNewMessage")
          .set(false);
    }
    // if opponent isNewMessage is false
    // User has seen the message
    publicUserDataRTDB
        .child(widget.userName)
        .child("conversationIDs")
        .child(widget.chatID)
        .child("isNewMessage")
        .onValue
        .listen((event) {
      late String seen = event.snapshot.value.toString();
      hasSeenMessage.value = bool.tryParse(seen) ?? true;
      hasSeenMessage.value = !(hasSeenMessage.value);
    });
    if (widget.initialMessage != null) {
      setState(() {
        messageController.text = widget.initialMessage ?? "";
      });
    }
    focusNode.addListener(() {
      focusNodeHasFocus.value = focusNode.hasFocus;
      // print(focusNode.hasFocus);
      // print(MediaQuery.viewInsetsOf(context));
    });
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  String viewPhoto() {
    return " ▶️   Photo ";
  }

  void handleImageBTN() async {
    if (focusNode.hasFocus) {
      focusNodeHasFocus.value = false;
      focusNode.unfocus();
    }
    final imageData = await pickImage(
      isProfile: false,
    );
    if (imageData.isEmpty) return;
    final bool shouldContinue = await calculateFileLength(
      imagePath: imageData[0],
      maxSize: 5,
    );
    if (!shouldContinue) return;
    setState(() {
      imagePath = imageData[0];
      extensionImg = imageData[1];
      messageController.text = viewPhoto();
    });
  }

  void sendNotification(String message, String name, String msgType) {
    if (widget.fcmToken.isEmpty) return;
    MessagingServices.sendNotification(
      toID: widget.fcmToken,
      name: name,
      body: msgType == "text" ? message : viewPhoto(),
      commRole: myCurrentHive!.communityRole,
    );
  }

  void storeConvoIDs(
      User? currentUSER,
      Messages messages,
      ChatForUIModel chatForUIModelForOppo,
      ChatForUIModel chatForUIModelForME,
      String fullname) async {
    await publicUserDataRTDB
        .child(myCurrentHive!.userName)
        .child("conversationIDs")
        .child(widget.chatID)
        .set(chatForUIModelForME.toMap());
    // also update for other user
    await publicUserDataRTDB
        .child(widget.userName)
        .child("conversationIDs")
        .child(widget.chatID)
        .set(chatForUIModelForOppo.toMap());
    pushMessage(messages);
    sendNotification(
      EncryptDecrypt.decrypt(chatForUIModelForOppo.lastMessage),
      fullname,
      messages.messageType,
    );
  }

  void pushMessage(Messages messages) async {
    await chatDataRTDB.push().set(messages.toMap());
  }

  void _scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future _handleSendBtn(User? currentUSER) async {
    // userProfileData.delete();
    if (_formKey.currentState!.validate()) {
      ChatForUIModel chatForUIModelForOppo = ChatForUIModel(
        chatID: widget.chatID,
        lastTimeStamp: getTimeStamp(),
        lastMessage: imagePath.isEmpty
            ? EncryptDecrypt.encrypt(messageController.text)
            : EncryptDecrypt.encrypt(viewPhoto()),
        isNewMessage: true,
        senderID: currentUSER!.uid,
        isConversationActive: true,
      );
      // For me no new message
      ChatForUIModel chatForUIModelForME = ChatForUIModel(
        chatID: widget.chatID,
        lastTimeStamp: getTimeStamp(),
        lastMessage: imagePath.isEmpty
            ? EncryptDecrypt.encrypt(messageController.text)
            : EncryptDecrypt.encrypt(viewPhoto()),
        isNewMessage: false,
        senderID: currentUSER.uid,
        isConversationActive: true,
      );
      if (imagePath.isNotEmpty) {
        downloadURL = await imgURLfromFirebase(
          imgURLpath: imagePath,
          extensionImg: extensionImg,
          user: currentUSER,
          isProfile: false,
          storageRef: chatImageDataStorage
              .child(
                widget.chatID,
              )
              .child(
                "${getTimeStamp()}$extensionImg",
              ),
        );
      }
      Messages messages = Messages(
        message: imagePath.isEmpty
            ? EncryptDecrypt.encrypt(messageController.text)
            : EncryptDecrypt.encrypt(downloadURL),
        timeStamp: getTimeStamp(),
        uid: currentUSER.uid,
        chatID: widget.chatID,
        messageType: imagePath.isEmpty ? "text" : "image",
      );

      storeConvoIDs(
        currentUSER,
        messages,
        chatForUIModelForOppo,
        chatForUIModelForME,
        currentUSER.displayName.toString(),
      );
      // No matter what after all database entries scroll to bottom
      if (scrollController.hasClients) {
        _scrollToBottom();
      }
      messageController.clear();
      if (imagePath.isNotEmpty) {
        setState(() {
          imagePath = "";
          extensionImg = "";
        });
      }
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    focusNode.dispose();
    hasSeenMessage.dispose();
    viewPadding.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    Query query = chatDataRTDB.orderByChild("chatID").equalTo(widget.chatID);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorDefination.bgColor,
        scrolledUnderElevation: 0.0,
        leading: onlyleading(context: context),
        titleSpacing: -10,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => MyProfile(
                  isMyProfile: false,
                  uid: widget.oppoUID,
                ),
              ),
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.userDP),
            ),
            title: Text(
              widget.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "@${widget.userName}",
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: ColorDefination.secondaryColor,
            height: 4.0,
          ),
        ),
      ),
      bottomNavigationBar: widget.oppoUID == currentUSER!.uid
          ? null
          : ValueListenableBuilder(
              valueListenable: viewPadding,
              builder: (context, value, child) {
                viewPadding.value = focusNodeHasFocus.value
                    ? MediaQuery.of(context).viewInsets
                    : EdgeInsets.zero;
                return Padding(
                  padding: value,
                  child: messsageField(width, currentUSER),
                );
              },
            ),
      body: StreamBuilder(
        stream: query.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const PlaceHolderListMessage();
          } else if (snapshot.hasData &&
              snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> messagesMap =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<dynamic> messageList = messagesMap.values.toList();
            messageList
                .sort((a, b) => a['timeStamp'].compareTo(b['timeStamp']));
            if (lastMsgTimestamp != messageList.last["timeStamp"]) {
              lastMsgTimestamp = messageList.last["timeStamp"];
              publicUserDataRTDB
                  .child(myCurrentHive!.userName)
                  .child("conversationIDs")
                  .child(widget.chatID)
                  .child("isNewMessage")
                  .set(false);
            }
            return ListView.builder(
              reverse: true,
              shrinkWrap: true,
              controller: scrollController,
              itemCount: messageList.length,
              itemBuilder: (context, index) {
                final indexx = messageList.length - 1 - index;
                Messages messages = Messages(
                  chatID: widget.chatID,
                  message:
                      EncryptDecrypt.decrypt(messageList[indexx]["message"]),
                  timeStamp: messageList[indexx]["timeStamp"],
                  uid: messageList[indexx]["uid"],
                  messageType: messageList[indexx]["messageType"],
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MessageBubble(
                      isNotMe: messageList[indexx]["uid"] != currentUSER!.uid,
                      isImage: messageList[indexx]["messageType"] == "image",
                      message: messages,
                      isLastMessage:
                          index + messageList.length == messageList.length,
                    ),
                    ValueListenableBuilder(
                      valueListenable: hasSeenMessage,
                      builder: (context, value, child) {
                        if (hasSeenMessage.value &&
                            (index + messageList.length == messageList.length &&
                                messageList[indexx]["uid"] ==
                                    currentUSER!.uid)) {
                          return const Padding(
                            padding: EdgeInsets.only(
                              right: 10,
                              left: 0,
                            ),
                            child: Text(
                              "Seen",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    )
                  ],
                );
              },
            );
          } else if (snapshot.hasError) {
            return SizedBox(
              height: height - kToolbarHeight - 30,
              width: width,
              child: const Center(
                child: Text(
                  "Something went terribly wrong, Please try again later",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            return SizedBox(
              height: height - kToolbarHeight - 30,
              width: width,
              child: Center(
                child: Text(
                  widget.oppoUID == currentUSER!.uid
                      ? "You cannot send messages to yourself."
                      : "No recent chat found with ${widget.name}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget messsageField(width, currentUSER) {
    return Container(
      color: ColorDefination.bgColor,
      padding: const EdgeInsets.all(8),
      width: width,
      // height: height,
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            SizedBox(
              width: width * 0.68,
              child: TextFormField(
                controller: messageController,
                expands: false,
                focusNode: focusNode,
                readOnly: imagePath.isNotEmpty ? true : false,
                minLines: 1,
                maxLines: 5,
                autofocus: false,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return ("Please Enter a valid Message");
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: "Message",
                  // prefixIcon: Icon(
                  //   Icons.message_outlined,
                  // ),
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ValueListenableBuilder(
              valueListenable: sendBtnActive,
              builder: (context, sendBtnActiveVal, child) {
                return IconButton(
                  onPressed: sendBtnActiveVal
                      ? imagePath.isEmpty
                          ? () {
                              handleImageBTN();
                            }
                          : () {
                              setState(() {
                                imagePath = "";
                                extensionImg = "";
                              });
                              messageController.clear();
                            }
                      : null,
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      ColorDefination.blue,
                    ),
                  ),
                  icon: CircleAvatar(
                    backgroundColor: ColorDefination.blue,
                    radius: 12,
                    child: Icon(
                      imagePath.isEmpty
                          ? Icons.image_outlined
                          : Icons.delete_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(
              width: 5,
            ),
            ValueListenableBuilder(
              valueListenable: sendBtnActive,
              builder: (context, sendBtnActiveVal, child) {
                return IconButton(
                  onPressed: sendBtnActiveVal
                      ? imagePath.isEmpty
                          ? () {
                              _handleSendBtn(currentUSER);
                            }
                          : () async {
                              sendBtnActive.value = false;
                              await _handleSendBtn(currentUSER);
                              sendBtnActive.value = true;
                            }
                      : null,
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      ColorDefination.blue,
                    ),
                  ),
                  icon: sendBtnActiveVal
                      ? CircleAvatar(
                          backgroundColor: ColorDefination.blue,
                          radius: 12,
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      : Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
