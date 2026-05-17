import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/shared/custom_slider.dart';
import 'package:fourteen_november/shared/modals/base_modal.dart';
import 'package:fourteen_november/shared/buttons/loading_elevated_button.dart';

part 'widgets/form.dart';

Future<Mood?> showAddMoodModal(BuildContext context) async {
  return await showModalBottomSheet(
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
  double _value = 1;
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BaseModal(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Text(
            "Welcome! Wer bist du?",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 30),
          _Form(
            formKey: _formKey,
            noteController: _noteController,
            value: _value,
            onValueChanged: _onValueChanged,
            noteValidator: _noteValidator,
            onSubmit: _onSubmit,
            submitting: _submitting,
          ),
        ],
      ),
    );
  }

  String? _noteValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a note';
    }

    return null;
  }

  void _onValueChanged(double newValue) {
    setState(() {
      _value = newValue;
    });
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final note = _noteController.text.trim();

    setState(() {
      _submitting = true;
    });

    try {
      final res = await MoodRepository().create(
        MoodCreatePayload(note: note, value: _value.toInt()),
      );
      if (mounted) context.pop(res);
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }
}
