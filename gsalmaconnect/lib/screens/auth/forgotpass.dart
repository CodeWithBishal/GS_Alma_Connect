import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsconnect/models/dynamic_link.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/appbar.dart';
import 'package:gsconnect/widgets/loading.dart';
import 'package:gsconnect/widgets/record_error.dart';
import 'package:gsconnect/widgets/toast.dart';
import 'package:line_icons/line_icons.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  String? errorMessage;
  final forgotemailEditingController = TextEditingController();

  void forgotPass(String email) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .sendPasswordResetEmail(
          email: email,
          actionCodeSettings: resetPasswordEmail,
        )
            .then((value) {
          setState(() {
            _isLoading = false;
          });
          flutterToast("Password Reset Email sent successfully");
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Invalid Email Address.";
            break;
          case "user-disabled":
            errorMessage = "User with this Email has been disabled.";
            break;
          case "user-not-found":
            errorMessage = "User with this Email could not be found.";
            break;
          default:
            errorMessage = "Failed, please try after some time.";
        }
        flutterToast("Undefined Error, Please try again later!");
        recordError(error, "$error sendPasswordResetEmail");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    TextFormField email = TextFormField(
      expands: false,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      style: const TextStyle(
        fontWeight: FontWeight.w700,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.deny(
          RegExp('[ ]'),
        ),
      ],
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter a valid Email Address");
        }
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please Enter a valid Email Address");
        }
        return null;
      },
      controller: forgotemailEditingController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(
          LineIcons.envelope,
        ),
      ),
    );
    return Scaffold(
      body: _isLoading
          ? const LoadingWidget()
          : SafeArea(
              child: ListView(
                primary: true,
                shrinkWrap: true,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  onlyleading(
                    context: context,
                  ),
                  SizedBox(
                    height: height / 50,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: width - width / 15,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 36,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: width - width / 15,
                          child: const Text(
                            "We got you! simply put your email here and we will send you a password reset email.", //TODOO
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height / 25,
                        ),
                        SizedBox(
                          width: width - width / 20,
                          child: email,
                        ),
                        SizedBox(
                          height: height / 30,
                        ),
                        SizedBox(
                          width: width - width / 15,
                          height: height / 15,
                          child: TextButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                forgotPass(forgotemailEditingController.text);
                              }
                            },
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
                            child: const Text(
                              "Submit",
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
                  )
                ],
              ),
            ),
    );
  }
}
