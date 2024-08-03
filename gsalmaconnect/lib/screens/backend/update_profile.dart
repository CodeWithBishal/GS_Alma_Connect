import 'package:gsconnect/widgets/consts.dart';
import 'package:intl/intl.dart';

///returns January 6, 2024 5:49 PM
String getCurrentDateTime() {
  var now = DateTime.now();
  var formatter = DateFormat('MMMM d, yyyy h:mm a');
  String formattedDate = formatter.format(now);
  return formattedDate;
}

String getTimeStamp() {
  DateTime now = DateTime.now();
  int timestampMillis = now.millisecondsSinceEpoch;
  return timestampMillis.toString();
}

String getFormattedDate(String timestampMillis) {
  DateTime today = DateTime.now();
  DateTime timestampDateTime = DateTime.fromMillisecondsSinceEpoch(
    int.parse(
      timestampMillis,
    ),
  );
  // Format the DateTime using DateFormat
  if (timestampDateTime.day == (today.day - 1)) {
    final date = DateFormat('h:mm a').format(timestampDateTime);
    String formattedDate = "Yesterday, $date";
    return formattedDate;
  } else if (timestampDateTime.day == today.day) {
    final date = DateFormat('h:mm a').format(timestampDateTime);
    String formattedDate = "Today, $date";
    return formattedDate;
  } else if (timestampDateTime.year == today.year) {
    String formattedDate =
        DateFormat('MMM d, h:mm a').format(timestampDateTime);
    return formattedDate;
  } else {
    String formattedDate =
        DateFormat('MMM d, yyyy h:mm a').format(timestampDateTime);
    return formattedDate;
  }
}

// Future updateAfterVerify(String enrollmentNo, String branch, String year,
//     String course, BuildContext context, String name) async {
//   updateProfileAtdataBase(
//     enrollmentNo,
//     branch,
//     year,
//     course,
//     context,
//     name,
//   ).then((value) async {
//     await deleteHiveAndRefetch();
//     if (!context.mounted) return;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const RedirectUser(),
//       ),
//       (route) => false,
//     );
//   });
// }

// Future updateProfileAtdataBase(
//   String enrollmentNo,
//   String branch,
//   String year,
//   String course,
//   BuildContext context,
//   String name,
// ) async {
//   if (userHiveData.length == 0) return;
//   final hiveRes = userHiveData.getAt(0);
//   if (hiveRes == null) return;
//   // final pfpURL = getDiceBearURL(name);
//   final ref = userDataRTDB.child(hiveRes.uid);
//   await ref.child("branch").set(branch);
//   await ref.child("fullname").set(name);
//   // await ref.child("imgURL").set(pfpURL);
//   await ref.child("course").set(course);
//   await ref.child("enrollmentNo").set(enrollmentNo);
//   await ref.child("enrollmentYear").set(year);
//   await ref.child("isVerified").set(true);
//   final publicDataRef = publicUserDataRTDB.child(hiveRes.userName);
//   await publicDataRef.child("isVerified").set(true);
//   await publicDataRef.child("fullname").set(name);

//   await linkProfile(
//     enrollmentNo,
//   );
//   User? user = FirebaseAuth.instance.currentUser;
//   await user!.updateDisplayName(name);
//   // await user.updatePhotoURL(
//   //   pfpURL,
//   // );
// }

Future updateProfileHeadline(
  String uid,
  String professionalBrief,
) async {
  final userRef = userDataRTDB.child(uid);
  await userRef.child("profileHeadline").set(professionalBrief);
}

Future updateprofessionalBrief(
  String uid,
  String profileHeadline,
) async {
  final userRef = userDataRTDB.child(uid);
  await userRef.child("professionalBrief").set(profileHeadline);
}

Future addNoOfPostVal(String uid) async {
  final userRef = userDataRTDB.child(uid);
  final det = await userRef.once();
  final int noOfPosts =
      int.parse(det.snapshot.child("noOfPosts").value.toString());
  await userRef.child("noOfPosts").set(noOfPosts + 1);
}
