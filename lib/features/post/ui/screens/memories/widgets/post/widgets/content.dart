part of '../../../memories_screen.dart';

class _Content extends StatelessWidget {
  final Post post;

  const _Content({required this.post});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final formattedCreatedAt = intl.DateFormat(
      'dd MMM yy / HH:mm',
    ).format(post.created);

    return Container(
      decoration: BoxDecoration(color: colors.surface.withValues(alpha: 0.5)),
      padding: EdgeInsets.all(8),
      child: Row(
        spacing: 8,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(post.user.avatarUrl),
            backgroundColor: colors.surfaceContainer,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.user.name, style: textTheme.labelSmall),
              Text(
                formattedCreatedAt,
                style: textTheme.labelSmall?.copyWith(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
