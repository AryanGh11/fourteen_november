import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/stats/stats.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/app_messenger.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/core/extensions/duration.dart';
import 'package:fourteen_november/core/extensions/date_time.dart';

part 'widgets/view.dart';
part 'widgets/widgets/tile.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _generalStatsRepository = GeneralStatsRepository();

  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {});
    });

    // Update user's location
    UserProviderService().updateLocation();

    _refreshStats();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: Text("Stats")),
      body: AppWrapper(
        child: Center(
          child: _View(
            distanceInKm: _getDistanceInKm(),
            sinceLastVisit: _getSinceLastTimeVisit(),
            togetherFor: _getTogetherFor(),
            memoriesCount: _getMemoriesCount(),
            moodsCount: _getMoodsCount(),
            onRefresh: _refresh,
          ),
        ),
      ),
    );
  }

  /// Picks up dates changed on the server since they were cached, such as
  /// [GeneralStats.lastHugAt] after a visit. Silent on failure: the cached
  /// copy keeps the screen counting in the meantime.
  Future<void> _refreshStats() async {
    await _generalStatsRepository.hardRefresh();

    if (mounted) setState(() {});
  }

  /// Pulls everything the stats are worked out from: the dates, the users
  /// for distance, and the posts and moods behind the counts. Run together,
  /// since none depends on another.
  Future<void> _refresh() async {
    try {
      await Future.wait([
        _generalStatsRepository.hardRefresh(),
        UserRepository().hardRefresh(),
        PostRepository().hardRefresh(),
        MoodRepository().hardRefresh(),
      ]);
    } catch (_) {
      if (!mounted) return;
      AppMessenger.showError(
        context,
        'بخاطر نت پرسرعت ایران رفرش نشد! لطفا دوباره بکش پایین...',
      );
    } finally {
      if (mounted) setState(() {});
    }
  }

  /// `null` until both users are cached, rather than reading past the end of
  /// the list.
  double? _getDistanceInKm() {
    final users = UserRepository().getAll();

    if (users.length < 2) return null;

    final distance = Distance();

    final meters = distance(
      LatLng(users[0].locationLat, users[0].locationLng),
      LatLng(users[1].locationLat, users[1].locationLng),
    );

    return meters / 1000;
  }

  /// `null` until the stats have been fetched at least once.
  Duration? _getSinceLastTimeVisit() {
    final lastHugAt = _generalStatsRepository.current?.lastHugAt;

    if (lastHugAt == null) return null;

    return DateTime.now().difference(lastHugAt);
  }

  /// `null` until the stats have been fetched at least once.
  String? _getTogetherFor() {
    final togetherSince = _generalStatsRepository.current?.togetherSince;

    if (togetherSince == null) return null;

    return DateTime.now().getTogetherFor(togetherSince);
  }

  int _getMemoriesCount() {
    final postRepository = PostRepository();
    return postRepository.getAll().length;
  }

  int _getMoodsCount() {
    final moodRepository = MoodRepository();
    return moodRepository.getAll().length;
  }
}
