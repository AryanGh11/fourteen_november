import 'package:flutter/material.dart';
import 'package:fourteen_november/features/user/user.dart';

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

class _Content extends StatefulWidget {
  const _Content();

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  List<User>? _users;

  @override
  void initState() {
    _fetchUsers();
    super.initState();
  }

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
            "Welcome! Wer bist du?",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 30),
          if (_users != null)
            _List(users: _users!)
          else
            CircularProgressIndicator(),
        ],
      ),
    );
  }

  Future<void> _fetchUsers() async {
    final res = await UserRepository().getAll();
    setState(() {
      _users = res;
    });
  }
}
