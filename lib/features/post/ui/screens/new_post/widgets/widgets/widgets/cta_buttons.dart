part of '../../../new_post_screen.dart';

class _CTAButtons extends StatelessWidget {
  const _CTAButtons();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      spacing: 16,
      children: [
        PostScreenCTAButton(
          count: 0,
          icon: Icon(Icons.favorite_outline, color: colors.onSurface),
          onTap: null,
          loading: false,
        ),
        PostScreenCTAButton(
          count: 0,
          icon: Icon(LucideIcons.messageCircle, color: colors.onSurface),
          onTap: null,
          loading: false,
        ),
      ],
    );
  }
}
