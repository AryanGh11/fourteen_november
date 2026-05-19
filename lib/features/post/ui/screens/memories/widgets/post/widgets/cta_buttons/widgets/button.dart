part of '../../../../../memories_screen.dart';

class _CTAButton extends StatelessWidget {
  final int count;
  final Widget icon;
  final Future<void> Function()? onTap;

  const _CTAButton({
    required this.count,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(minWidth: 40),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          spacing: 4,
          children: [
            icon,
            Text(
              count.toString(),
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
