import 'dart:async';
import 'package:dependencies/dependencies.dart';
import 'package:flutter/widgets.dart';

import '../env/flavor.dart';
import '../env/env.dart';
import '../firebase_options.dart';
import '../src/app.dart';
import '../src/di.dart';

Future<void> mainEnv(Flavor flavor) async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      Env.flavor = flavor;
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      await configureDependencies();
      runApp(App());
    },
    (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
  );
}
