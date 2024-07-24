import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/screens/auth/login.dart';
import 'package:gsconnect/screens/auth/register.dart';
import 'package:gsconnect/models/authentication.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/copyright.dart';
import 'package:gsconnect/widgets/loading.dart';
import 'package:gsconnect/theme/whitelabel.dart';
import 'package:provider/provider.dart';

class ContinuePage extends StatefulWidget {
  const ContinuePage({super.key});

  @override
  State<ContinuePage> createState() => _ContinuePageState();
}

class _ContinuePageState extends State<ContinuePage> {
  late Image googlePicture;
  late bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      // initDynamicLinks();
      googlePicture = Image.asset(
        "assets/g-logo/g-logo.png",
      );
    }
  }

  @override
  void didChangeDependencies() {
    precacheImage(googlePicture.image, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: _isLoading
          ? const LoadingWidget()
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    width: width,
                    child: Text(
                      Whitelabel.tag_1,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontFamily: 'Kaushan Script',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: width,
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      Whitelabel.tag_2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorDefination.yellow,
                        fontFamily: 'Kaushan Script',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: width,
                    height: height / 4,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black26,
                          width: 2.0,
                        ),
                      ),
                      child: Image.asset(
                        Whitelabel.logoPath,
                        width: width / 2,
                        scale: 0.7,
                      ),
                    ),
                  ),
                  Text(
                    Whitelabel.platName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorDefination.yellow,
                      fontFamily: 'Kaushan Script',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: height / 30,
                  ),
                  Text(
                    Whitelabel.subTag, //TODOO
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Source Sans Pro',
                      fontSize: 24,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  SizedBox(
                    height: height / 10,
                  ),
                  SizedBox(
                    width: width - width / 15,
                    height: height / 15,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
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
                        "Sign Up with Email ID",
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
                  SizedBox(
                    height: height / 100,
                  ),
                  SizedBox(
                    width: width - width / 15,
                    height: height / 15,
                    child: TextButton.icon(
                      icon: Image.asset(
                        "assets/g-logo/g-logo.png",
                      ),
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                        });
                        final provider = Provider.of<GoogleSignInProvider>(
                          context,
                          listen: false,
                        );
                        provider.googleLogin().whenComplete(() {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        });
                      },
                      style: ButtonStyle(
                        enableFeedback: false,
                        backgroundColor: WidgetStateProperty.all(Colors.white),
                        overlayColor: WidgetStateProperty.all(Colors.black12),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                            side: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      label: const Text(
                        "Continue with Google",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height / 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an Account?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontFamily: 'Source Sans Pro',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          enableFeedback: false,
                        ),
                        child: const Text(
                          "Sign in",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Source Sans Pro',
                          ),
                        ),
                      ),
                    ],
                  ),
                  copywrite(
                    context,
                  ),
                ],
              ),
            ),
    );
  }
}
