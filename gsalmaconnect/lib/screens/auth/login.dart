import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsconnect/models/authentication.dart';
import 'package:gsconnect/screens/auth/forgotpass.dart';
import 'package:gsconnect/theme/colors.dart';
import 'package:gsconnect/widgets/appbar.dart';
import 'package:gsconnect/widgets/loading.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final _formKey = GlobalKey<FormState>();
  late bool _obscureText = true;
  late bool _isLoading = false;

  @override
  void dispose() {
    passwordEditingController.dispose();
    emailEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      controller: emailEditingController,
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: _isLoading
          ? const LoadingWidget()
          : SafeArea(
              child: ListView(
                shrinkWrap: true,
                primary: false,
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          width: width - width / 15,
                          child: const Text(
                            "Welcome Back!",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: width - width / 15,
                          child: const Text(
                            "Sign in back to your account",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Source Sans Pro',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height / 13,
                        ),
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
                          width: width,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => const ForgotPassword(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              enableFeedback: false,
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Forgot Password?",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: ColorDefination.blue,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Source Sans Pro',
                                ),
                              ),
                            ),
                          ),
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
                                final provider =
                                    Provider.of<GoogleSignInProvider>(context,
                                        listen: false);
                                provider
                                    .signIn(
                                  email: emailEditingController.text,
                                  password: passwordEditingController.text,
                                  context: context,
                                )
                                    .whenComplete(
                                  () {
                                    Navigator.of(context)
                                        .popUntil((route) => route.isFirst);
                                    Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () {
                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      },
                                    );
                                  },
                                );
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
                              "Login",
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
