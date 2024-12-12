import 'package:core/core.dart';
import 'package:desys/desys.dart';
import 'splash.dart';
import 'package:dependencies/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:post_microapp/post_microapp.dart';
import 'package:ui/ui.dart';
import 'package:user_microapp/user_microapp.dart';
import 'package:wallet_microapp/wallet_microapp.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.walletController,
    required this.getUserBloc,
    required this.userController,
    required this.getPostsBloc,
    this.args,
  });

  final WalletController walletController;
  final GetUserBloc getUserBloc;
  final UserController userController;
  final GetPostsBloc getPostsBloc;
  final SplashArgs? args;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    isPopupOpen = false;
    _scrollController = ScrollController();

    if (currentUser != null) {
      widget.getUserBloc.emit(
        GetUserEvent(
          pubKey: currentUser!.pubKey,
          isLoggedUser: true,
        ),
      );
    }

    _handleBackgroundNotification();

    super.initState();
  }

  void _handleBackgroundNotification() {
    if ((widget.args?.fromBackgroundNotification ?? false) &&
        currentUser?.pubKey != null) {
      BottomBarController.pushNamed(
        Routes.profile,
        arguments: ProfileScreenArgs(
          fromBackgroundNotification:
              widget.args?.fromBackgroundNotification ?? false,
        ),
      );
    }
  }

  void _fetch() {
    PostInteractionViewmodel.resetFeed(
      onReset: () => widget.getPostsBloc.emit(
        GetPostsEvent(page: 1, limit: 40, hardReset: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    setSystemUIOverlayStyle(dark: context.isDark);

    return ScaffoldWrapper(
      body: PaddingTop(
        child: StnRefreshIndicator(
          onRefresh: _fetch,
          fixed: true,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              // SliverAppBar(
              //   automaticallyImplyLeading: false,
              //   backgroundColor: Colors.transparent,
              //   surfaceTintColor: Colors.transparent,
              //   expandedHeight: 42,
              //   toolbarHeight: 10,
              //   flexibleSpace: FlexibleSpaceBar(
              //     titlePadding: EdgeInsets.zero,
              //     expandedTitleScale: 1.1,
              //     background: Align(child: context.logo(40)),
              //   ),
              // ),
              SliverToBoxAdapter(
                child: AppScrollView(
                  scrollController: _scrollController,
                  nestedScroll: true,
                  child: PostsView(
                    bloc: widget.getPostsBloc,
                    scrollController: _scrollController,
                    postController: locator(),
                    canHandleOwnPost: false,
                    bottomBarConstraintsHeight: 65,
                    canPop: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
