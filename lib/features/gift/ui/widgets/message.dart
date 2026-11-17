part of '../gift_screen.dart';

/// Shown when the gift cannot be opened: not here yet, or no connection.
class _Message extends StatelessWidget {
  final VoidCallback onRetry;

  const _Message({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Icon(
              LucideIcons.gift,
              size: 40,
              color: colors.onSurface.withValues(alpha: 0.4),
            ),
            Text(
              'هدیه باز نشد! نت رو چک کن و دوباره امتحان کن',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text("Try again")),
          ],
        ),
      ),
    );
  }
}
