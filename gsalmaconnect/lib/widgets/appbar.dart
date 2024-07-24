import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/pages/search_res.dart';
import 'package:gsconnect/theme/whitelabel.dart';
import 'package:gsconnect/widgets/image.dart';
import 'package:gsconnect/widgets/internet.dart';
import 'package:gsconnect/widgets/snacbar.dart';
import 'package:line_icons/line_icons.dart';

Widget onlyleading({required BuildContext context}) {
  return backBtn(
    context: context,
  );
}

AppBar loggedInAppBar({
  required BuildContext context,
  GlobalKey? key,
  Widget? widget,
  required bool isBack,
}) {
  final width = MediaQuery.of(context).size.width;
  final editingController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  return AppBar(
    scrolledUnderElevation: 0.0,
    shape: Border(
      bottom: BorderSide(
        color: Colors.grey.shade200,
        width: 2,
      ),
    ),
    automaticallyImplyLeading: false,
    actions: [
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            isBack
                ? Navigator.canPop(context)
                    ? backBtn(
                        context: context,
                      )
                    : dp(key, user)
                : dp(key, user),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: width - width / 3,
                  child: TextFormField(
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    // onChanged: _search,
                    onFieldSubmitted: (str) async {
                      bool isInternet =
                          await CheckForInternet.checkForInternet(context);
                      if (!context.mounted || !isInternet) return;
                      if (str.length < 5) {
                        customSnacBar(
                            context, "Please enter atleast 5 Characters");
                      } else {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => SearchResultPage(
                              queryString: str,
                            ),
                          ),
                        );
                      }
                    },
                    readOnly: notVerified(),
                    controller: editingController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      labelText: "Search Users or Posts",
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: InputBorder.none,
                      focusedBorder: const OutlineInputBorder().copyWith(
                        borderRadius: BorderRadius.circular(19),
                        borderSide: const BorderSide(
                          width: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            widget ??
                IconButton(
                  onPressed: () {
                    customSnacBar(
                      context,
                      "Coming Soon!",
                    );
                  },
                  icon: const Icon(
                    LineIcons.bell,
                  ),
                )
          ],
        ),
      )
    ],
  );
}

Widget dp(key, User? user) => SafeArea(
      child: GestureDetector(
        onTap: () {
          if (key != null) {
            key.currentState.openDrawer();
          }
        },
        child: user?.photoURL.toString() != null
            ? CachedImageNetworkimage(
                url: user!.photoURL.toString(),
                width: 50,
                isBorder: false,
                height: 0,
                isCircle: true,
                isMaxHeight: true,
              )
            : logo,
      ),
    );
Widget backBtn({required BuildContext context}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_outlined,
        ),
      ),
    ],
  );
}
