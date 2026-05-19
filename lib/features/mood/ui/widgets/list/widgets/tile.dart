part of '../../../mood_screen.dart';

class _Tile extends StatelessWidget {
  final Mood mood;

  const _Tile({required this.mood});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surface,
      child: Row(children: [Text(mood.note ?? "")]),
    );
  }
}
