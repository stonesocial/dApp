import 'dart:io';

import 'package:auth_microapp/auth_microapp.dart';
import 'package:dependencies/dependencies.dart';
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
  final SplashArgs args;

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SignInController {

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() {
    controller = widget.controller;
    walletController = widget.walletController;
    userController = widget.userController;
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
        padding: EdgeInsets.only(bottom: context.mediaQuery.viewPadding.bottom + (Platform.isAndroid ? 20 : 0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            context.logo(size: 60),
            context.branding()
          ],
        ),
      ),
    );
  }
}

class SplashArgs {
  final bool fromBackgroundNotification;

  SplashArgs({this.fromBackgroundNotification = false});
}