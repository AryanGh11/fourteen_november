part of '../../period_screen.dart';

class _Stats extends StatelessWidget {
  final List<Period> periods;
  const _Stats({required this.periods});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Derive intervals from start dates so backfilled entries are represented.
    final dates =
        periods
            .map(
              (p) => DateTime(
                p.periodDate.year,
                p.periodDate.month,
                p.periodDate.day,
              ),
            )
            .toSet()
            .toList()
          ..sort();
    final intervals = <int>[];
    for (var i = 1; i < dates.length; i++) {
      intervals.add(dates[i].difference(dates[i - 1]).inDays);
    }
    final average = intervals.isEmpty
        ? null
        : intervals.reduce((a, b) => a + b) / intervals.length;
    final next = average == null
        ? null
        : dates.last.add(Duration(days: average.round()));
    final today = DateUtils.dateOnly(DateTime.now());
    final days = next == null
        ? null
        : DateUtils.dateOnly(next).difference(today).inDays;
    final estimate = days == null
        ? 'با ثبت دوره بعدی، یک تخمین می‌بینی'
        : days > 0
        ? '$days روز تا تاریخ تخمینی'
        : days == 0
        ? 'تاریخ تخمینی: امروز'
        : 'تاریخ تخمینی گذشته است';

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'آخرین شروع',
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            periods.first.formattedDate,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Divider(color: colors.outlineVariant.withValues(alpha: .5)),
          const SizedBox(height: 8),
          Text(
            estimate,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            average == null
                ? 'برای محاسبه فاصله، حداقل دو تاریخ شروع لازمه.'
                : 'میانگین فاصله شروع‌ها: ${average.round()} روز · این فقط یک تخمینه و ممکنه تغییر کنه.',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
