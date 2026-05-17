import 'package:flutter/material.dart';

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

  int _currentRange = 1;

  @override
  void initState() {
    super.initState();

    _currentRange = _getRange(widget.value);

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

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 30,
        overlayShape: SliderComponentShape.noOverlay,
        trackShape: const RoundedRectSliderTrackShape(),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 0,
        ),
        activeTrackColor: colors.primary.withValues(alpha: 0.8),
        inactiveTrackColor: colors.onSurface.withValues(alpha: 0.08),
        thumbColor: colors.primary,
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
      ),
      child: Slider(
        value: widget.value.clamp(1, 5),
        min: 1,
        max: 5,
        divisions: null,
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

      _controller
        ..reset()
        ..forward();
    }

    widget.onChanged(value);
  }
}
