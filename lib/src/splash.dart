import 'package:auth_microapp/auth_microapp.dart';
import 'package:dependencies/dependencies.dart';
import 'package:desys/desys.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';
import 'package:user_microapp/user_microapp.dart';
import 'package:wallet_microapp/wallet_microapp.dart';

class Splash extends StatefulWidget {
  const Splash({
    super.key,
    required this.controller,
    required this.walletController,
    required this.userController,
    required this.args,
  });

  final AuthController controller;
  final WalletController walletController;
  final UserController userController;
  final WrapperArgs args;

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SignInController, SingleTickerProviderStateMixin {

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() {
    controller = widget.controller;
    walletController = widget.walletController;
    userController = widget.userController;

    RemoteConfigHelper().init().then((instance) {
      instance.fetchConfigs(
        callback: _authenticate,
        onUpdate: (
          forceUpdate,
          current,
          fresh,
          playStoreUrl,
          appleStoreUrl,
          news,
        ) {
          showAnimatedPopup(
            AppUpdateDialog(
              current: current,
              fresh: fresh,
              news: news,
              playStoreUrl: playStoreUrl,
              appleStoreUrl: appleStoreUrl,
              forceUpdate: forceUpdate,
              callback: _authenticate,
            ),
          );
        },
      );
    });
  }

  void _authenticate() {
    Future(
      () async => await authenticate(
        remember: true,
        isAuthScreen: false,
        showLoadingIndicator: false,
        fromBackgroundNotification: widget.args.fromBackgroundNotification,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: dw(context),
        height: dh(context),
        margin: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            loading(),
            Center(child: context.branding()),
          ],
        ),
      ),
    );
  }
}