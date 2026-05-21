import 'package:flutter/material.dart';
import 'package:fourteen_november/shared/custom_circular_progress_indicator.dart';

class LoadingIconButton extends IconButton {
  final bool loading;
  final double loadingSize;
  final Color? loadingColor;

  const LoadingIconButton({
    required this.loading,
    this.loadingSize = 24,
    this.loadingColor,
    super.key,
    super.iconSize,
    super.visualDensity,
    super.padding,
    super.alignment,
    super.splashRadius,
    super.color,
    super.focusColor,
    super.hoverColor,
    super.highlightColor,
    super.splashColor,
    super.disabledColor,
    required super.onPressed,
    super.onHover,
    super.onLongPress,
    super.mouseCursor,
    super.focusNode,
    super.autofocus = false,
    super.tooltip,
    super.enableFeedback,
    super.constraints,
    super.style,
    super.isSelected,
    super.selectedIcon,
    required super.icon,
  });

  @override
  Widget get icon {
    return Stack(
      children: [
        Opacity(opacity: loading ? 0 : 1, child: super.icon),
        if (loading)
          Container(
            padding: EdgeInsets.all(4),
            width: loadingSize,
            height: loadingSize,
            child: CustomCircularProgressIndicator(color: loadingColor),
          ),
      ],
    );
  }

  @override
  VoidCallback? get onPressed => loading ? null : super.onPressed;
}
