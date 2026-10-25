part of '../../profile_screen.dart';

/// Large avatar with a camera badge, tapped to pick a new photo.
class _Avatar extends StatelessWidget {
  static const double _size = 120;

  final String url;
  final bool uploading;
  final VoidCallback? onTap;

  const _Avatar({required this.url, required this.uploading, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          children: [
            CustomCircleAvatar(url: url, size: _size),
            if (uploading)
              Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surface.withValues(alpha: 0.6),
                ),
                child: const Center(child: CustomCircularProgressIndicator()),
              ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  // Ring in the page colour separates the badge from the photo.
                  border: Border.all(color: colors.surface, width: 3),
                ),
                // The primary is a light pastel in both themes, so dark
                // icons read on it; the light scheme's onPrimary is white.
                child: Icon(
                  LucideIcons.camera,
                  size: 16,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
