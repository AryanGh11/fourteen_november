import 'package:flutter/material.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

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
    super.centerTitle = true,
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
    return GestureDetector(
      onTap: PocketBaseService.pasteUrl,
      child: super.title,
    );
  }
}
