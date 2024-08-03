import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/models/user.dart';
import 'package:gsconnect/screens/backend/update_profile.dart';
import 'package:gsconnect/screens/chat/chat_screen.dart';
import 'package:gsconnect/screens/pages/homepage.dart';
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
  final TextEditingController professionalEditingController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();
  final String uidForMessage = FirebaseAuth.instance.currentUser!.uid;
  late User? user = FirebaseAuth.instance.currentUser;
  UserModel userModel = UserModel(
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
    passYear: "",
    profileHeadline: "",
    professionalBrief: "",
    course: "",
    otherData: [],
    fcmToken: "",
    isAllowDM: false,
  );
  late double _keyboardHeight = 0;
  late String imagePath = "";
  late String extensionImg = "";
  late dynamic res;

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

      userModel.userName = res?.userName.toString() ?? "";
      userModel.profileHeadline = res?.profileHeadline.toString() ?? "";
      userModel.enrollmentNo = res?.enrollmentNo.toString() ?? "";
      userModel.enrollmentYear = res?.enrollmentYear.toString() ?? "";
      userModel.branch = res?.branch.toString() ?? "";
      userModel.communityRole = res?.communityRole ?? "Student";
      userModel.isVerified = res?.isVerified ?? false;
      userModel.professionalBrief = res?.professionalBrief ?? "";
      if (userModel.professionalBrief.isEmpty) {
        userModel.professionalBrief =
            "Provide a concise overview of your professional journey.";
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
    userModel.fullname = data.snapshot.child("fullname").value.toString();
    if (userModel.fullname == "null" && mounted) {
      customSnacBar(context, "User not Found");
      Navigator.pop(context);
      return;
    }
    userModel.userName = data.snapshot.child("userName").value.toString();
    userModel.uid = data.snapshot.child("UID").value.toString();
    userModel.imgURL = data.snapshot.child("imgURL").value.toString();
    userModel.profileHeadline =
        data.snapshot.child("profileHeadline").value.toString();
    userModel.enrollmentYear =
        data.snapshot.child("enrollmentYear").value.toString();
    userModel.branch = data.snapshot.child("branch").value.toString();
    userModel.fcmToken = data.snapshot.child("fcmToken").value.toString();
    userModel.isVerified =
        bool.parse(data.snapshot.child("isVerified").value.toString());
    userModel.communityRole =
        data.snapshot.child("communityRole").value.toString();
    userModel.professionalBrief =
        data.snapshot.child("professionalBrief").value.toString();
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
    final DatabaseReference publicEvents =
        publicUserDataRTDB.child(userModel.userName);
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
          userModel.profileHeadline = profileHeadlineEditingController.text;
        });
        flutterToast(
          "Profile Updated Successfully!",
        );
        deleteHiveAndRefetch();
      });
      Navigator.pop(context);
    }
  }

  void professionalHandler(BuildContext context) {
    bool validate = formKey.currentState!.validate();
    if (validate) {
      updateprofessionalBrief(
        user!.uid,
        professionalEditingController.text,
      ).then((value) {
        setState(() {
          userModel.professionalBrief = professionalEditingController.text;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if (keyboardHeight != _keyboardHeight) {
        setState(() {
          _keyboardHeight = keyboardHeight;
          if (_keyboardHeight == 0) {
            Navigator.of(context).pop();
          }
        });
      }
    });
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

    TextFormField professionalHeadlineEditor = TextFormField(
      controller: professionalEditingController,
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
        professionalHandler(context);
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
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            // if (keyboardHeight == 0) {
            //   Navigator.pop(context);
            // }
            return Form(
              key: formKey,
              child: SizedBox(
                width: width,
                height: height - keyboardHeight,
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
                            : "Professional Summary 🔬",
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
                            : "Provide a concise overview of your professional journey.",
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
                              : professionalHeadlineEditor,
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
                                    professionalHandler(context);
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
                                            : userModel.fullname,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      userModel.isVerified
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
                                          text: userModel.userName,
                                        ),
                                      ).then((value) {
                                        flutterToast(
                                          "Username copied to clipboard",
                                        );
                                      });
                                    },
                                    child: Text(
                                      "@${userModel.userName}",
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
                                          : userModel.imgURL,
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
                                              : userModel.imgURL,
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
                                      userModel.profileHeadline.isEmpty
                                          ? "Describe yourself in brief"
                                          : userModel.profileHeadline,
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
                                    userModel.profileHeadline,
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
                                                  userDP: userModel.imgURL,
                                                  name: userModel.fullname,
                                                  userName: userModel.userName,
                                                  oppoUID: userModel.uid,
                                                  fcmToken: userModel.fcmToken,
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
                                  final shareLink =
                                      "$domain@${userModel.userName}";
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "Academic Details",
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
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
                widget.isMyProfile &&
                        userModel.enrollmentNo.isEmpty &&
                        userModel.branch.isEmpty &&
                        userModel.enrollmentYear.isEmpty &&
                        userModel.passYear.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Text(
                          "Provide a concise overview of your academic background",
                        ),
                      )
                    : const SizedBox(),
                widget.isMyProfile && userModel.enrollmentNo.isNotEmpty
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
                              userModel.enrollmentNo,
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
                widget.isMyProfile && userModel.branch.isNotEmpty
                    ? Padding(
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
                                userModel.branch,
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
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 10,
                ),
                widget.isMyProfile &&
                        userModel.enrollmentYear.isNotEmpty &&
                        userModel.passYear.isNotEmpty
                    ? Padding(
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
                              "${userModel.communityRole} at SGSITS From ${userModel.enrollmentYear} till ${userModel.passYear}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorDefination.blue,
                              ),
                            )
                          ],
                        ),
                      )
                    : const SizedBox(),

                //professional bg
                userModel.professionalBrief.isNotEmpty
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
                                  "Professional Summary",
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
                            child: Text(userModel.professionalBrief),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  // width: width - width / 125,
                  height: height / 15,
                  child: TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      enableFeedback: false,
                      backgroundColor:
                          WidgetStateProperty.all(const Color(0XFF064A98)),
                      overlayColor: WidgetStateProperty.all(Colors.white12),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                    child: const Text(
                      "Verify ✅",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
