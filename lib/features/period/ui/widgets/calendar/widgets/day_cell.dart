part of '../../../period_screen.dart';

class _DayCell extends StatelessWidget {
  final int day;
  final DateTime date;
  final bool isToday;
  final bool hasPeriod;
  final Period? period;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.date,
    required this.isToday,
    required this.hasPeriod,
    this.period,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getBackgroundColor(colors),
          border: isToday ? Border.all(color: colors.primary, width: 2) : null,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              Text(
                '$day',
                style: textTheme.labelLarge?.copyWith(
                  color: _getTextColor(colors),
                  fontWeight: isToday || hasPeriod
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
              if (hasPeriod)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ColorScheme colors) {
    if (hasPeriod) {
      return AppColors.accent.withValues(alpha: 0.2);
    }
    if (isToday) {
      return colors.primary.withValues(alpha: 0.1);
    }
    return Colors.transparent;
  }

  Color _getTextColor(ColorScheme colors) {
    if (hasPeriod) {
      return AppColors.accent;
    }
    if (isToday) {
      return colors.primary;
    }
    return colors.onSurface;
  }
}
