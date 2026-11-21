part of '../home_screen.dart';

class _SectionTitle extends StatelessWidget {
  final String title, action;
  final VoidCallback onTap;
  const _SectionTitle({
    required this.title,
    required this.action,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 20, 2, 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(onPressed: onTap, child: Text('$action  →')),
      ],
    ),
  );
}
