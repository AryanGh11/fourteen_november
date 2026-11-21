part of '../../period_screen.dart';

class _List extends StatelessWidget {
  final List<Period> periods;
  const _List({required this.periods});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تاریخچه شروع‌ها',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${periods.length} تاریخ ثبت شده',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...periods.map((period) => _Tile(period: period)),
        ],
      ),
    );
  }
}
