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

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    init();
    initAnimation();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void init() {
    controller = widget.controller;
    walletController = widget.walletController;
    userController = widget.userController;

    RemoteConfigHelper().init().then((instance) {
      instance.verifyWalletEnabled();
      instance.canUpdate(
        callback: _authenticate,
        onUpdate: (forceUpdate, current, fresh, playStoreUrl, appleStoreUrl, news) {
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

  initAnimation() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: dw(context),
        height: dh(context),
        child: ScaleTransition(
          scale: _animation,
          child: Center(child: context.logo()),
        ),
      ),
    );
  }
}