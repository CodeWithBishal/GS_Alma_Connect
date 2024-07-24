import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

recordError(e, String fnName) {
  if (!kIsWeb) {
    FirebaseCrashlytics.instance.recordError(
      Exception("$e $fnName"),
      StackTrace.current,
      reason: "$e $fnName",
      fatal: false,
    );
  }
}
