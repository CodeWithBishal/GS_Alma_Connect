import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/models/authentication.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/auth/redirect.dart';
import 'package:gsconnect/screens/pages/add.dart';
import 'package:gsconnect/screens/pages/all_post.dart';
import 'package:gsconnect/screens/pages/homepage.dart';
import 'package:gsconnect/screens/chat/messages.dart';
import 'package:gsconnect/screens/pages/official_updates.dart';
import 'package:gsconnect/screens/pages/profile.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/copyright.dart';
import 'package:gsconnect/widgets/image.dart';
import 'package:gsconnect/widgets/snacbar.dart';
import 'package:gsconnect/widgets/url_launcher.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'appbar.dart';

class NavBarBottom extends StatefulWidget {
  final int? selectedInd;
  const NavBarBottom({super.key, this.selectedInd});

  @override
  State<NavBarBottom> createState() => _NavBarBottomState();
}

class _NavBarBottomState extends State<NavBarBottom> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;
  @override
  void initState() {
    selectedIndex = widget.selectedInd ?? 0;
    super.initState();
  }

  final screens = <Widget>[
    const HomePage(
      isMyPost: false,
      isOfficialUpdate: false,
    ),
    const OfficialUpdates(),
    const MessagesPage(),
    const MyPostPage(),
  ];
  late bool exit = false;
  @override
  Widget build(BuildContext context) {
    late List<IconData> iconList = <IconData>[
      selectedIndex == 0 ? Icons.home : LineIcons.home,
      selectedIndex == 1 ? LineIcons.newspaperAlt : LineIcons.newspaper,
      selectedIndex == 2 ? Icons.message : Icons.message_outlined,
      selectedIndex == 3 ? LineIcons.mailBulk : LineIcons.mailBulk,
    ];
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    User? user = FirebaseAuth.instance.currentUser;
    bool isVerified = !notVerified();

    return Scaffold(
      key: _scaffoldKey,
      appBar: loggedInAppBar(
        context: context,
        key: _scaffoldKey,
        isBack: false,
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DrawerHeader(
                  padding: EdgeInsets.zero,
                  child: UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    margin: EdgeInsets.zero,
                    accountName: Row(
                      children: [
                        Text(
                          user!.displayName.toString().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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
                    accountEmail: GestureDetector(
                      onTap: isVerified
                          ? () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const MyProfile(
                                    isMyProfile: true,
                                    uid: "",
                                  ),
                                ),
                              );
                            }
                          : () {
                              customSnacBar(
                                context,
                                "Link your Enrollment Number to access your profile",
                              );
                            },
                      child: Text(
                        "View Profile",
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    currentAccountPicture: CachedImageNetworkimage(
                      url: user.photoURL.toString(),
                      width: width,
                      isBorder: false,
                      height: height,
                      isCircle: true,
                      isMaxHeight: false,
                    ),
                  ),
                ),
                isVerified
                    ? Column(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              LaunchUrl.openLink(
                                url: "http://www.sgsitsindore.in/",
                                context: context,
                                launchMode: LaunchMode.externalApplication,
                              );
                            },
                            icon: const LineIcon(
                              LineIcons.university,
                            ),
                            label: SizedBox(
                              width: width,
                              child: Text(
                                "Students Portal",
                                style: TextStyle(
                                  color: ColorDefination.blue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : TextButton.icon(
                        onPressed: () {
                          handleVerify(context);
                        },
                        icon: const LineIcon(
                          LineIcons.user,
                        ),
                        label: SizedBox(
                          width: width,
                          child: Text(
                            "Verify Profile",
                            style: TextStyle(
                              color: ColorDefination.blue,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () {
                    final provider = Provider.of<GoogleSignInProvider>(context,
                        listen: false);
                    provider.logoutUser().then((value) async {
                      await onlyDeleteHive();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RedirectUser()),
                        (Route<dynamic> route) => false,
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.logout_outlined,
                  ),
                  label: Text(
                    "Logout",
                    style: TextStyle(
                      color: ColorDefination.blue,
                    ),
                  ),
                ),
                copywrite(context),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ],
        ),
      ),
      extendBody: true,
      body: PopScope(
        canPop: exit,
        onPopInvoked: (didPop) {
          customSnacBar(context, "Press back again to exit");
          setState(() {
            exit = true;
          });
        },
        child: Center(
          child: screens[selectedIndex],
        ),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: isVerified && selectedIndex != 4
          ? FloatingActionButton(
              backgroundColor: Colors.blue[100],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPost(),
                  ),
                );
              },
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                size: 40,
                weight: 10,
                color: Colors.white,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isVerified
          ? AnimatedBottomNavigationBar(
              height: 67,
              icons: iconList,
              activeIndex: selectedIndex,
              activeColor: ColorDefination.yellow,
              gapLocation: GapLocation.center,
              notchSmoothness: NotchSmoothness.softEdge,
              onTap: (index) => setState(
                () => selectedIndex = index,
              ),
              //other params
            )
          : null,
      // bottomNavigationBar: Column(
      //   mainAxisSize: MainAxisSize.min,
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     NavigationBarTheme(
      //       data: NavigationBarThemeData(
      //         height: 62,
      //         elevation: 4,
      //         indicatorColor: selectedIndex == 4
      //             ? Colors.transparent
      //             : ColorDefination.secondaryColor,
      //         labelTextStyle: MaterialStateProperty.all(
      //           const TextStyle(
      //             fontWeight: FontWeight.w600,
      //             color: Colors.black,
      //             fontFamily: "",
      //             fontSize: 10,
      //           ),
      //         ),
      //         backgroundColor: ColorDefination.navbar,
      //       ),
      //       child: NavigationBar(
      //           animationDuration: const Duration(seconds: 1),
      //           selectedIndex: selectedIndex,
      //           onDestinationSelected: (int selectedIndex) {
      //             setState(() {
      //               if (selectedIndex > 2) {
      //                 this.selectedIndex = selectedIndex - 1;
      //               } else {
      //                 this.selectedIndex = selectedIndex;
      //               }
      //               print(this.selectedIndex);
      //             });
      //           },
      //           destinations: const [
      //             NavigationDestination(
      //               icon: Icon(LineIcons.home),
      //               selectedIcon: Icon(Icons.home),
      //               label: "Home",
      //             ),
      //             NavigationDestination(
      //               icon: Icon(Icons.message),
      //               selectedIcon: Icon(Icons.message),
      //               label: "Messages",
      //             ),
      //             Stack(
      //               children: [],
      //             ),
      //             NavigationDestination(
      //               icon: Icon(LineIcons.bell),
      //               selectedIcon: Icon(Icons.notifications),
      //               label: "Updates",
      //             ),
      //             NavigationDestination(
      //               icon: Icon(
      //                 LineIcons.mailBulk,
      //               ),
      //               selectedIcon: Icon(
      //                 LineIcons.mailBulk,
      //               ),
      //               label: "My Posts",
      //             )
      //           ]),
      //     ),
      //   ],
      // ),
    );
  }
}
