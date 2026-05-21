part of '../../../../mood_screen.dart';

class _TileContent extends StatelessWidget {
  final Mood mood;

  const _TileContent({required this.mood});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final formattedCreatedAt = intl.DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(mood.created);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(
                      Mood.getIconForValue(mood.value),
                      color: Mood.getColorForValue(mood.value),
                      size: 32,
                    ),
                    Expanded(
                      child: Text(
                        mood.note ?? "---",
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  formattedCreatedAt,
                  style: textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            spacing: 4,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                width: 32,
                height: 32,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: CachedNetworkImage(imageUrl: mood.user.avatarUrl),
              ),
              Text(mood.user.name, style: textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
