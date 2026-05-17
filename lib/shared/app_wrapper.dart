import 'package:flutter/material.dart';

class AppWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AppWrapper({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}
