import 'flavor.dart';

export 'env.dart';

sealed class Env {
  static Flavor? flavor;

  static bool get isDev => flavor == Flavor.dev;
  static bool get isProd => flavor == Flavor.prod;
}
