part of '../../../select_user_modal.dart';

class _Tile extends StatelessWidget {
  final User user;

  const _Tile({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      clipBehavior: Clip.hardEdge,
      color: colors.surfaceContainer,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        splashColor: colors.surfaceContainerHighest,
        highlightColor: colors.surfaceContainerHighest,
        onTap: () => _onUserTapped(context),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            spacing: 12,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: CustomCachedNetworkImage(
                  imageUrl: user.avatarUrl,
                  width: 48,
                  height: 48,
                ),
              ),
              Text(user.name),
            ],
          ),
        ),
      ),
    );
  }

  void _onUserTapped(BuildContext context) {
    Navigator.of(context).pop(user);
  }
}
