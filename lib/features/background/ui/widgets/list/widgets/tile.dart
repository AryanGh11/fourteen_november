part of '../../../backgrounds_screen.dart';

/// One background, filling the screen the way it would as the app's backdrop.
class _Tile extends StatelessWidget {
  final Background background;

  const _Tile({required this.background});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // CachedNetworkImage rather than CustomCachedNetworkImage: the custom one
    // always supplies a placeholder, and octo_image asserts that a placeholder
    // and a progress builder are never both set, so it cannot show a spinner.
    return CachedNetworkImage(
      imageUrl: background.imageUrl,
      width: double.infinity,
      height: double.infinity,
      // Cover rather than contain: this previews the image as a background,
      // edge to edge, which is how it actually appears behind the home screen.
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 250),
      progressIndicatorBuilder: (context, _, __) {
        return const Center(child: CustomCircularProgressIndicator());
      },
      errorWidget: (context, _, __) {
        return Center(
          child: Icon(
            LucideIcons.imageOff,
            size: 40,
            color: colors.onSurface.withValues(alpha: 0.4),
          ),
        );
      },
    );
  }
}
