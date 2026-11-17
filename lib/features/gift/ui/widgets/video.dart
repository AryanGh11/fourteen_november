part of '../gift_screen.dart';

/// The video, fitted to the screen, with a progress bar and tap to pause.
class _Video extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onTap;

  const _Video({required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Contain rather than cover: the whole video is the message, so
          // nothing at its edges should be cropped away.
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) {
              final paused = !value.isPlaying && !value.isCompleted;

              return AnimatedOpacity(
                opacity: paused ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.play,
                      size: 32,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: VideoProgressIndicator(
                    controller,
                    // No scrubbing: the gift comes at the end of the video,
                    // and skipping straight there would miss the point.
                    allowScrubbing: false,
                    padding: EdgeInsets.zero,
                    colors: VideoProgressColors(
                      playedColor: AppColors.secondary,
                      bufferedColor: colors.onSurface.withValues(alpha: 0.3),
                      backgroundColor: colors.onSurface.withValues(alpha: 0.12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
