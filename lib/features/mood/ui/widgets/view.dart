part of '../mood_screen.dart';

class _View extends StatelessWidget {
  final List<Mood> moods;
  final Future<void> Function() onRefresh;

  const _View({required this.moods, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await onRefresh(),
      child: SizedBox(child: _List(moods: moods)),
    );
  }
}
