import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/period/period.dart';
import 'package:fourteen_november/shared/app_wrapper.dart';
import 'package:fourteen_november/shared/app_messenger.dart';
import 'package:fourteen_november/shared/default_app_bar.dart';
import 'package:fourteen_november/shared/dialogs/add_period_dialog/add_period_dialog.dart';
import 'package:fourteen_november/theme/app_colors.dart';

part 'widgets/view.dart';
part 'widgets/calendar/calendar.dart';
part 'widgets/calendar/widgets/day_cell.dart';
part 'widgets/stats/stats.dart';
part 'widgets/list/list.dart';
part 'widgets/list/widgets/tile.dart';

class PeriodScreen extends StatelessWidget {
  PeriodScreen({super.key});

  final periodRepository = PeriodRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: const Text("ردیاب دوره")),
      body: AppWrapper(
        child: ValueListenableBuilder(
          valueListenable: periodRepository.listenableBox(),
          builder: (context, Box<Period> box, _) {
            final periods = periodRepository.getAllFromBox(box)
              ..sort((a, b) => b.periodDate.compareTo(a.periodDate));
            return _View(periods: periods, onRefresh: () => _refresh(context));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPeriodDialog(context),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("ثبت شروع دوره"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _showAddPeriodDialog(BuildContext context) async {
    final result = await showAddPeriodDialog(context);
    if (result != null && context.mounted) {
      AppMessenger.showSuccess(context, 'تاریخ شروع دوره ثبت شد 💗');
    }
  }

  Future<void> _refresh(BuildContext context) async {
    try {
      await periodRepository.hardRefresh();
      if (context.mounted) {
        AppMessenger.showSuccess(context, 'رفرش شد! ✨');
      }
    } catch (_) {
      if (!context.mounted) return;
      AppMessenger.showError(
        context,
        'نتونستم رفرش کنم! یبار دیگه بکش پایین 😅',
      );
    }
  }
}
