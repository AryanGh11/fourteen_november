part of '../gift_screen.dart';

/// Shown over the last frame once the video ends: the way into the gift.
class _Reveal extends StatelessWidget {
  final String title;
  final bool saving;

  /// Whether the gift has already been opened once, which changes the button
  /// from a first opening to an "open again".
  final bool opened;

  final VoidCallback onOpen;
  final VoidCallback onWatchAgain;

  const _Reveal({
    required this.title,
    required this.saving,
    required this.opened,
    required this.onOpen,
    required this.onWatchAgain,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Fades and blurs in over the final frame of the video, rather than
    // cutting to a new screen, so the ending flows straight into the gift.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12 * t, sigmaY: 12 * t),
          child: Container(
            color: colors.surface.withValues(alpha: 0.55 * t),
            child: Opacity(
              opacity: t,
              child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
            ),
          ),
        );
      },
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.gift,
                    size: 40,
                    color: AppColors.secondary,
                  ),
                ),
                if (title.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: saving ? null : onOpen,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      // A light pastel, so dark text keeps the label readable.
                      foregroundColor: AppColors.lightTextPrimary,
                      disabledBackgroundColor: AppColors.secondary.withValues(
                        alpha: 0.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      textStyle: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: saving
                        ? const CustomCircularProgressIndicator(
                            size: 22,
                            color: AppColors.lightTextPrimary,
                          )
                        : Text(opened ? "Open again" : "Open your gift 🎁"),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: saving ? null : onWatchAgain,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.onSurface.withValues(alpha: 0.7),
                  ),
                  child: const Text("Watch again"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
