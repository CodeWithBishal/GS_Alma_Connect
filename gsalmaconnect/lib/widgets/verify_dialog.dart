import 'package:flutter/material.dart';
import 'package:gsconnect/screens/backend/database_api.dart';
import 'package:gsconnect/screens/backend/update_profile.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:gsconnect/widgets/internet.dart';
import 'package:gsconnect/widgets/toast.dart';
import 'package:line_icons/line_icons.dart';

final TextEditingController _enrollmentNo = TextEditingController();
TextFormField verify = TextFormField(
  controller: _enrollmentNo,
  expands: false,
  autofocus: false,
  textInputAction: TextInputAction.done,
  style: const TextStyle(
    fontWeight: FontWeight.w300,
    fontSize: 15,
  ),
  validator: (value) {
    return null;
  },
  keyboardType: TextInputType.text,
  decoration: const InputDecoration(
    labelText: "Enrollment No.",
    prefixIcon: Icon(
      LineIcons.university,
    ),
  ),
);
void verifyBottomSheet(BuildContext context) {
  late bool isLoading = false;
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  showModalBottomSheet(
    backgroundColor: ColorDefination.bgColor,
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
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
                      "Verify Account ✅",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width - width / 15,
                    child: const Text(
                      "Enter Enrollment No.",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: width - width / 15,
                    child: Stack(
                      children: [
                        verify,
                        Positioned(
                          right: 3,
                          bottom: 6,
                          child: IconButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (_enrollmentNo.text.isNotEmpty) {
                                      bool isInternet = await CheckForInternet
                                          .checkForInternet(context);
                                      if (!isInternet || !context.mounted) {
                                        return;
                                      }
                                      flutterToast(
                                        "Please wait while we are verifying your profile.",
                                      );
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await calltoCheck(
                                        _enrollmentNo.text,
                                        context,
                                      ).then((value) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      });
                                    } else {
                                      flutterToast(
                                        "Enter a valid Enrollment No.",
                                      );
                                    }
                                  },
                            icon: const Icon(
                              Icons.check,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void confirmProfile(BuildContext context, String name, String branch,
    String enrollmentNo, String year, String course) {
  bool isLoading = false;
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: ColorDefination.bgColor,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            width: width,
            height: height / 4.5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width,
                    child: const Text(
                      "Confirm Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: const Text(
                      textAlign: TextAlign.center,
                      "Profile once linked can't be unlinked",
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircleAvatar(
                        radius: 30.0,
                        backgroundImage:
                            NetworkImage(getDiceBearURL(name.toString())),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "${name.toString()} (${year.toString()})",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(
                            width: width / 1.8,
                            child: Text(
                              "$course $branch",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                          onPressed: !isLoading
                              ? () async {
                                  bool isInternet =
                                      await CheckForInternet.checkForInternet(
                                          context);
                                  if (!isInternet || !context.mounted) return;
                                  setState(() {
                                    isLoading = true;
                                  });
                                  flutterToast("Please Wait, Redirecting...");
                                  updateAfterVerify(
                                    enrollmentNo,
                                    branch,
                                    year,
                                    course,
                                    context,
                                    name,
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.check))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
