part of '../add_mood_modal.dart';

class _Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController noteController;
  final double value;
  final void Function(double value) onValueChanged;
  final String? Function(String?)? noteValidator;
  final bool submitting;
  final Future<void> Function() onSubmit;

  const _Form({
    required this.formKey,
    required this.noteController,
    required this.value,
    required this.onValueChanged,
    required this.noteValidator,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'Note',
              hintText: 'How are you feeling?',
            ),
            validator: noteValidator,
          ),
          CustomSlider(value: value, onChanged: onValueChanged),
          LoadingElevatedButton(
            loading: submitting,
            onPressed: () async {
              FocusScope.of(context).unfocus();
              await onSubmit();
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }
}
