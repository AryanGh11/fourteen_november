import 'package:flutter/material.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/shared/custom_cached_network_image.dart';

part 'widgets/list/list.dart';
part 'widgets/list/widgets/tile.dart';

Future<User?> showSelectUserModal(BuildContext context) async {
  final user = UserProviderService().current;

  if (user != null) return null;

  return await showModalBottomSheet(
    context: context,
    isDismissible: false,
    builder: (context) {
      return _Content();
    },
  );
}

class _Content extends StatelessWidget {
  _Content();

  final _users = UserRepository().getAll();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Text(
            "هالووو! شما؟",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 30),
          _List(users: _users),
        ],
      ),
    );
  }
}
