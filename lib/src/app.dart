import 'package:auth_microapp/auth_microapp.dart';
import 'package:dapp/src/splash.dart';
import 'package:desys/desys.dart';
import 'package:explore_microapp/explore_microapp.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:core/core.dart';
import 'package:dependencies/dependencies.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notification_microapp/notification_microapp.dart';
import 'package:post_microapp/post_microapp.dart';
import 'package:ui/ui.dart';
import 'package:user_microapp/user_microapp.dart';
import 'package:wallet_microapp/wallet_microapp.dart';

import '../env/env.dart';
import '../env/flavor.dart';

class App extends StatelessWidget with BasisApp, Routing {
  App({super.key}) { init(); }

  void _configure() {
    configureInjection();
    configureRoutes();
    configureListener();
  }

  void init() {
    _configure();

    final notificationFacade = locator.get<NotificationFacade>();
    final settingsViewmodel = locator.get<UiViewmodel>();

    settingsViewmodel.setCurrentTheme();
    notificationFacade.initialize().then((_) {
      notificationFacade.messageListener(
        onLiveMessage: showNotificationAlert,
        onInitialMessage: _handleReceivedNotification,
        onMessageOpenedApp: (_) {},
      );
    });
  }

  void _handleReceivedNotification(Notification _) {
    Navigate.to.pushReplacementNamed(
      super.initialRoute,
      arguments: WrapperArgs(fromBackgroundNotification: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    setPreferredOrientations();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowIndicator();
          
          return false;
        },
        child: ValueListenableBuilder(
          valueListenable: locator.get<UiViewmodel>().isSystemTheme,
          builder: (context, isSystemTheme, child) {
            return ValueListenableBuilder(
              valueListenable: locator.get<UiViewmodel>().isDark,
              builder: (context, isDark, child) {
                return ValueListenableBuilder(
                  valueListenable: locator.get<UiViewmodel>().locale,
                  builder: (context, locale, child) {
                    return MaterialApp(
                      scaffoldMessengerKey: GlobalKeys.scaffoldMessengerKey,
                      debugShowCheckedModeBanner: false,
                      title: switch (Env.flavor) {
                        Flavor.prod => 'Stone',
                        Flavor.dev => 'Stone Dev',
                        _ => 'Stone Dev',
                      },
                      theme: isDark && !isSystemTheme ? Themes.darkTheme : Themes.lightTheme,
                      darkTheme: isDark || (context.platformDark && isSystemTheme) ? Themes.darkTheme : null,
                      navigatorKey: Navigate.navigatorKey,
                      onGenerateRoute: onGenerateRoute,
                      initialRoute: initialRoute,
                      locale: locale,
                      supportedLocales: locales.supportedLocales,
                      localizationsDelegates: AppLocalizations.localizationsDelegates,
                    );
                  }
                );
              }
            );
          }
        ),
      ),
    );
  }
  
  @override
  List<MicroApp> get microApps => [
    AuthMicroapp(),
    ExploreMicroapp(),
    NotificationMicroapp(),
    WalletMicroapp(),
    UserMicroapp(),
    PostMicroapp(),
  ];

  @override
  Map<String, BasisRoute> get basisRoutes => {
    super.initialRoute: BasisRoute(
      (context, args) => Splash(
        controller: locator(),
        walletController: locator(),
        userController: locator(),
        args: args as WrapperArgs? ?? WrapperArgs(fromBackgroundNotification: false),
      ),
      transitionType: TransitionType.leftToRight,
    ),
    Routes.wrapper: BasisRoute(
      (context, args) => NavigatorWrapper(
        onGenerateRoute: onGenerateRoute,
        bottomBarMain: CreatePostScreen(
          walletController: locator(),
          getUserBloc: locator(),
          postController: locator(),
          userController: locator(),
          getPostsBloc: locator(),
          getPostCommentsBloc: locator(),
        ),
      ),
      transitionType: TransitionType.leftToRight,
    ),
  };

  @override
  Map<String, BasisRoute> get routes => super.registeredRoutes;

  @override
  Map<String, BasisRoute>? get basisNestedRoutes => {};
}