import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/models/posts.dart';
import 'package:gsconnect/screens/auth/redirect.dart';
import 'package:gsconnect/screens/backend/update_profile.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/theme/whitelabel.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:gsconnect/widgets/internet.dart';
import 'package:gsconnect/widgets/pick_upload_image.dart';
import 'package:gsconnect/widgets/appbar.dart';
import 'package:gsconnect/widgets/loading.dart';
import 'package:gsconnect/widgets/record_error.dart';
import 'package:gsconnect/widgets/snacbar.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:flutter/material.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  late bool _isLoading = true;
  late bool isDM = true;
  final cUserUID = userHiveData.getAt(0)!;
  late bool contentError = false;
  late bool linkError = false;
  late String error = "";
  final formKey = GlobalKey<FormState>();
  final linkEditingController = TextEditingController();
  final contentEditingController = TextEditingController();
  // final tagEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isKeyboardOpen = true;
  bool isBottomSheetOpen = false;
  late double _distanceToField;
  final TextfieldTagsController _controller = TextfieldTagsController();
  late List initialList = [];
  late String imagePath = "";
  late String extensionImg = "";
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void initState() {
    super.initState();
    handleVerify(context).then((value) {
      if (value != _isLoading) {
        setState(() {
          _isLoading = value;
        });
      }
    });
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && isBottomSheetOpen) {
        Navigator.pop(context);
      }
    });
  }

  _handlePost(BuildContext context) async {
    bool isInternet = await CheckForInternet.checkForInternet(context);
    if (!isInternet) return;
    final Uri? parsedUri = Uri.tryParse(linkEditingController.text);
    final bool isValidLink = linkEditingController.text.isNotEmpty
        ? parsedUri != null && parsedUri.isAbsolute
        : true;
    if (formKey.currentState!.validate() &&
        contentEditingController.text != "" &&
        isValidLink) {
      setState(() {
        _isLoading = true;
      });
      initialList.sort();
      addNoOfPostVal(cUserUID.uid);
      handleModalData(
        contentEditingController.text.trimRight().trimLeft(),
        imagePath,
        linkEditingController.text,
        isDM,
        initialList,
        extensionImg,
      ).then((value) {
        if (context.mounted) {
          setState(() {
            _isLoading = false;
          });
          customSnacBar(
            context,
            "New Post has been Uploaded Successfully",
          );
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const RedirectUser(),
              ),
              (route) => false);
        }
      });
    } else if (!isValidLink) {
      setState(() {
        error = "Invalid Link";
        linkError = false;
        contentError = true;
      });
      if (!context.mounted) return;
      Navigator.pop(context);
    } else {
      setState(() {
        error = "Content Can't be Empty";
        contentError = true;
        linkError = false;
      });
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  _showDisclaimer(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    late bool isExpand = false;
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ListView(
              shrinkWrap: true,
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          IconButton(
                            style: transparentButtonStyle,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.cancel_outlined),
                          ),
                          SizedBox(
                            width: 0.70 * width,
                            child: Text(
                              "Disclaimer",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                color: ColorDefination.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Image.asset("assets/logo/rules.jpg"),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "Please review the guidelines prior to posting your content. Failure to adhere to our posting criteria may result in the removal of your content or the initiation of serious disciplinary measures.",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                isExpand = !isExpand;
                              });
                            },
                            style: transparentButtonStyle,
                            label: !isExpand
                                ? const Icon(Icons.arrow_right)
                                : const Icon(Icons.arrow_drop_down_outlined),
                            icon: const Text("RULES"),
                          ),
                        ),
                      ),
                      isExpand
                          ? const Padding(
                              padding: EdgeInsets.all(13.0),
                              child: Column(
                                children: [
                                  Text(
                                    "1. Treat others with kindness, empathy, and respect at all times.",
                                  ),
                                  Text(
                                    "2. No bullying: Do not engage in any form of bullying, harassment, or intimidation towards others.",
                                  ),
                                  Text(
                                    "3. No hate speech: Avoid using offensive language, slurs, or discriminatory remarks targeting individuals or groups.",
                                  ),
                                  Text(
                                    "4. Stay constructive: Offer feedback and suggestions in a constructive manner, focusing on the code or ideas being discussed.",
                                  ),
                                  Text(
                                    "5. No spamming or self-promotion: Refrain from excessive self-promotion or sharing irrelevant content in the community.",
                                  ),
                                  Text(
                                    "6. Keep discussions on-topic: Stick to research or institute related discussions and avoid unrelated or off-topic conversations.",
                                  ),
                                  Text(
                                    "7. No plagiarism: Respect intellectual property rights and refrain from plagiarizing content or claiming others' work as your own.",
                                  ),
                                  Text(
                                    "8. Explicit Content: Explicit content is defined as adult, 'NSFW', or graphic content. Posting or sharing any explicit content in the community will be met with a punishment.",
                                  ),
                                  Text(
                                    "9. Controversial Content in this community is defined as content that can spark outrage, arguments, or heavy disagreement among members and is strictly prohibited.",
                                  ),
                                  Text(
                                    "10. Report incidents: Promptly report any instances of abuse, bullying, or inappropriate behavior to the moderators or administrators.",
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            ColorDefination.blueBg,
                          ),
                        ),
                        onPressed: () {
                          _handlePost(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(
                            "Continue   ➤",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  Future handleModalData(String message, String imgURL, String extURL,
      bool isAllowDM, List tags, String extension) async {
    if (userHiveData.getAt(0)!.uid != "" ||
        userHiveData.getAt(0)!.uid.isNotEmpty) {
      String postID = DateTime.now().millisecondsSinceEpoch.toString();
      String subFirstFourID = postID.substring(0, 4);
      String subLastFourID = postID.substring(postID.length - 6, postID.length);
      String downloadImgURL = "";
      if (imgURL != "") {
        downloadImgURL = await imgURLfromFirebase(
          imgURLpath: imgURL,
          extensionImg: extensionImg,
          user: user,
          isProfile: false,
          storageRef: feedPostsStorage.child(
            postID + extension,
          ),
        );
      }
      PostModel postModel = PostModel(
        id: postID,
        sharedID: subLastFourID + subFirstFourID,
        uid: cUserUID.uid,
        message: message,
        likes: ["aacd"],
        imgURL: downloadImgURL,
        extURL: extURL,
        dateTime: getCurrentDateTime(),
        isAllowDM: isAllowDM,
        isHidden: false,
        isReported: [],
        views: 0,
        userName: cUserUID.userName,
        userPfp: cUserUID.imgURL,
        name: cUserUID.fullname,
        tags: tags,
        communityRole: cUserUID.communityRole,
        fcmToken: cUserUID.fcmToken,
      );

      await feedPostsRTDB
          .child(postID)
          .set(
            postModel.toMap(),
          )
          .onError(
        (error, stackTrace) {
          recordError(
            error.toString(),
            "handleModalData",
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    TextField content = TextField(
      controller: contentEditingController,
      keyboardType: TextInputType.multiline,
      textAlignVertical: TextAlignVertical.top,
      autofocus: true,
      maxLines: null,
      minLines: 11,
      maxLength: 1000,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: "What would you like to share today?",
        errorText: contentError
            ? error
            : (linkError ? "Content Can't be Empty" : null),
      ),
    );
    TextFormField link = TextFormField(
      controller: linkEditingController,
      expands: false,
      autofocus: true,
      focusNode: _focusNode,
      textInputAction: TextInputAction.done,
      style: const TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 15,
      ),
      validator: (value) {
        RegExp regex = RegExp(r'^(https):\/\/[^\s\/$.?#].[^\s]*$');
        if (value == null || value.isEmpty || value == " ") {
          return null;
        } else if (!regex.hasMatch(value)) {
          return ("Enter a valid https link");
        }
        return null;
      },
      keyboardType: TextInputType.name,
      decoration: const InputDecoration(
        labelText: "Link",
        prefixIcon: Icon(
          LineIcons.link,
        ),
      ),
    );

    Widget tagfield = TextFieldTags(
      textfieldTagsController: _controller,
      validator: (tag) {
        if (_controller.getTags!.contains(tag)) {
          return 'Already entered';
        } else if (_controller.getTags!.length > 5) {
          return 'Maximum of 5 tags are allowed';
        }
        return null;
      },
      initialTags: initialList,
      textSeparators: const [' ', ','],
      letterCase: LetterCase.normal,
      inputFieldBuilder: (context, inputFieldValues) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            onTap: () {
              _controller.getFocusNode?.requestFocus();
            },
            controller: inputFieldValues.textEditingController,
            focusNode: inputFieldValues.focusNode,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 74, 137, 92),
                  width: 3.0,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 74, 137, 92),
                  width: 3.0,
                ),
              ),
              helperText: 'Enter language...',
              helperStyle: const TextStyle(
                color: Color.fromARGB(255, 74, 137, 92),
              ),
              hintText: inputFieldValues.tags.isNotEmpty ? '' : "Enter tag...",
              errorText: inputFieldValues.error,
              prefixIconConstraints:
                  BoxConstraints(maxWidth: _distanceToField * 0.8),
              prefixIcon: inputFieldValues.tags.isNotEmpty
                  ? SingleChildScrollView(
                      controller: inputFieldValues.tagScrollController,
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                          left: 8,
                        ),
                        child: Wrap(
                            runSpacing: 4.0,
                            spacing: 4.0,
                            children: inputFieldValues.tags.map((dynamic tag) {
                              return Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                  color: Color.fromARGB(255, 74, 137, 92),
                                ),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      child: Text(
                                        '#$tag',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      onTap: () {
                                        //print("$tag selected");
                                      },
                                    ),
                                    const SizedBox(width: 4.0),
                                    InkWell(
                                      child: const Icon(
                                        Icons.cancel,
                                        size: 14.0,
                                        color:
                                            Color.fromARGB(255, 233, 233, 233),
                                      ),
                                      onTap: () {
                                        inputFieldValues.onTagRemoved(tag);
                                      },
                                    )
                                  ],
                                ),
                              );
                            }).toList()),
                      ),
                    )
                  : null,
            ),
            onChanged: inputFieldValues.onTagChanged,
            onSubmitted: inputFieldValues.onTagSubmitted,
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.0,
        actions: [
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: backBtn(context: context),
              ),
              const Text(
                "Share a Post",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        _showDisclaimer(context);
                      },
                child: const Text(
                  "POST",
                ),
              ),
            ],
          ))
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: dp(null, user),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Text(
                        user!.displayName.toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                linkEditingController.text.isNotEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          width: width - width / 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            color: ColorDefination.blueBg,
                          ),
                          child: Text(
                            linkEditingController.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: SizedBox(
                    height: initialList.isEmpty ? 0 : height / 20,
                    width: width - width / 12,
                    child: ListView.builder(
                      itemCount: initialList.length,
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
                                initialList[index],
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
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: formKey,
                      child: ListView(
                        children: [
                          Stack(
                            children: [
                              content,
                              Positioned(
                                bottom: 30,
                                left: 5,
                                child: IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      isBottomSheetOpen = true;
                                    });
                                    await showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor:
                                            ColorDefination.bgColor,
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom,
                                              ),
                                              child: SizedBox(
                                                width: width,
                                                height: height / 4,
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    SizedBox(
                                                      width: width - width / 15,
                                                      child: const Text(
                                                        "Add Link 🔗",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    SizedBox(
                                                      width: width - width / 15,
                                                      child: link,
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                        }).then((value) {
                                      setState(() {
                                        isBottomSheetOpen = false;
                                      });
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.link,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                left: 55,
                                child: IconButton(
                                  onPressed: () async {
                                    final imageData = await pickImage(
                                      isProfile: false,
                                    );
                                    if (imageData.isEmpty) return;
                                    final shouldContinue =
                                        await calculateFileLength(
                                      imagePath: imageData[0],
                                      maxSize: 10,
                                    );
                                    if (!shouldContinue) return;
                                    setState(() {
                                      imagePath = imageData[0];
                                      extensionImg = imageData[1];
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.add_a_photo_outlined,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                left: 105,
                                child: IconButton(
                                  onPressed: () async {
                                    // setState(() {
                                    //   _focusNode.unfocus();
                                    // });
                                    await showModalBottomSheet(
                                      backgroundColor: ColorDefination.bgColor,
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                            builder: (context, setState) {
                                          return SizedBox(
                                            width: width,
                                            height: height / 3,
                                            child: Column(
                                              children: [
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                const Text(
                                                  "Who can Direct Message?",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                SizedBox(
                                                  width: width - width / 12,
                                                  child: const Text(
                                                    "Choose if people can direct message you through this post.",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black45,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        horizontalTitleGap: 0,
                                                        onTap: () {
                                                          setState(() {
                                                            isDM = true;
                                                          });
                                                        },
                                                        splashColor:
                                                            Colors.transparent,
                                                        title: const Text(
                                                          'Yes',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        leading: Radio(
                                                          value: true,
                                                          activeColor:
                                                              ColorDefination
                                                                  .blue,
                                                          groupValue: isDM,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              isDM = value!;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: ListTile(
                                                          horizontalTitleGap: 0,
                                                          onTap: () {
                                                            setState(() {
                                                              isDM = false;
                                                            });
                                                          },
                                                          splashColor: Colors
                                                              .transparent,
                                                          title: const Text(
                                                            'No',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          leading: Radio(
                                                            value: false,
                                                            activeColor:
                                                                ColorDefination
                                                                    .blue,
                                                            groupValue: isDM,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                isDM = value!;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                      },
                                    );
                                  },
                                  icon: const LineIcon(
                                    LineIcons.paperPlane,
                                    size: 20,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 30,
                                left: 155,
                                child: IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      isBottomSheetOpen = true;
                                    });
                                    await showModalBottomSheet(
                                        backgroundColor:
                                            ColorDefination.bgColor,
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom,
                                              ),
                                              child: SizedBox(
                                                width: width,
                                                height: height / 4,
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    SizedBox(
                                                      width: width - width / 15,
                                                      child: const Text(
                                                        "Add Tags #️⃣",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    SizedBox(
                                                      width: width - width / 12,
                                                      child: const Text(
                                                        "Enter upto 5 tags separated by comma(,)",
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black45,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: width - width / 15,
                                                      child: tagfield,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                        }).then((value) {
                                      setState(() {
                                        initialList =
                                            _controller.getTags ?? initialList;
                                        isBottomSheetOpen = false;
                                      });
                                    });
                                  },
                                  tooltip: "Tags",
                                  icon: const LineIcon(
                                    LineIcons.tags,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          imagePath != ""
                              ? Container(
                                  constraints: BoxConstraints(
                                    maxHeight: height / 3,
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Image.file(
                                          File(imagePath),
                                        ),
                                      ),
                                      Positioned(
                                          top: 8,
                                          right: 0,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                imagePath = "";
                                              });
                                            },
                                            icon: const Icon(Icons.delete),
                                          ))
                                    ],
                                  ),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
