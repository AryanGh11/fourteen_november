part of '../../../select_user_modal.dart';

class _Tile extends StatefulWidget {
  final User user;

  const _Tile({required this.user});

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  String? _avatarUrl;

  @override
  void initState() {
    _fetchUserAvatar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      clipBehavior: Clip.hardEdge,
      color: colors.surfaceContainer,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: () => _onUserTapped(context),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            spacing: 8,
            children: [
              _avatarUrl == null
                  ? CircleAvatar()
                  : CircleAvatar(backgroundImage: NetworkImage(_avatarUrl!)),
              Text(widget.user.name),
            ],
          ),
        ),
      ),
    );
  }

  void _onUserTapped(BuildContext context) {
    Navigator.of(context).pop(widget.user);
  }

  Future<void> _fetchUserAvatar() async {
    final avatarUrl = await widget.user.avatarUrl;

    setState(() {
      _avatarUrl = avatarUrl;
    });
  }
}
