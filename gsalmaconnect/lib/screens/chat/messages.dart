import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/chat/chatpage.dart';
import 'package:gsconnect/widgets/loading.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late bool _isLoading = true;
  // late bool isNoChat = false;

  @override
  void initState() {
    handleVerify(context).then((value) {
      // final int length = userHiveData.getAt(0)!.chat.length;
      // setState(() {
      //   isNoChat = length == 0 ? true : false;
      // });
      if (value != _isLoading) {
        setState(() {
          _isLoading = value;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const LoadingWidget() : const ChatPageWidget();
  }
}
