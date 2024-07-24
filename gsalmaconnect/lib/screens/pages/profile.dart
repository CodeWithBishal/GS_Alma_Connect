import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/backend/update_profile.dart';
import 'package:gsconnect/screens/chat/chat_screen.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/theme/whitelabel.dart';
import 'package:gsconnect/widgets/appbar.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:gsconnect/widgets/image_dialog.dart';
import 'package:gsconnect/widgets/loading.dart';
import 'package:gsconnect/widgets/pick_upload_image.dart';
import 'package:gsconnect/widgets/snacbar.dart';
import 'package:gsconnect/widgets/toast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:share_plus/share_plus.dart';

class MyProfile extends StatefulWidget {
  final bool isMyProfile;
  final String uid;
  const MyProfile({super.key, required this.isMyProfile, required this.uid});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController profileHeadlineEditingController =
      TextEditingController();
  final TextEditingController researchEditingController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();
  final String uidForMessage = FirebaseAuth.instance.currentUser!.uid;
  late User? user = FirebaseAuth.instance.currentUser;
  late String imagePath = "";
  late String extensionImg = "";
  late dynamic res;
  late String username;
  late String profileHeadline;
  late String enrollmentNo;
  late String enrollmentYear;
  late String branch;
  late String communityRole;
  late bool isVerified;
  late String researchBrief;

  //for fetch
  late String displayName;
  late String photoURL;
  late String oppoUID;
  late String fcmToken;
  late bool _isLoading = widget.isMyProfile ? false : true;

  @override
  void initState() {
    if (widget.isMyProfile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isHiveExist() && context.mounted) {
          checkHiveDatabase();
          customSnacBar(
            context,
            "Please try again after some time",
          );
          Navigator.pop(
            context,
          );
        }
      });

      user = FirebaseAuth.instance.currentUser;
      res = userHiveData.getAt(0);
      username = res?.userName.toString() ?? "";
      profileHeadline = res?.profileHeadline.toString() ?? "";
      enrollmentNo = res?.enrollmentNo.toString() ?? "";
      enrollmentYear = res?.enrollmentYear.toString() ?? "";
      branch = res?.branch.toString() ?? "";
      communityRole = res?.communityRole ?? "Student";
      isVerified = res?.isVerified ?? false;
      researchBrief = res?.researchBrief ?? "";
      if (researchBrief.isEmpty) {
        researchBrief =
            "Provide a concise overview of your previous research background.";
      }
    } else {
      fetchUserData();
    }
    super.initState();
  }

  void fetchUserData() async {
    final query = userDataRTDB.child(widget.uid).once();
    final data = await query;
    user = null;
    res = null;
    displayName = data.snapshot.child("fullname").value.toString();
    if (displayName == "null" && mounted) {
      customSnacBar(context, "User not Found");
      Navigator.pop(context);
      return;
    }
    username = data.snapshot.child("userName").value.toString();
    oppoUID = data.snapshot.child("UID").value.toString();
    photoURL = data.snapshot.child("imgURL").value.toString();
    profileHeadline = data.snapshot.child("profileHeadline").value.toString();
    enrollmentYear = data.snapshot.child("enrollmentYear").value.toString();
    branch = data.snapshot.child("branch").value.toString();
    fcmToken = data.snapshot.child("fcmToken").value.toString();
    isVerified = bool.parse(data.snapshot.child("isVerified").value.toString());
    communityRole = data.snapshot.child("communityRole").value.toString();
    researchBrief = data.snapshot.child("researchBrief").value.toString();
    setState(() {
      _isLoading = false;
    });
  }

  Future uploadAndUpdateDP() async {
    List imageData = await pickImage(
      isProfile: true,
    );
    if (imageData.isEmpty) return;
    imagePath = imageData[0];
    extensionImg = imageData[1];
    if (!imagePath.toString().contains("compress")) return;
    flutterToast("Uploading new Profile Picture...");

    final shouldContinue = await calculateFileLength(
      imagePath: imagePath,
      maxSize: 1,
    );
    if (!shouldContinue) return;

    //upload to firebase
    final String downloadURL = await imgURLfromFirebase(
      imgURLpath: imagePath,
      user: user,
      extensionImg: extensionImg,
      storageRef: userDPStorage.child(user!.uid),
      isProfile: true,
    );

    // update to firebase auth object
    await user!.updatePhotoURL(downloadURL);

    //Update userData
    final DatabaseReference userDatabaseEvent = userDataRTDB.child(user!.uid);
    await userDatabaseEvent.child("imgURL").set(downloadURL);

    //Update DP at PublicUserData
    final DatabaseReference publicEvents = publicUserDataRTDB.child(username);
    await publicEvents.child("imgURL").set(downloadURL);

    //List all posts by the user store the post id
    final postIDs =
        await feedPostsRTDB.orderByChild("UID").equalTo(user!.uid).once();

    final DatabaseReference feedPostEvents = feedPostsRTDB;

    if (postIDs.snapshot.value != null) {
      Map<dynamic, dynamic> values =
          postIDs.snapshot.value as Map<dynamic, dynamic>;

      //For each id, update the dp at feedpost
      final List idList = values.keys.toList();
      for (int i = 0; i < idList.length; i++) {
        await feedPostEvents.child(idList[i]).child("userPfp").set(downloadURL);
      }
    }

    //also delete hive and refresh
    deleteHiveAndRefetch();
    user = FirebaseAuth.instance.currentUser;
    flutterToast("Profile Image has been updated successfully.");
  }

  void handleHeadline(BuildContext context) {
    bool validate = formKey.currentState!.validate();
    if (validate) {
      updateProfileHeadline(
        user!.uid,
        profileHeadlineEditingController.text,
      ).then((value) {
        setState(() {
          profileHeadline = profileHeadlineEditingController.text;
        });
        flutterToast(
          "Profile Updated Successfully!",
        );
        deleteHiveAndRefetch();
      });
      Navigator.pop(context);
    }
  }

  void researchHandler(BuildContext context) {
    bool validate = formKey.currentState!.validate();
    if (validate) {
      updateResearchBrief(
        user!.uid,
        researchEditingController.text,
      ).then((value) {
        setState(() {
          researchBrief = researchEditingController.text;
        });
        flutterToast(
          "Profile Updated Successfully!",
        );
        deleteHiveAndRefetch();
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    TextFormField profileHeadlineEditor = TextFormField(
      controller: profileHeadlineEditingController,
      expands: false,
      autofocus: true,
      maxLength: 110,
      minLines: 3,
      maxLines: 4,
      focusNode: _focusNode,
      textInputAction: TextInputAction.done,
      style: const TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 15,
      ),
      onFieldSubmitted: (value) {
        handleHeadline(context);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Profile Headline can't be empty";
        } else if (value.length <= 10) {
          return "Profile Headline should contain atleast 10 characters";
        }
        return null;
      },
      keyboardType: TextInputType.name,
      decoration: const InputDecoration(
        labelText: "Write about yourself",
      ),
    );

    TextFormField researchHeadlineEditor = TextFormField(
      controller: researchEditingController,
      expands: false,
      autofocus: true,
      maxLength: 500,
      minLines: 3,
      maxLines: 4,
      focusNode: _focusNode,
      textInputAction: TextInputAction.done,
      style: const TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 15,
      ),
      onFieldSubmitted: (value) {
        researchHandler(context);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Profile Headline can't be empty";
        } else if (value.length <= 10) {
          return "Profile Headline should contain atleast 10 characters";
        }
        return null;
      },
      keyboardType: TextInputType.name,
      decoration: const InputDecoration(
        labelText: "Write about yourself",
      ),
    );

    Future btmSheetEditor(bool isHeadlinePro) async {
      await showModalBottomSheet(
        backgroundColor: ColorDefination.bgColor,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            double fHeight = height;
            if (isHeadlinePro) {
              fHeight = _focusNode.hasFocus ? height / 1.55 : height / 3.2;
            } else {
              fHeight = _focusNode.hasFocus ? height / 1.45 : height / 3;
            }
            return Form(
              key: formKey,
              child: SizedBox(
                width: width,
                height: fHeight,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: width - width / 15,
                      child: Text(
                        isHeadlinePro
                            ? "Profile Headline 👤"
                            : "Research Brief 🔬",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      width: width - width / 12,
                      child: Text(
                        isHeadlinePro
                            ? "Describe yourself in brief"
                            : "Provide a concise overview of your previous research background.",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          width: width - width / 15,
                          child: isHeadlinePro
                              ? profileHeadlineEditor
                              : researchHeadlineEditor,
                        ),
                        Positioned(
                          right: 7,
                          top: 5,
                          child: IconButton(
                            onPressed: isHeadlinePro
                                ? () {
                                    handleHeadline(context);
                                  }
                                : () {
                                    researchHandler(context);
                                  },
                            icon: const Icon(
                              Icons.check,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          });
        },
      );
    }

    return Scaffold(
      appBar: loggedInAppBar(
        context: context,
        isBack: true,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : ListView(
              children: [
                Container(
                  // height: height / 4.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        ColorDefination.secondaryColor,
                        ColorDefination.blue,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        widget.isMyProfile
                                            ? user!.displayName
                                                .toString()
                                                .toUpperCase()
                                            : displayName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      isVerified
                                          ? const Icon(
                                              Icons.verified,
                                              color: Colors.greenAccent,
                                            )
                                          : const SizedBox()
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  GestureDetector(
                                    onLongPress: () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text: username,
                                        ),
                                      ).then((value) {
                                        flutterToast(
                                          "Username copied to clipboard",
                                        );
                                      });
                                    },
                                    child: Text(
                                      "@$username",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ImageDialog(
                                      imgUrl: widget.isMyProfile
                                          ? user!.photoURL ?? ""
                                          : photoURL,
                                    ),
                                  ),
                                );
                              },
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 4,
                                          color: Colors.white,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            color:
                                                Colors.black.withOpacity(0.1),
                                          )
                                        ],
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircleAvatar(
                                        radius: width / 12,
                                        backgroundImage: NetworkImage(
                                          widget.isMyProfile
                                              ? user!.photoURL ?? ""
                                              : photoURL,
                                        ),
                                      ),
                                    ),
                                    widget.isMyProfile
                                        ? Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  width: 2.5,
                                                  color: Colors.white,
                                                ),
                                                color: ColorDefination.yellow,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  uploadAndUpdateDP()
                                                      .then((value) {
                                                    setState(() {});
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.edit,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        //if someone is visiting their profile only then
                        //They can update their profile
                        widget.isMyProfile
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: width / 1.3,
                                    child: Text(
                                      profileHeadline.isEmpty
                                          ? "Describe yourself in brief"
                                          : profileHeadline,
                                      textAlign: TextAlign.start,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    style: transparentButtonStyle,
                                    onPressed: () {
                                      btmSheetEditor(true).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 16,
                                    ),
                                  )
                                ],
                              )
                            : SizedBox(
                                width: width,
                                child: SizedBox(
                                  width: width / 1.3,
                                  child: Text(
                                    profileHeadline,
                                    textAlign: TextAlign.start,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(
                          height: 20,
                        ),
                        Stack(
                          children: [
                            widget.isMyProfile
                                ? Align(
                                    alignment: Alignment.topLeft,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            customSnacBar(
                                              context,
                                              "Coming Soon",
                                            );
                                          },
                                          child: const Text(
                                            "0 Followers",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            //TODO
                                            customSnacBar(
                                              context,
                                              "Coming Soon",
                                            );
                                          },
                                          child: const Text(
                                            "0 Following",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Align(
                                    alignment: Alignment.topLeft,
                                    child: Row(
                                      children: [
                                        TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                              ColorDefination.yellow,
                                            ),
                                          ),
                                          onPressed: () {
                                            customSnacBar(
                                              context,
                                              "Coming Soon",
                                            );
                                          },
                                          child: const Text("Follow"),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        TextButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                              ColorDefination.yellow,
                                            ),
                                          ),
                                          onPressed: () {
                                            final List tableName = [];
                                            tableName.add(uidForMessage);
                                            tableName.add(
                                              widget.uid,
                                            );
                                            tableName.sort();
                                            final String chatID =
                                                "${tableName[0]}+${tableName[1]}";
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) =>
                                                    ChatScreenPage(
                                                  chatID: chatID,
                                                  userDP: photoURL,
                                                  name: displayName,
                                                  userName: username,
                                                  oppoUID: oppoUID,
                                                  fcmToken: fcmToken,
                                                  isNewMessage: false,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text("Message"),
                                        )
                                      ],
                                    ),
                                  ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                style: transparentButtonStyle,
                                onPressed: () {
                                  final shareLink = "$domain@$username";
                                  Share.share(
                                    shareLink,
                                  );
                                },
                                icon: const Icon(
                                  Icons.share,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                widget.isMyProfile
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Personal Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // TextButton(
                            //   onPressed: () {},
                            //   child: const Text(
                            //     "EDIT",
                            //     style: TextStyle(
                            //         fontWeight: FontWeight.bold),
                            //   ),
                            // )
                          ],
                        ),
                      )
                    : const SizedBox(),
                widget.isMyProfile
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LineIcons.phone,
                                  size: 27,
                                  color: ColorDefination.blue,
                                ),
                                SizedBox(
                                  width: width / 30,
                                ),
                                Text(
                                  widget.isMyProfile
                                      ? user!.phoneNumber
                                          .toString()
                                          .replaceAll("+91", "+91-")
                                      : "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: ColorDefination.blue,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Icon(
                                  LineIcons.envelope,
                                  size: 27,
                                  color: ColorDefination.blue,
                                ),
                                SizedBox(
                                  width: width / 30,
                                ),
                                Text(
                                  widget.isMyProfile
                                      ? user!.email.toString()
                                      : "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: ColorDefination.blue,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
                widget.isMyProfile
                    ? const Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 10,
                          bottom: 0,
                        ),
                        child: Divider(),
                      )
                    : const SizedBox(),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Text(
                    "Academic Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                widget.isMyProfile
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.pin_outlined,
                              size: 27,
                              color: ColorDefination.blue,
                            ),
                            SizedBox(
                              width: width / 30,
                            ),
                            Text(
                              enrollmentNo,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: ColorDefination.blue,
                              ),
                            )
                          ],
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 27,
                        color: ColorDefination.blue,
                      ),
                      SizedBox(
                        width: width / 30,
                      ),
                      SizedBox(
                        width: width / 1.8,
                        child: Text(
                          branch,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorDefination.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        size: 27,
                        color: ColorDefination.blue,
                      ),
                      SizedBox(
                        width: width / 30,
                      ),
                      Text(
                        "$communityRole at SGSITS Since $enrollmentYear",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorDefination.blue,
                        ),
                      )
                    ],
                  ),
                ),

                //research bg
                researchBrief.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 10,
                              bottom: 0,
                            ),
                            child: Divider(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 0,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "Research Background",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                widget.isMyProfile
                                    ? TextButton(
                                        onPressed: () {
                                          btmSheetEditor(false).then((value) {
                                            setState(() {});
                                          });
                                        },
                                        child: const Text(
                                          "EDIT",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : const SizedBox()
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            child: Text(researchBrief),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      )
                    : const SizedBox()
              ],
            ),
    );
  }
}
