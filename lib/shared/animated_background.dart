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

      setState(() {
        _currentIndex = _nextIndex;

        _nextIndex = (_nextIndex + 1) % widget.images.length;
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
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

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
                imageUrl: widget.images[_currentIndex],
                fit: BoxFit.cover,
              ),
            ),

            // NEXT IMAGE
            Opacity(
              opacity: fadeProgress.toDouble(),
              child: Transform.scale(
                scale: nextScale,
                child: CustomCachedNetworkImage(
                  imageUrl: widget.images[_nextIndex],
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
