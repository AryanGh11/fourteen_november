part of '../../../../posts_screen.dart';

class _DescriptionRow extends StatelessWidget {
  final Post post;

  const _DescriptionRow({required this.post});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          post.user.name,
          style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            post.description,
            style: textTheme.labelSmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 999,
          ),
        ),
      ],
    );
  }
}
