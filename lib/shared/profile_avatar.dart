import 'package:flutter/material.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final double size;

  const ProfileAvatar({super.key, this.size = 1});

  @override
  Widget build(BuildContext context) {
    final user = UserProviderService().current;

    if (user == null) return const SizedBox.shrink();

    return Container(
      clipBehavior: Clip.hardEdge,
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: CachedNetworkImage(
        imageUrl: user.avatarUrl,
        width: size,
        height: size,
      ),
    );
  }
}
