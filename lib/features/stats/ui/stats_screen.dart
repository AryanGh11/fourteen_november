import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/core/extensions/duration.dart';
import 'package:fourteen_november/core/extensions/date_time.dart';

part 'widgets/view.dart';
part 'widgets/widgets/tile.dart';

final _lastTimeVisitAt = DateTime(2026, 4, 4, 23, 0, 0, 0, 0);
final _firstTimeVisitAt = DateTime(2025, 11, 14, 19, 0, 0, 0, 0);

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {});
    });
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
          ),
        ),
      ),
    );
  }

  double _getDistanceInKm() {
    final users = UserRepository().getAll();
    final distance = Distance();

    final meters = distance(
      LatLng(users[0].locationLat, users[0].locationLng),
      LatLng(users[1].locationLat, users[1].locationLng),
    );

    return meters / 1000;
  }

  Duration _getSinceLastTimeVisit() {
    return DateTime.now().difference(_lastTimeVisitAt);
  }

  String _getTogetherFor() {
    return DateTime.now().getTogetherFor(_firstTimeVisitAt);
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
