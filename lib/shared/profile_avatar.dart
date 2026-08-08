import 'package:flutter/material.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/shared/custom_circle_avatar.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserProviderService().current;

    if (user == null) return const SizedBox.shrink();

    return CustomCircleAvatar(url: user.avatarUrl);
  }
}
