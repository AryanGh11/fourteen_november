import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/shared/custom_circle_avatar.dart';

/// The current user's avatar.
///
/// Watches the users box rather than reading it once, so a new photo from the
/// profile screen shows here as soon as you return.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UserRepository().listenableBox(),
      builder: (context, Box<User> _, __) {
        final user = UserProviderService().current;

        if (user == null) return const SizedBox.shrink();

        return CustomCircleAvatar(url: user.avatarUrl);
      },
    );
  }
}
