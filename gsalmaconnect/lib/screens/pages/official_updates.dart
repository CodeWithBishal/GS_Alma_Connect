import 'package:flutter/cupertino.dart';
import 'package:gsconnect/models/hive/hiveboxes.dart';
import 'package:gsconnect/screens/pages/homepage.dart';
import 'package:gsconnect/widgets/loading.dart';

class OfficialUpdates extends StatefulWidget {
  const OfficialUpdates({super.key});

  @override
  State<OfficialUpdates> createState() => _OfficialUpdatesState();
}

class _OfficialUpdatesState extends State<OfficialUpdates> {
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
            isMyPost: false,
            isOfficialUpdate: true,
          );
  }
}
