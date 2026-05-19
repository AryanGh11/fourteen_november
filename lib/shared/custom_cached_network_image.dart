import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomCachedNetworkImage extends CachedNetworkImage {
  CustomCachedNetworkImage({
    super.key,
    required super.imageUrl,
    super.httpHeaders = const {'ngrok-skip-browser-warning': 'true'},
    super.imageBuilder,
    super.placeholder,
    super.progressIndicatorBuilder,
    super.errorWidget,
    super.fadeOutDuration,
    super.fadeOutCurve,
    super.fadeInDuration,
    super.fadeInCurve,
    super.width,
    super.height,
    super.fit,
    super.alignment,
    super.repeat,
    super.matchTextDirection,
    super.cacheManager,
    super.useOldImageOnUrlChange,
    super.color,
    super.filterQuality,
    super.colorBlendMode,
    super.placeholderFadeInDuration,
    super.memCacheWidth,
    super.memCacheHeight,
    super.cacheKey,
    super.maxWidthDiskCache,
    super.maxHeightDiskCache,
    super.errorListener,
    super.imageRenderMethodForWeb,
    super.scale,
  });

  @override
  PlaceholderWidgetBuilder? get placeholder {
    return (context, url) {
      final colors = Theme.of(context).colorScheme;

      return Container(color: colors.surfaceContainer);
    };
  }
}
