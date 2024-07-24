import 'package:flutter/cupertino.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/pages/homepage.dart';
import 'package:gsconnect/widgets/loading.dart';

class MyPostPage extends StatefulWidget {
  const MyPostPage({super.key});

  @override
  State<MyPostPage> createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  late bool _isLoading = true;

  @override
  void initState() {
    handleVerify(context).then((value) {
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
    return _isLoading
        ? const LoadingWidget()
        : const HomePage(
            isMyPost: true,
            isOfficialUpdate: false,
          );
  }
}
