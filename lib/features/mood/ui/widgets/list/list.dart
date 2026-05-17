part of '../../mood_screen.dart';

class _List extends StatelessWidget {
  final List<Mood> moods;

  const _List({required this.moods});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        final item = moods[index];
        return _Tile(mood: item);
      },
      separatorBuilder: (_, __) => SizedBox(height: 10),
      itemCount: moods.length,
    );
  }
}
