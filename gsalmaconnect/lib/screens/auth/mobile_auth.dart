import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsconnect/models/authentication.dart';
import 'package:gsconnect/screens/backend/notification.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/internet.dart';
import 'package:gsconnect/widgets/record_error.dart';
import 'package:gsconnect/widgets/snacbar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

ValueNotifier<bool> isOTP = ValueNotifier(false);
final pinController = TextEditingController();

class MobileOTP extends StatefulWidget {
  const MobileOTP({super.key});

  @override
  State<MobileOTP> createState() => _MobileOTPState();
}

class _MobileOTPState extends State<MobileOTP> {
  late Image otpImage;
  String fcmToken = "";
  final _formKey = GlobalKey<FormState>();
  final _formOTPKey = GlobalKey<FormState>();
  late bool _isLoading = false;
  late String verificationCode = "";
  final userEditingController = TextEditingController();
  final phoneEditingController = TextEditingController();
  late bool usrNameErr = false;
  final FocusNode focusNode = FocusNode();
  final FocusNode usernameNode = FocusNode();
  User? user = FirebaseAuth.instance.currentUser;
  final defaultPinTheme = PinTheme(
    width: 80,
    height: 50,
    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    decoration: BoxDecoration(
      color: const Color.fromRGBO(222, 231, 240, .57),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.transparent),
    ),
  );
  @override
  void initState() {
    if (mounted) {
      isOTP.value = false;
      otpImage = Image.asset(
        "assets/logo/otp.png",
        scale: 0.1,
      );
    }
    super.initState();
  }

  checkUsername(String username) async {
    setState(() {
      _isLoading = true;
    });
    final storageRef = FirebaseDatabase.instance.ref("UserName");
    final listResult = await storageRef.child(username).once();
    if (listResult.snapshot.value != null) {
      setState(() {
        usrNameErr = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        usrNameErr = false;
      });
      sendOTP();
    }
  }

  Future sendOTP() async {
    Timer(const Duration(seconds: 15), () {
      if (!isOTP.value) {
        customSnacBarWithAction(
          context,
          "OTP request is taking too long, kindly restart the app or refresh the page",
          SnackBarAction(
            label: "Refresh",
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        );
      }
    });
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    provider
        .verifyPhoneNumber(
      "+91 ${phoneEditingController.text}",
      context,
      setData,
    )
        .catchError((onError) {
      recordError(
        onError.toString(),
        "verifynumber",
      );
    });
  }

  verifyNumber(pin) async {
    bool isInternet = await CheckForInternet.checkForInternet(context);
    fcmToken = await NotificationFirebase.getFirebaseMessagingToken();
    if (!isInternet || !mounted) return;
    RegExp regExp = RegExp(r'^[0-9]{6}$');
    if (regExp.hasMatch(pin)) {
      setState(() {
        _isLoading = true;
      });
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      provider
          .connectPhoneNumber(
        verificationCode,
        pin,
        context,
        phoneEditingController.text,
        userEditingController.text,
        fcmToken,
      )
          .catchError((onError) {
        FirebaseAuth.instance.currentUser?.reload();
        isOTP.value = false;
        recordError(onError, "pinPutFnc");
      }).then((value) {
        setState(() {
          _isLoading = false;
          FirebaseAuth.instance.currentUser?.reload();
        });
        isOTP.value = false;
      });
    } else {
      customSnacBar(
        context,
        "Invalid, Please enter a valid OTP",
      );
    }
  }

  @override
  void didChangeDependencies() {
    precacheImage(otpImage.image, context);
    isOTP.addListener(_showModalBottomSheetIfNeeded);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    isOTP.removeListener(_showModalBottomSheetIfNeeded);
    super.dispose();
  }

  void _showModalBottomSheetIfNeeded() {
    if (isOTP.value) {
      showModalBottomSheet(
        backgroundColor: ColorDefination.bgColor,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          final width = MediaQuery.of(context).size.width;
          final height = MediaQuery.of(context).size.height;
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SizedBox(
                  width: width,
                  height: height / 4.5,
                  child: Form(
                    key: _formOTPKey,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        SizedBox(
                          width: width - width / 9,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "OTP sent on SMS to +91${phoneEditingController.text}",
                              semanticsLabel:
                                  "OTP sent on SMS to +91${phoneEditingController.text}",
                              style: const TextStyle(
                                // fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          width: width,
                        ),
                        SizedBox(
                          width: width - width / 8,
                          child: Pinput(
                            controller: pinController,
                            androidSmsAutofillMethod:
                                AndroidSmsAutofillMethod.none,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: defaultPinTheme.copyWith(
                              height: 60,
                              width: 80,
                              decoration: defaultPinTheme.decoration!.copyWith(
                                border: Border.all(
                                  color: ColorDefination.blue,
                                ),
                              ),
                            ),
                            focusNode: focusNode,
                            autofocus: true,
                            errorPinTheme: defaultPinTheme.copyWith(
                              decoration: BoxDecoration(
                                color: ColorDefination.errColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            length: 6,
                            validator: (pin) {
                              RegExp regex = RegExp(r'^[0-9]{6}$');
                              if (pin != null && pin.isEmpty) {
                                return ("Please enter a valid OTP");
                              }
                              if (!regex.hasMatch(pin.toString())) {
                                return ("Please enter a valid OTP");
                              }
                              return null;
                            },
                            onCompleted: (pin) {
                              verifyNumber(pin);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    TextFormField username = TextFormField(
      controller: userEditingController,
      expands: false,
      focusNode: usernameNode,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username],
      style: const TextStyle(
        fontWeight: FontWeight.w700,
      ),
      maxLength: 20,
      inputFormatters: [
        FilteringTextInputFormatter.deny(
          RegExp('[ ]'),
        ),
      ],
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter a valid Username");
        }
        if (!RegExp("^[a-zA-Z0-9]").hasMatch(value)) {
          return ("Please Enter a valid Username");
        }
        if (value.length < 5) {
          return "Please enter more than 4 characters";
        }
        return null;
      },
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelText: "Username",
        errorText: usrNameErr
            ? "Username already exists, Choose a new Username"
            : null,
        prefixIcon: const Icon(
          LineIcons.user,
        ),
      ),
    );
    final phoneField = TextFormField(
      autofocus: false,
      focusNode: focusNode,
      inputFormatters: [
        FilteringTextInputFormatter.deny(
          RegExp('[ ]'),
        ),
      ],
      autofillHints: const [AutofillHints.telephoneNumber],
      controller: phoneEditingController,
      validator: (value) {
        RegExp regex = RegExp(r'^[6-9]\d{9}$');
        if (value!.isEmpty) {
          return ("Please Enter a valid 10 Digit Phone Number");
        }
        if (!regex.hasMatch(value)) {
          return ("Please Enter a valid 10 Digit Phone Number");
        }
        return null;
      },
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      cursorColor: Colors.black,
      maxLength: 10,
      decoration: const InputDecoration(
        prefixIcon: Icon(
          LineIcons.mobilePhone,
        ),
        prefixText: "+91 ",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(9),
          ),
        ),
        labelText: "Phone Number",
      ),
    );
    return ValueListenableBuilder(
      valueListenable: isOTP,
      builder: (context, value, child) {
        return Scaffold(
          body: SafeArea(
            child: ListView(
              shrinkWrap: true,
              primary: true,
              children: [
                SizedBox(
                  height: height / 50,
                ),
                SizedBox(
                  height: height / 2.7,
                  width: width,
                  child: otpImage,
                ),
                SizedBox(
                  height: height / 15,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        width: width - width / 12,
                        child: username,
                      ),
                      SizedBox(
                        height: height / 50,
                      ),
                      SizedBox(
                        width: width - width / 12,
                        child: phoneField,
                      ),
                      SizedBox(
                        height: height / 40,
                      ),
                      SizedBox(
                        width: width,
                        child: const Text(
                          "Username is publicly viewable and once set can't be changed.",
                          style: TextStyle(
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: width - width / 15,
                        height: height / 15,
                        child: TextButton.icon(
                          onPressed: !_isLoading
                              ? () async {
                                  focusNode.unfocus();
                                  usernameNode.unfocus();
                                  if (_formKey.currentState!.validate()) {
                                    bool isInternet =
                                        await CheckForInternet.checkForInternet(
                                            context);
                                    if (!isInternet) return;
                                    checkUsername(
                                      userEditingController.text,
                                    );
                                  }
                                }
                              : null,
                          style: ButtonStyle(
                            enableFeedback: false,
                            backgroundColor: WidgetStateProperty.all(
                              ColorDefination.blue,
                            ),
                            overlayColor:
                                WidgetStateProperty.all(Colors.white12),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                          label: _isLoading
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const SizedBox(),
                          icon: const Text(
                            "Send OTP    ",
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void setData(verificationID) {
    if (mounted) {
      verificationCode = verificationID;
    }
  }
}
