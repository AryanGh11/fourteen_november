part of '../stats_screen.dart';

/// Shown for a value that has not been loaded yet, e.g. on a first launch
/// with no connection.
const _missing = '—';

class _View extends StatelessWidget {
  final double? distanceInKm;
  final Duration? sinceLastVisit;
  final String? togetherFor;
  final int memoriesCount;
  final int moodsCount;
  final Future<void> Function() onRefresh;

  const _View({
    required this.distanceInKm,
    required this.sinceLastVisit,
    required this.togetherFor,
    required this.memoriesCount,
    required this.moodsCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await onRefresh(),
      child: ListView(
        // A short list cannot otherwise be pulled on Android, so the
        // indicator would never trigger.
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _Tile(
            title: 'Since Our Last Hug',
            value: sinceLastVisit?.prettyInDays ?? _missing,
          ),
          _Tile(
            title: 'Miles Apart, Hearts Together 🤍',
            value: distanceInKm == null
                ? _missing
                : '${distanceInKm!.ceil()} km',
          ),
          _Tile(title: 'Together for', value: togetherFor ?? _missing),
          _Tile(title: '$memoriesCount Memories created', value: ''),
          _Tile(title: '$moodsCount Mood Check-ins', value: ''),
        ],
      ),
    );
  }
}
