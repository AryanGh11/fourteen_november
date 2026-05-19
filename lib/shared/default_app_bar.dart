import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fourteen_november/services/shared_performance/shared_performance_service.dart';

class DefaultAppBar extends AppBar {
  DefaultAppBar({
    super.key,
    super.leading,
    super.automaticallyImplyLeading = true,
    super.title,
    super.actions,
    super.flexibleSpace,
    super.bottom,
    super.elevation = 0,
    super.scrolledUnderElevation,
    super.notificationPredicate,
    super.shadowColor = Colors.transparent,
    super.surfaceTintColor = Colors.transparent,
    super.shape,
    super.backgroundColor = Colors.transparent,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary,
    super.centerTitle,
    super.excludeHeaderSemantics,
    super.titleSpacing,
    super.toolbarOpacity,
    super.bottomOpacity,
    super.toolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
    super.forceMaterialTransparency,
    super.useDefaultSemanticsOrder,
    super.clipBehavior,
    super.actionsPadding,
  });

  @override
  Widget? get title {
    return GestureDetector(onTap: _pastePocketBaseUrl, child: super.title);
  }

  Future<void> _pastePocketBaseUrl() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();

    if (text == null) return;

    final urlRegex = RegExp(
      r'^(https?:\/\/)'
      r'('
      r'(([a-zA-Z0-9_-]+\.)+[a-zA-Z]{2,})' // domain
      r'|'
      r'((\d{1,3}\.){3}\d{1,3})' // IPv4
      r'|'
      r'(localhost)' // localhost
      r')'
      r'(:\d+)?'
      r'(\/.*)?$',
    );

    if (!urlRegex.hasMatch(text)) return;

    await SharedPerformanceService.put('pocketBaseUrl', text);
  }
}
