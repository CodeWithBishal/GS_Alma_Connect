import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gsconnect/main.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/models/public.dart';
import 'package:gsconnect/models/user.dart';
import 'package:gsconnect/models/user_name.dart';
import 'package:gsconnect/screens/auth/mobile_auth.dart';
import 'package:gsconnect/screens/auth/redirect.dart';
import 'package:gsconnect/widgets/consts.dart';
import 'package:gsconnect/widgets/record_error.dart';
import 'package:gsconnect/widgets/toast.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';

const String _fakeIdToken =
    "eyJhbGciOiJSUzI1NiIsImtpZCI6IjAzMmNjMWNiMjg5ZGQ0NjI2YTQzNWQ3Mjk4OWFlNDMyMTJkZWZlNzgiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoid29ybCBpbXBvcnRhbnQiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jS3pNNm9GWmJzYXg0bUNzMFVkdnJzZlZraU5TWHNrd3pNYlU4elFveHNIPXM5Ni1jIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL2dzY29ubmVjdC0xIiwiYXVkIjoiZ3Njb25uZWN0LTEiLCJhdXRoX3RpbWUiOjE3MDM2OTg0NzEsInVzZXJfaWQiOiJHNExQSWx6MlA4UktEaVFoaVVmMUxNZUhzQzQzIiwic3ViIjoiRzRMUElsejJQOFJLRGlRaGlVZjFMTWVIc0M0MyIsImlhdCI6MTcwMzY5ODQ3MSwiZXhwIjoxNzAzNzAyMDcxLCJlbWFpbCI6IndpbXBvcnRhbnQxMTJAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZ29vZ2xlLmNvbSI6WyIxMDk5Njc0Nzk2MzMxNDQ5MTYyMzMiXSwiZW1haWwiOlsid2ltcG9ydGFudDExMkBnbWFpbC5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJnb29nbGUuY29tIn19.JtnCqbLZf2rNAjo3g2iMG40OnFFMP46ZKQg2pEvTVcmcQZrcQVfVHp4R3HhTLKnGmKLKVyL7mQHm96RXl02ms2MyhG_bmBeWuKnEbpbZJ0SFf2KVINby2mQfoVCJm6m-qnhu-XkruoEul1Sp8Z0zhcc3osimYW3jH4mVeCxa5VzASQJOyGUq2UiKeDPoM2Ix2ZfUuUQw63JOyfWTEKNLU783P6v";

Future<bool> isUserAlreadyRegistered(String email) async {
  try {
    final methods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

    return methods.isEmpty || methods[0] == "google.com" ? false : true;
  } catch (e) {
    recordError(
      e.toString(),
      "isUserAlreadyRegistered_fnName",
    );
    return false;
  }
}

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignin = GoogleSignIn();
  final _auth = FirebaseAuth.instance;
  UserCredential? googleUserCredential;
  GoogleSignInAccount? _user;
  OAuthCredential? credential;
  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignin.signIn();
      if (googleUser == null) return null;
      _user = googleUser;
      final googleAuth = await googleUser.authentication;
      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:
            (kDebugMode && !isUseProdDB) ? _fakeIdToken : googleAuth.idToken,
      );
      try {
        // await isUserAlreadyRegistered(googleUser.email).then((value) async {
        //   if (value == false) {
        //     await _auth.signInWithCredential(credential!);
        //   } else {
        //     flutterToast(
        //       "Account already exists with Password Authentication",
        //     );
        //   }
        // });
        await _auth.signInWithCredential(credential!);
      } catch (e) {
        late String msg = e.toString();
        if (e.toString().contains("[firebase_auth/user-disabled]")) {
          msg = "The user account has been disabled by an administrator.";
        } else if (e.toString().contains("[firebase_auth/user-not-found]")) {
          msg =
              "There is no user record corresponding to this identifier. The user may have been deleted.";
        } else if (e
            .toString()
            .contains("[firebase_auth/network-request-failed]")) {
          msg =
              "A network error (such as timeout, interrupted connection or unreachable host) has occurred. Please update the app or make sure to install from the playstore";
        } else {
          msg = e.toString();
          recordError(e, "Google Login fn");
        }
        flutterToast(msg);
      }
      notifyListeners();
    } catch (e) {
      if (e.toString().contains("popup_closed_by_user")) {
        flutterToast(
          "Popup Closed by User!",
        );
      } else if (e.toString().contains("idpiframe_initialization_failed")) {
        flutterToast(
          "Cookies are not enabled, Please enable cookies and try again.",
        );
      } else if (e.toString().contains("user-not-found")) {
        flutterToast(
          "User not Found, Please try creating a new account",
        );
      } else if (e.toString().contains("network_error")) {
        flutterToast(
          "Please check your internet connection and try again.",
        );
      } else {
        recordError(e, "google login 2 fn");
        flutterToast("Undefined Error, Please try again later");
      }
    }
  }

  Future logoutUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final provider = auth.currentUser?.providerData;
    if (provider?[0].providerId == 'google.com') {
      try {
        await googleSignin.signOut();
      } catch (e) {
        flutterToast("There seem to be an error.");
      }
    }
    await FirebaseAuth.instance.signOut();
  }

  String? errorMessage;

  bool get isSignedIn => _auth.currentUser != null;

  Future signIn(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "invalid-email":
          errorMessage = "Invalid Email Address.";
          break;
        case "wrong-password" || "INVALID_LOGIN_CREDENTIALS":
          errorMessage = "Invalid Email Address or Password.";
          break;
        case "user-not-found":
          errorMessage = "Account with this Email Address does not exists.";
          break;
        case "user-disabled":
          errorMessage = "User with this Email has been disabled.";
          break;
        case "too-many-requests":
          errorMessage = "Too many Requests, Please retry after some time";
          break;
        case "channel-error":
          errorMessage =
              "Unable to establish connection on channel. Please try again later";
          break;
        default:
          errorMessage = "Undefined Error, Please try again later!";
      }
      flutterToast(errorMessage.toString());
      if (errorMessage == "Undefined Error, Please try again later!") {
        recordError(error, "Signin fn");
      }
      FirebaseAuth.instance.signOut();
    }
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber, BuildContext context, Function setData) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          pinController.setText(phoneAuthCredential.smsCode ?? "");
          await _auth.signInWithCredential(phoneAuthCredential);
          notifyListeners();
        },
        verificationFailed:
            (FirebaseAuthException firebaseAuthException) async {
          if (firebaseAuthException.code ==
              "[firebase_auth/missing-client-identifier]") {
            flutterToast("Device Verification Failed!");
          } else if (firebaseAuthException.code == 'invalid-phone-number') {
            flutterToast("The provided phone number is not valid.");
          } else if (firebaseAuthException.code ==
              "firebase_auth/too-many-requests") {
            flutterToast(
                "We have blocked all requests from this device due to unusual activity. Try again later.");
          } else if (firebaseAuthException.code ==
              "firebase_auth/invalid-verification-id") {
            flutterToast("Invalid Verification Code");
          } else {
            isOTP.value = false;
            flutterToast(firebaseAuthException.message.toString());
            recordError(firebaseAuthException.message, "verifyPhoneNumber_1");
          }
        },
        codeSent: (String verificationID, int? resentToken) async {
          setData(verificationID);
          flutterToast("OTP Sent Successfully!");
          isOTP.value = true;
        },
        codeAutoRetrievalTimeout: (String verificationID) async {
          setData(verificationID);
        },
        timeout: const Duration(seconds: 60),
      );
      notifyListeners();
    } catch (e) {
      recordError(e.toString(), "verifyPhoneNumber");
      isOTP.value = false;
      flutterToast("Undefined Error, Please try again later!");
    }
  }

  Future connectPhoneNumber(
    verificationId,
    smsCode,
    BuildContext context,
    String phoneNo,
    String userName,
    String fcmToken,
  ) async {
    String communityRole = "Student";
    try {
      AuthCredential phonecredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      // await _auth.currentUser?.updateDisplayName(userName);

      //Link with credential will only launch after all details are uploaded
      // as once linked we can't store user data again, so for some users
      // Userdata in firebase database might be null
      // await _auth.currentUser?.linkWithCredential(phonecredential);
      if (context.mounted) {
        await postDetailsToFirebaseDataBase(
          phoneNo,
          _auth.currentUser!.displayName,
          _auth,
          context,
          userName,
          _auth.currentUser!,
          communityRole,
          phonecredential,
          fcmToken,
        );
      }
    } catch (e) {
      if (e.toString().contains(
            "invalid-verification-code",
          )) {
        flutterToast("Incorrect OTP, Please try again with the correct OTP!");
      } else if (e.toString() ==
          "[firebase_auth/credential-already-in-use] This Phone Number is already associated with a different user account.") {
        flutterToast(
            "This credential is already associated with a different user account.");
      } else if (e.toString().contains("[firebase_auth/channel-error]")) {
        recordError(e.toString(), "connectPhoneNumber21");
        flutterToast(
          "We are having trouble authenticating your account, Please try again later",
        );
      } else {
        recordError(e.toString(), "connectPhoneNumber");
        flutterToast("Undefined Error, Please try again later!");
      }
      notifyListeners();
      isOTP.value = false;
    }
  }
}

Future postDetailsToFirebaseDataBase(
  number,
  fullname,
  FirebaseAuth auth,
  BuildContext context,
  userName,
  User user,
  String communityRole,
  AuthCredential phonecredential,
  String fcmToken,
) async {
  //Date
  DateTime nowTime = DateTime.now();
  String formattedDateTime = DateFormat.yMMMMd().add_jm().format(nowTime);
  //TODO change domain and otherUserData
  bool isVerified = false;
  List domain = [];
  String enrollmentNo = "";
  int noOfPosts = 0;
  String branch = "";
  String enrollmentYear = "";
  String passYear = "";
  List otherUserData = [];
  String profileHeadline = "";
  String professionalBrief = "";
  String course = "";

  // calling firebaseStorage
  DatabaseReference userDataRef = userDataRTDB;

  UserModel userModel = UserModel(
    uid: user.uid,
    fullname: fullname,
    phoneNumber: number,
    email: user.email!,
    userName: userName,
    dateTime: formattedDateTime,
    isVerified: isVerified,
    imgURL: user.photoURL!,
    enrollmentNo: enrollmentNo,
    domain: domain, //change
    communityRole: communityRole,
    lastProfileUpdateTime: formattedDateTime,
    noOfPosts: noOfPosts,
    branch: branch,
    enrollmentYear: enrollmentYear,
    passYear: passYear,
    otherData: otherUserData,
    profileHeadline: profileHeadline,
    professionalBrief: professionalBrief,
    course: course,
    fcmToken: fcmToken,
    isAllowDM: true,
  );
//Add all userData to userData Table
  await userDataRef
      .child(user.uid)
      .set(
        userModel.toMap(),
      )
      .onError((error, stackTrace) async {
    recordError(
      error.toString(),
      "postDetailsToFirebaseDataBase_1",
    );
    await GoogleSignInProvider().logoutUser();
  }).then((value) {
    //only continue if no errors
    handleUserNameFirebaseDatabase(
      user,
      fullname,
      userName,
      auth,
      phonecredential,
      context,
      fcmToken,
      communityRole,
    );
  });

//Add to localStorage
  await addToHive(
    user.uid,
    fullname,
    number,
    user.email.toString(),
    userName,
    formattedDateTime,
    isVerified,
    user.photoURL.toString(),
    enrollmentNo,
    formattedDateTime,
    domain,
    communityRole,
    noOfPosts,
    branch,
    enrollmentYear,
    profileHeadline,
    professionalBrief,
    course,
    otherUserData,
    fcmToken,
  );
}

handleUserNameFirebaseDatabase(
  User user,
  String fullname,
  String userName,
  FirebaseAuth auth,
  AuthCredential phonecredential,
  BuildContext context,
  String fcmToken,
  String communityRole,
) async {
  // After all the datas are stored in the database
  // only then link the credential, as linkWithCredential once successfull
  // can't be launch twice and there is a possibility that user may access
  // the panel even without storing the data(due to an error)
  try {
    await auth.currentUser?.linkWithCredential(phonecredential);
    FirebaseAuth.instance.currentUser?.reload();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RedirectUser()),
      (Route<dynamic> route) => false,
    );
    DatabaseReference userNameRef = FirebaseDatabase.instance.ref("UserName");
    UserNameModal userNameModal = UserNameModal(
      uid: user.uid,
      userName: userName,
    );
    await userNameRef
        .child(userNameModal.userName)
        .set(
          userNameModal.toMap(),
        )
        .onError((error, stackTrace) async {
      recordError(
        error.toString(),
        "postDetailsToFirebaseDataBase_2",
      );
      await GoogleSignInProvider().logoutUser();
    });

    DatabaseReference publicDataRef = publicUserDataRTDB;
    PublicUserDataModal publicDataRefModal = PublicUserDataModal(
      uid: user.uid,
      fullname: fullname,
      userName: userName,
      imgURL: user.photoURL!,
      isVerified: false,
      fcmToken: fcmToken,
      isAllowDM: true,
      conversationIDs: [],
      communityRole: communityRole,
    );
    await publicDataRef
        .child(publicDataRefModal.userName)
        .set(
          publicDataRefModal.toMap(),
        )
        .onError((error, stackTrace) async {
      recordError(
        error.toString(),
        "postDetailsToFirebaseDataBase_23",
      );
      await GoogleSignInProvider().logoutUser();
    });
  } catch (e) {
    if (e.toString().contains("correct verification code again")) {
      flutterToast("Wrong Verification Code...");
    } else {
      flutterToast("Wrong Verification Code...");
      recordError(e.toString(), "postDetails_linkWithCredential");
    }
  }
}

class HandleSignup {
  static Future signUp(
    String email,
    String password,
    String fullname,
    BuildContext context,
  ) async {
    final auth = FirebaseAuth.instance;
    try {
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then(
        (value) {
          value.user!.updateDisplayName(fullname).catchError(
            (onError) {
              flutterToast("Failed to update user name.");
            },
          );
          //probably remove dicebear if does not work well
          value.user!.updatePhotoURL(
            getDiceBearURL(fullname.toString()),
          );
        },
      );
    } catch (e) {
      if (e.toString().contains("[firebase_auth/email-already-in-use]")) {
        flutterToast("The email address is already in use by another account.");
      } else {
        flutterToast("Undefined Error!");
        recordError(e, "registerUser");
      }
    }
  }
}
