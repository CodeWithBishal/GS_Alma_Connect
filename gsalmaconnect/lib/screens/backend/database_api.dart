// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:gsconnect/widgets/toast.dart';
// import 'package:gsconnect/widgets/verify_dialog.dart';
// import 'package:http/http.dart' as http;
// // https://script.google.com/macros/s/AKfycbyCqUc99_dwxFr27A8NgCJnFtt-zpSj64EjB_H5cayeIThPL9z58p8Nc5aJz-sJGHd9/exec?apiKey=95da8f21fd7d0100A3c9c594140529b85d&name=0801BM231001

// Future calltoCheck(String enrollmentNo, BuildContext context) async {
//   final Uri url = Uri.parse(
//       "https://script.google.com/macros/s/AKfycbyCqUc99_dwxFr27A8NgCJnFtt-zpSj64EjB_H5cayeIThPL9z58p8Nc5aJz-sJGHd9/exec?apiKey=95da8f21fd7d0100A3c9c594140529b85d&name=$enrollmentNo&isUpdate=false");
//   var response = await http.get(
//     url,
//   );
//   final decodedData = jsonDecode(response.body);
//   if (decodedData['status'] == "success") {
//     if (context.mounted) {
//       Navigator.pop(context);
//       confirmProfile(
//         context,
//         decodedData["data"][1],
//         decodedData["data"][2],
//         enrollmentNo,
//         (decodedData["data"][3]).toString(), //Show Admission year
//         decodedData["data"][5], //course
//       );
//     }
//   } else {
//     flutterToast(
//       "Invalid Enrollment No. or Enrollment No. already linked with some other account",
//     );
//   }
// }

// Future linkProfile(
//   String enrollmentNo,
// ) async {
//   final Uri url = Uri.parse(
//       "https://script.google.com/macros/s/AKfycbyCqUc99_dwxFr27A8NgCJnFtt-zpSj64EjB_H5cayeIThPL9z58p8Nc5aJz-sJGHd9/exec?apiKey=95da8f21fd7d0100A3c9c594140529b85d&name=$enrollmentNo&isUpdate=true");
//   await http.get(
//     url,
//   );
// }
