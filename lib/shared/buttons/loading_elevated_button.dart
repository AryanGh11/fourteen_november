import 'package:flutter/material.dart';
import 'package:fourteen_november/shared/custom_circular_progress_indicator.dart';

class LoadingElevatedButton extends StatelessWidget {
  final bool loading;
  final Widget? loadingWidget;
  final Widget child;
  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final double indicatorSize;
  final double? buttonSizedBoxHeight;

  const LoadingElevatedButton({
    super.key,
    required this.loading,
    this.loadingWidget,
    required this.child,
    this.style,
    this.onPressed,
    this.indicatorSize = 20,
    this.buttonSizedBoxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: buttonSizedBoxHeight,
          child: ElevatedButton(
            style: style,
            onPressed: loading ? null : onPressed,
            child: Opacity(opacity: loading ? 0 : 1, child: child),
          ),
        ),
        if (loading)
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: indicatorSize,
                height: indicatorSize,
                child: loadingWidget ?? CustomCircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
