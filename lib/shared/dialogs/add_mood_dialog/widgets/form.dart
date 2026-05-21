part of '../add_mood_dialog.dart';

class _Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController noteController;
  final double value;
  final void Function(double value) onValueChanged;
  final bool submitting;
  final Future<void> Function() onSubmit;

  const _Form({
    required this.formKey,
    required this.noteController,
    required this.value,
    required this.onValueChanged,
    required this.submitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Mood.getIconForValue(value.toInt()),
            size: 60,
            color: Mood.getColorForValue(value.toInt()),
          ),
          SizedBox(),
          CustomSlider(value: value, onChanged: onValueChanged),
          SizedBox(),
          TextFormField(
            controller: noteController,
            decoration: InputDecoration(
              labelText: 'Note',
              alignLabelWithHint: true,
              labelStyle: textTheme.labelMedium?.copyWith(
                color: colors.onSurface,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: colors.onSurface.withValues(alpha: 0.25),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.onSurface),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: textTheme.labelMedium,
            textInputAction: TextInputAction.done,
            maxLines: 5,
          ),
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
