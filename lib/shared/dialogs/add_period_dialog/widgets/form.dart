part of '../add_period_dialog.dart';

class _Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onSubmit;
  final bool submitting;

  const _Form({
    required this.formKey,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onSubmit,
    required this.submitting,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Form(
      key: formKey,
      child: Column(
        spacing: 16,
        children: [
          // Date picker field
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: colors.primary,
                        onPrimary: colors.onPrimary,
                        surface: colors.surface,
                        onSurface: colors.onSurface,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onDateChanged(picked);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.accent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatPersianDate(selectedDate),
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
          // Submit button
          LoadingElevatedButton(
            onPressed: onSubmit,
            loading: submitting,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.accent),
            ),
            child: const Text("ثبت تاریخ"),
          ),
        ],
      ),
    );
  }

  String _formatPersianDate(DateTime date) {
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
    const weekdays = [
      'یکشنبه',
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنج‌شنبه',
      'جمعه',
      'شنبه',
    ];
    final weekday = weekdays[date.weekday % 7];
    return '$weekday، ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
