import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fourteen_november/features/period/period.dart';
import 'package:fourteen_november/shared/app_messenger.dart';
import 'package:fourteen_november/shared/buttons/loading_elevated_button.dart';

part 'widgets/form.dart';

Future<Period?> showAddPeriodDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return _Content();
    },
  );
}

class _Content extends StatefulWidget {
  const _Content();

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "شروع دوره‌تو ثبت کن",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "اولین روز دوره‌ت کی بود؟",
                textDirection: TextDirection.rtl,
                style: textTheme.bodyMedium,
              ),
              _Form(
                formKey: _formKey,
                selectedDate: _selectedDate,
                onDateChanged: _onDateChanged,
                onSubmit: _create,
                submitting: _submitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
    });

    try {
      final res = await PeriodRepository().create(
        PeriodCreatePayload(
          periodDate: DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
          ),
        ),
      );
      if (mounted) context.pop(res);
    } catch (e) {
      if (!mounted) return;
      debugPrint("Period create error: $e");
      AppMessenger.showError(
        context,
        'نمی‌تونم ذخیره کنم! یبار دیگه امتحان کن لطفا 😅',
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}
