import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/core/router/route_provider.dart';
import 'package:fourteen_november/shared/animated_background.dart';
import 'package:fourteen_november/features/background/background.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';
import 'package:fourteen_november/shared/modals/select_user_modal/select_user_modal.dart';

part './widgets/tiles/tiles.dart';
part './widgets/tiles/widgets/tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final pb = PocketBaseService.I.instance;

  List<String>? _backgroundsUrls;

  @override
  void initState() {
    _showSelectUserModal();
    _fetchBackgrounds();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: Text("14 November 💕")),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: _backgroundsUrls == null
                ? Container()
                : AnimatedBackground(images: _backgroundsUrls!),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.6)),
          ),
          AppWrapper(child: Center(child: _Tiles())),
        ],
      ),
    );
  }

  Future<void> _showSelectUserModal() async {
    final user = UserProviderService().current;

    if (!mounted) return;

    if (user == null) {
      final selectedUser = await showSelectUserModal(context);

      if (selectedUser == null) return;

      await UserProviderService().update(selectedUser);
    }
  }

  Future<void> _fetchBackgrounds() async {
    final res = await BackgroundRepository().getAll();

    final urls = await Future.wait(res.map((item) => item.imageUrl));

    setState(() {
      _backgroundsUrls = urls;
    });
  }
}
