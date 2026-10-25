part of '../profile_screen.dart';

class _View extends StatelessWidget {
  final User user;
  final TextEditingController nameController;
  final bool uploadingAvatar;
  final bool savingName;
  final VoidCallback? onChangeAvatar;
  final Future<void> Function()? onSaveName;

  const _View({
    required this.user,
    required this.nameController,
    required this.uploadingAvatar,
    required this.savingName,
    required this.onChangeAvatar,
    required this.onSaveName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      // Scrolls so the keyboard never covers the field on a small phone.
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        Center(
          child: _Avatar(
            url: user.avatarUrl,
            uploading: uploadingAvatar,
            onTap: onChangeAvatar,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Tap to change photo",
          textAlign: TextAlign.center,
          style: textTheme.labelSmall?.copyWith(
            color: colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          maxLength: 30,
          onSubmitted: (_) => onSaveName?.call(),
          decoration: InputDecoration(
            labelText: 'Name',
            // The limit still applies; the "12/30" counter is just noise here.
            counterText: '',
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
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        LoadingElevatedButton(
          loading: savingName,
          // Disabled until the name differs from the saved one, so there is
          // never a save that changes nothing.
          onPressed: onSaveName == null ? null : () => onSaveName!(),
          child: Text("Save"),
        ),
      ],
    );
  }
}
