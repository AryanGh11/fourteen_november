part of '../../period_screen.dart';

class _Calendar extends StatefulWidget {
  final List<Period> periods;

  const _Calendar({required this.periods});

  @override
  State<_Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<_Calendar> {
  late DateTime _focusedMonth;

  static const _weekdays = ['ی', 'د', 'س', 'چ', 'پ', 'ج', 'ش'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final daysInMonth = _getDaysInMonth(_focusedMonth);
    final firstWeekday = _focusedMonth.weekday % 7; // 0 = Sunday
    final periodDates = widget.periods
        .map(
          (p) =>
              DateTime(p.periodDate.year, p.periodDate.month, p.periodDate.day),
        )
        .toSet();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        spacing: 16,
        children: [
          // Month header with navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: colors.primary),
                onPressed: () => setState(() {
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month - 1,
                  );
                }),
              ),
              Text(
                _formatMonth(_focusedMonth),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: colors.primary),
                onPressed: () => setState(() {
                  _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month + 1,
                  );
                }),
              ),
            ],
          ),
          Text(
            "تقویم میلادی · دایره صورتی یعنی شروع ثبت‌شده",
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdays
                .map(
                  (day) => SizedBox(
                    width: 28,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                return const SizedBox.shrink();
              }
              final day = index - firstWeekday + 1;
              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                day,
              );
              final isToday = date == todayDate;
              final hasPeriod = periodDates.contains(date);
              final period = widget.periods.firstWhere(
                (p) =>
                    DateTime(
                      p.periodDate.year,
                      p.periodDate.month,
                      p.periodDate.day,
                    ) ==
                    date,
                orElse: () => widget
                    .periods
                    .first, // fallback, won't be used due to hasPeriod check
              );

              return _DayCell(
                day: day,
                date: date,
                isToday: isToday,
                hasPeriod: hasPeriod,
                period: hasPeriod ? period : null,
                onTap: hasPeriod
                    ? () => _showPeriodDetails(context, period)
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  int _getDaysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  String _formatMonth(DateTime month) {
    const months = [
      'ژانویه',
      'فوریه',
      'مارس',
      'آوریل',
      'مه',
      'ژوئن',
      'ژوئیه',
      'اوت',
      'سپتامبر',
      'اکتبر',
      'نوامبر',
      'دسامبر',
    ];
    return '${months[month.month - 1]} ${month.year}';
  }

  void _showPeriodDetails(BuildContext context, Period period) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      period.formattedDate,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (period.hasPreviousPeriod) ...[
                _buildInfoRow(
                  context,
                  Icons.arrow_back,
                  "از دوره قبل",
                  "${period.daysFromPrevious} روز",
                  colors,
                  textTheme,
                ),
              ],
              if (period.hasCycleLength) ...[
                _buildInfoRow(
                  context,
                  Icons.repeat,
                  "فاصله تا شروع بعدی",
                  "${period.cycleLength} روز",
                  colors,
                  textTheme,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "باشه",
                      style: TextStyle(color: colors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}
