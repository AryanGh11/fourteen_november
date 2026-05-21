import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/shared/app_messenger.dart';
import 'package:fourteen_november/shared/custom_slider.dart';
import 'package:fourteen_november/shared/buttons/loading_elevated_button.dart';

part 'widgets/form.dart';

Future<Mood?> showAddMoodDialog(BuildContext context) async {
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
  final _noteController = TextEditingController();
  double _value = 3;
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();

    super.dispose();
  }

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
                "حالت چطوره نفس؟",
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              _Form(
                formKey: _formKey,
                noteController: _noteController,
                value: _value,
                onValueChanged: _onValueChanged,
                onSubmit: _create,
                submitting: _submitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onValueChanged(double newValue) {
    setState(() {
      _value = newValue;
    });
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    final note = _noteController.text.trim();

    setState(() {
      _submitting = true;
    });

    try {
      final res = await MoodRepository().create(
        MoodCreatePayload(
          note: note.isNotEmpty ? note : null,
          value: _value.toInt(),
        ),
      );
      if (mounted) context.pop(res);
    } catch (_) {
      if (!mounted) return;
      AppMessenger.showError(context, 'مودت ثبت نشد! یبار دیگه بزن لطفا');
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }
}
