part of '../../../home_screen.dart';

class _Tile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;

  const _Tile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final color = disabled
        ? colors.onSurface.withValues(alpha: 0.2)
        : colors.primary;

    return Material(
      clipBehavior: Clip.hardEdge,
      color: colors.surfaceContainer,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        splashColor: color.withValues(alpha: 0.05),
        highlightColor: color.withValues(alpha: 0.05),
        onTap: disabled ? null : onTap,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Icon(icon, size: 40, color: color),
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(color: color),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
