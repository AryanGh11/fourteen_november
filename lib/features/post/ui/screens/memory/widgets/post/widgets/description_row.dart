part of '../../../memory_screen.dart';

class _DescriptionRow extends StatelessWidget {
  final Post post;
  final User? postUser;

  const _DescriptionRow({required this.post, required this.postUser});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 6,
      children: [
        Text(
          postUser?.name ?? "",
          style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(post.description, style: textTheme.labelSmall),
      ],
    );
  }
}
