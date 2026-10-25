import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi, DateFormat;
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fourteen_november/theme/dark_theme.dart';
import 'package:fourteen_november/theme/app_colors.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/app_messenger.dart';
import 'package:fourteen_november/features/alert/alert.dart';
import 'package:fourteen_november/shared/profile_avatar.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/shared/loading_icon_button.dart';
import 'package:fourteen_november/core/router/route_provider.dart';
import 'package:fourteen_november/shared/animated_background.dart';
import 'package:fourteen_november/features/background/background.dart';
import 'package:fourteen_november/shared/modals/select_user_modal/select_user_modal.dart';

part './widgets/alert/alert.dart';
part './widgets/alert/widgets/card.dart';
part './widgets/tiles/tiles.dart';
part './widgets/tiles/widgets/tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _backgroundRepository = BackgroundRepository();

  bool _hardRefreshing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSelectUserModal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 20),
          child: ProfileAvatar(),
        ),
        title: Text("14 November 💕"),
        foregroundColor: Colors.white,
        actions: [
          LoadingIconButton(
            onPressed: _onHardRefresh,
            icon: Icon(Icons.refresh),
            loading: _hardRefreshing,
            loadingColor: Colors.white,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Theme(
        data: darkTheme,
        child: Stack(
          children: [
            Positioned.fill(
              // Watches the cache rather than reading it once, so a
              // background added from the backgrounds screen joins the
              // rotation as soon as you come back here.
              child: ValueListenableBuilder(
                valueListenable: _backgroundRepository.listenableBox(),
                builder: (context, Box<Background> box, _) {
                  final backgrounds = _backgroundRepository.getAllFromBox(box)
                    ..shuffle();

                  return AnimatedBackground(
                    images: backgrounds.map((b) => b.imageUrl).toList(),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
            AppWrapper(child: Center(child: _Tiles())),
            const _Alert(),
          ],
        ),
      ),
    );
  }

  Future<void> _showSelectUserModal() async {
    final user = UserProviderService().current;

    if (!mounted) return;

    if (user == null) {
      final selectedUser = await showSelectUserModal(context);

      if (selectedUser == null) return;

      await UserProviderService().update(selectedUser.id);
    }
  }

  Future<void> _onHardRefresh() async {
    setState(() {
      _hardRefreshing = true;
    });
    try {
      await HiveService.hardRefreshBoxes();
    } catch (_) {
      if (!mounted) return;
      AppMessenger.showError(context, 'نت عالیه! یبار دیگه بزن نفس');
    } finally {
      setState(() {
        _hardRefreshing = false;
      });
    }
  }
}
