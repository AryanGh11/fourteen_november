import 'package:flutter/material.dart';
import 'package:fourteen_november/shared/custom_cached_network_image.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String url;
  final double size;

  const CustomCircleAvatar({super.key, required this.url, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: CustomCachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
