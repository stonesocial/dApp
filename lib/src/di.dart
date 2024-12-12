import 'package:core/core.dart';
import 'package:dependencies/dependencies.dart';
import 'package:ui/ui.dart';
import 'package:stn_wallet/wallet.dart';

import 'di.config.dart';

@InjectableInit(preferRelativeImports: true)
Future<void> configureDependencies() async {
  locator.registerSingleton<SolanaService>(SolanaService(solana: SolanaClient(rpcUrl: Uri.parse(Defines.rpcUrl), websocketUrl: Uri.parse(Defines.websocketUrl))));
  locator.registerSingleton<BasisHttpClient>(BasisHttpClient(urlBase: Defines.apiUrl));
  locator.registerSingleton<IpfsClient>(IpfsClient(httpClient: locator()));
  locator.registerSingleton<ISecureStorage>(const SecureStorage(FlutterSecureStorage()));
  locator.registerSingleton<ICacheStorage>(CacheStorage(await SharedPreferences.getInstance()));
  locator.registerSingleton<WalletService>(WalletService(locator(), locator(), locator()));
  locator.registerSingleton<UiViewmodel>(UiViewmodel(locator()));
  locator.init();
}