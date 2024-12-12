import 'package:auth_microapp/auth_microapp.dart';
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
import 'home.dart';
import 'splash.dart';

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
        onMessageOpenedApp: _handleReceivedNotification,
      );
    });
  }

  void _handleReceivedNotification(Notification _) {
    Navigate.to.pushReplacementNamed(
      super.initialRoute,
      arguments: SplashArgs(fromBackgroundNotification: true),
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
                      debugShowCheckedModeBanner: Env.isDev,
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
    super.initialRoute: BasisRoute((context, args) => Splash(
      controller: locator(),
      walletController: locator(),
      userController: locator(),
      args: args as SplashArgs? ?? SplashArgs(fromBackgroundNotification: false),
    )),
    Routes.wrapper: BasisRoute(
      (context, args) => NavigatorWrapper(
        bottomBarMain: CreatePostScreen(
          walletController: locator(),
          getUserBloc: locator(),
          postController: locator(),
          userController: locator(),
          getPostsBloc: locator(),
          getCommentsByPostBloc: locator(),
        ),

        onGenerateRoute: (routerSettings) => onGenerateRoute(routerSettings, super.nestedRoutes),
      ),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  };

  @override
  Map<String, BasisRoute> get routes => super.registeredRoutes;

  @override
  Map<String, BasisRoute>? get basisNestedRoutes => {
    Routes.home: BasisRoute(
      (context, args) => Home(
        getPostsBloc: locator(),
        getUserBloc: locator(),
        userController: locator(),
        walletController: locator(),
      ),
      transitionType: TransitionType.fadeIn,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  };
}