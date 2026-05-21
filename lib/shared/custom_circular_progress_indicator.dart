import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;
  final double? size;

  const CustomCircularProgressIndicator({
    super.key,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 2,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color ?? colors.onSurface,
        backgroundColor: backgroundColor,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
