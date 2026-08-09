part of '../../stats_screen.dart';

class _Tile extends StatelessWidget {
  final String title;
  final String value;

  const _Tile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(value),
        ],
      ),
    );
  }
}
