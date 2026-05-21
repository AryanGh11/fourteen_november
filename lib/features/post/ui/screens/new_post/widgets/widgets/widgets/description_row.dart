part of '../../../new_post_screen.dart';

class _DescriptionRow extends StatelessWidget {
  final User user;
  final TextEditingController descriptionController;

  const _DescriptionRow({
    required this.user,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          user.name,
          style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: TextField(
            controller: descriptionController,
            style: textTheme.labelSmall,
            decoration: const InputDecoration(
              hintText: "Write something...",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: 10,
          ),
        ),
      ],
    );
  }
}
