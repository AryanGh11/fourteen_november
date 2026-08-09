import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fourteen_november/shared/custom_cached_network_image.dart';

class AnimatedBackground extends StatefulWidget {
  final List<String> images;

  const AnimatedBackground({super.key, required this.images});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Timer? _timer;

  int _currentIndex = 0;
  int _nextIndex = 1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..forward();

    _startLoop();
  }

  void _startLoop() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;

      // Checked every tick rather than once at startup: the list is empty
      // until the backgrounds finish syncing, and cycling needs two images.
      final count = widget.images.length;
      if (count < 2) return;

      setState(() {
        _currentIndex = _nextIndex;

        _nextIndex = (_nextIndex + 1) % count;
      });

      _controller
        ..reset()
        ..forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.images.length;

    if (count == 0) {
      return const SizedBox.shrink();
    }

    // Wrapped rather than used raw: with a single image both indices must
    // collapse onto it, otherwise the next-image slot reads out of range.
    final currentIndex = _currentIndex % count;
    final nextIndex = _nextIndex % count;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;

        // Current image:
        // scale 1 -> 1.1
        final currentScale = lerpDouble(1, 1.1, progress)!;

        // Next image:
        // reverse scale 1.1 -> 1
        final nextScale = lerpDouble(1.1, 1, progress)!;

        // Fade only in last second
        final fadeProgress = progress < 0.9 ? 0 : (progress - 0.9) / 0.1;

        return Stack(
          fit: StackFit.expand,
          children: [
            // CURRENT IMAGE
            Transform.scale(
              scale: currentScale,
              child: CustomCachedNetworkImage(
                imageUrl: widget.images[currentIndex],
                fit: BoxFit.cover,
              ),
            ),

            // NEXT IMAGE
            Opacity(
              opacity: fadeProgress.toDouble(),
              child: Transform.scale(
                scale: nextScale,
                child: CustomCachedNetworkImage(
                  imageUrl: widget.images[nextIndex],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
