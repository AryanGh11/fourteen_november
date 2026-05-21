import 'package:flutter/material.dart';
import 'package:fourteen_november/theme/app_colors.dart';

class CustomSlider extends StatefulWidget {
  final double value;
  final void Function(double value) onChanged;

  const CustomSlider({super.key, required this.value, required this.onChanged});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Color _previousColor;

  int _currentRange = 1;

  @override
  void initState() {
    super.initState();

    _currentRange = _getRange(widget.value);
    _previousColor = _getColorForRange(widget.value);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final targetColor = _getColorForRange(widget.value);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animatedColor = ColorTween(
          begin: _previousColor,
          end: targetColor,
        ).evaluate(_controller)!;

        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 30,
            overlayShape: SliderComponentShape.noOverlay,
            trackShape: const RoundedRectSliderTrackShape(),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 0,
            ),
            activeTrackColor: animatedColor.withValues(alpha: 0.8),
            inactiveTrackColor: colors.onSurface.withValues(alpha: 0.08),
            thumbColor: animatedColor,
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: Colors.transparent,
          ),
          child: child!,
        );
      },
      child: Slider(
        padding: EdgeInsets.all(0),
        value: widget.value.clamp(1, 5),
        min: 1,
        max: 5,
        divisions: 4,
        onChanged: _onChanged,
      ),
    );
  }

  int _getRange(double value) {
    if (value < 1.5) return 1;
    if (value < 2.5) return 2;
    if (value < 3.5) return 3;
    if (value < 4.5) return 4;

    return 5;
  }

  void _onChanged(double value) {
    final newRange = _getRange(value);

    if (newRange != _currentRange) {
      _currentRange = newRange;
      _previousColor = _getColorForRange(widget.value);

      _controller
        ..reset()
        ..forward();
    }

    widget.onChanged(value);
  }

  Color _getColorForRange(double value) {
    final range = _getRange(value);

    if (range == 1) return AppColors.moodTerrible;
    if (range == 2) return AppColors.moodBad;
    if (range == 3) return AppColors.moodOkay;
    if (range == 4) return AppColors.moodGood;

    return AppColors.moodAmazing;
  }
}
