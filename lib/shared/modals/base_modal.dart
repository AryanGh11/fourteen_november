import 'package:flutter/material.dart';

class BaseModal extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const BaseModal({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 10, 20, 60),
  });

  @override
  Widget build(BuildContext context) {
    return Container(padding: padding, child: child);
  }
}
