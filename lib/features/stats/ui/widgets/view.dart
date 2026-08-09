part of '../stats_screen.dart';

class _View extends StatelessWidget {
  final double distanceInKm;
  final Duration sinceLastVisit;
  final String togetherFor;
  final int memoriesCount;
  final int moodsCount;

  const _View({
    required this.distanceInKm,
    required this.sinceLastVisit,
    required this.togetherFor,
    required this.memoriesCount,
    required this.moodsCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _Tile(title: 'Since Our Last Hug', value: sinceLastVisit.prettyInDays),
        _Tile(
          title: 'Miles Apart, Hearts Together 🤍',
          value: '${distanceInKm.ceil()} km',
        ),
        _Tile(title: 'Together for', value: togetherFor),
        _Tile(title: '$memoriesCount Memories created', value: ''),
        _Tile(title: '$moodsCount Mood Check-ins', value: ''),
      ],
    );
  }
}
