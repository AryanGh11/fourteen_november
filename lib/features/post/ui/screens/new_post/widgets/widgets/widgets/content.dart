part of '../../../new_post_screen.dart';

class _Content extends StatelessWidget {
  final User user;

  const _Content({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final formattedCreatedAt = intl.DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(DateTime.now());

    return Container(
      decoration: BoxDecoration(color: colors.surface),
      padding: EdgeInsets.all(8),
      child: Row(
        spacing: 8,
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: CustomCachedNetworkImage(
              imageUrl: user.avatarUrl,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: textTheme.labelSmall),
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
