import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsconnect/models/authentication.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/appbar.dart';
import 'package:gsconnect/widgets/loading.dart';
import 'package:gsconnect/widgets/record_error.dart';
import 'package:gsconnect/widgets/toast.dart';
import 'package:line_icons/line_icons.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  late bool _obscureText = true;
  late bool _isLoading = false;
  String? errorMessage;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final passwordEditingController = TextEditingController();
  final confirmpasswordEditingController = TextEditingController();
  final fnameEditingController = TextEditingController();
  final lnameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    TextFormField fname = TextFormField(
      expands: false,
      autofillHints: const [AutofillHints.name],
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
      ),
      controller: fnameEditingController,
      validator: (value) {
        RegExp regex = RegExp(r'[a-zA-Z]{3,}');
        if (value!.isEmpty) {
          return ("First Name is required");
        }
        if (!regex.hasMatch(value)) {
          return ("First Name is required");
        }
        return null;
      },
      keyboardType: TextInputType.name,
      decoration: const InputDecoration(
        labelText: "First Name",
        prefixIcon: Icon(
          LineIcons.user,
        ),
      ),
    );
    TextFormField lname = TextFormField(
      expands: false,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
      ),
      decoration: const InputDecoration(
        labelText: "Last Name",
      ),
      controller: lnameEditingController,
      validator: (value) {
        RegExp regex = RegExp(r'[a-zA-Z]{3,}');
        if (value!.isEmpty) {
          return ("Last Name is required");
        }
        if (!regex.hasMatch(value)) {
          return ("Last Name is required");
        }
        return null;
      },
      keyboardType: TextInputType.name,
    );
    TextFormField email = TextFormField(
      controller: emailEditingController,
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
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(
          LineIcons.envelope,
        ),
      ),
    );
    TextFormField password = TextFormField(
      expands: false,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.newPassword],
      style: const TextStyle(
        fontWeight: FontWeight.w700,
      ),
      obscureText: _obscureText,
      controller: passwordEditingController,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Please Enter a valid Password");
        }
        if (!regex.hasMatch(value)) {
          return ("Password must be 6 or more characters long");
        }
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.deny(
          RegExp('[ ]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(
          LineIcons.lock,
        ),
        suffixIcon: IconButton(
          enableFeedback: false,
          onPressed: _toggle,
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: ColorDefination.blue,
          ),
        ),
      ),
    );
    TextFormField cpassword = TextFormField(
      controller: confirmpasswordEditingController,
      expands: false,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.newPassword],
      style: const TextStyle(
        fontWeight: FontWeight.w700,
      ),
      validator: (value) {
        if (value != passwordEditingController.text) {
          return "Password and Confirm Password Should be Same";
        } else {
          return null;
        }
      },
      inputFormatters: [
        FilteringTextInputFormatter.deny(
          RegExp('[ ]'),
        ),
      ],
      obscureText: _obscureText,
      decoration: const InputDecoration(
        labelText: "Confirm Password",
        prefixIcon: Icon(
          LineIcons.lock,
        ),
      ),
    );
    return Scaffold(
      body: _isLoading
          ? const LoadingWidget()
          : SafeArea(
              child: ListView(
                primary: true,
                shrinkWrap: false,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  onlyleading(context: context),
                  const Center(
                    child: Text(
                      "Let's Create an Account for You",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: height / 25,
                  ),
                  Form(
                    key: _formKey,
                    child: ListView(
                      primary: false,
                      shrinkWrap: true,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: width / 2 - width / 25,
                              child: fname,
                            ),
                            SizedBox(
                              width: width / 2 - width / 25,
                              child: lname,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: height / 50,
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: width - width / 20,
                              child: email,
                            ),
                            SizedBox(
                              height: height / 50,
                            ),
                            SizedBox(
                              width: width - width / 20,
                              child: password,
                            ),
                            SizedBox(
                              height: height / 50,
                            ),
                            SizedBox(
                              width: width - width / 20,
                              child: cpassword,
                            ),
                            SizedBox(
                              height: height / 30,
                            ),
                            SizedBox(
                              height: height / 60,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "By signing up you agree to our",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: " Terms of Service",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                          fontFamily: 'Montserrat',
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            //TODO
                                          },
                                      ),
                                      const TextSpan(
                                        text: " & ",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      TextSpan(
                                        text: " Privacy Policy",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                          fontFamily: 'Montserrat',
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            //TODO
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: height / 50,
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

                                    try {
                                      HandleSignup.signUp(
                                        emailEditingController.text,
                                        passwordEditingController.text,
                                        "${fnameEditingController.text} ${lnameEditingController.text}",
                                        context,
                                      ).then((value) {
                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      });
                                    } on FirebaseAuthException catch (error) {
                                      switch (error.code) {
                                        case "invalid-email":
                                          errorMessage =
                                              "Invalid Email Address.";
                                          break;
                                        case "user-disabled":
                                          errorMessage =
                                              "User with this Email has been disabled.";
                                          break;
                                        case "too-many-requests":
                                          errorMessage =
                                              "Too many Requests, Please retry after some time.";
                                          break;
                                        case "email-already-in-use":
                                          errorMessage =
                                              "The Email Address is already in use by another account.";
                                          break;
                                        default:
                                          errorMessage =
                                              "Failed, please try after some time.";
                                      }
                                      flutterToast(
                                          "Undefined Error, Please try again later!");
                                      recordError(error,
                                          "$error Create an Account btn");
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
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
                                  "Create an Account",
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
                              height: height / 50,
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
