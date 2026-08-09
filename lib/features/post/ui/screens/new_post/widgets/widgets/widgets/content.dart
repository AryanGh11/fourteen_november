part of '../../../new_post_screen.dart';

class _Content extends StatelessWidget {
  final User user;

  const _Content({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(color: colors.surface),
      padding: EdgeInsets.all(8),
      child: Row(
        spacing: 8,
        children: [
          CustomCircleAvatar(url: user.avatarUrl, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: textTheme.labelSmall),
              Text(
                DateFormatter.format(date: DateTime.now()),
                style: textTheme.labelSmall?.copyWith(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
