import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigInfo {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  Future<void> initConfig() async {
    int buildNumber = 0;
    bool isMaintenance = false;
    bool isForceUpdate = false;
    await remoteConfig.setDefaults(<String, dynamic>{
      'min_usable_version': buildNumber,
      'force_update': isForceUpdate,
      'is_maintenance': isMaintenance,
    });
  }
}
