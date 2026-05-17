part of '../../select_user_modal.dart';

class _List extends StatelessWidget {
  final List<User> users;

  const _List({required this.users});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120 * 2,
      child: Column(
        spacing: 10,
        children: [
          ...users.map((user) {
            return _Tile(user: user);
          }),
        ],
      ),
    );
  }
}
