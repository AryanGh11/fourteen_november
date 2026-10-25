part of '../../../home_screen.dart';

/// The visual body of an in-app alert.
///
/// One card serves every alert; [celebratory] only shifts its accent and icon,
/// so occasions like the monthly anniversary feel warmer without needing a
/// separate dialog with its own open and close handling.
class _AlertCard extends StatelessWidget {
  final Alert alert;
  final bool celebratory;
  final VoidCallback onClose;

  const _AlertCard({
    required this.alert,
    required this.celebratory,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final tint = celebratory ? AppColors.accent : colors.primary;

    return Dialog(
      backgroundColor: colors.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  celebratory ? LucideIcons.heart : LucideIcons.bellRing,
                  color: tint,
                  size: 26,
                ),
              ),
              const SizedBox(height: 18),
              if (alert.title.isNotEmpty) ...[
                Text(
                  alert.title,
                  textAlign: TextAlign.center,
                  textDirection: _directionOf(alert.title),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // Scrolls rather than overflowing, so a long message still fits
              // on a small phone with the button kept in reach below it.
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    alert.content,
                    textAlign: TextAlign.center,
                    textDirection: _directionOf(alert.content),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.72),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (alert.dismissible)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: onClose,
                    style: FilledButton.styleFrom(
                      backgroundColor: tint,
                      // Both accents are light pastels, so dark text keeps the
                      // label readable on either.
                      foregroundColor: AppColors.lightTextPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: celebratory
                        ? Icon(LucideIcons.thumbsUp, size: 20)
                        : const Text("باجه"),
                  ),
                )
              else
                // Without a button the reader would otherwise have no idea why
                // it cannot be closed, or for how long it will stay.
                Text(
                  "Showing until ${_formatEnd(alert.endAt)}",
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Alerts mix Persian and English, so direction follows the text itself
  /// rather than the app locale.
  static TextDirection _directionOf(String text) {
    return Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// Time alone when the alert ends today, otherwise with the date too.
  static String _formatEnd(DateTime end) {
    final now = DateTime.now();

    final sameDay =
        end.year == now.year && end.month == now.month && end.day == now.day;

    return sameDay
        ? DateFormat.Hm().format(end)
        : DateFormat('d MMM, HH:mm').format(end);
  }
}
