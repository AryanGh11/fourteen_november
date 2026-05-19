part of '../../../../memories_screen.dart';

class _CTAButtons extends StatefulWidget {
  final Post post;
  final Future<void> Function() onPostChanged;

  const _CTAButtons({required this.post, required this.onPostChanged});

  @override
  State<_CTAButtons> createState() => _CTAButtonsState();
}

class _CTAButtonsState extends State<_CTAButtons> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final likesBy = widget.post.likesBy;

    return Row(
      spacing: 16,
      children: [
        _CTAButton(
          count: likesBy.length,
          icon: Icon(
            likedByUser(likesBy) ? Icons.favorite : Icons.favorite_outline,
            color: likedByUser(likesBy) ? Colors.redAccent : colors.onSurface,
          ),
          onTap: _toggleLike,
        ),
        _CTAButton(
          count: widget.post.commentsIds.length,
          icon: Icon(LucideIcons.messageCircle, color: colors.onSurface),
          onTap: null,
        ),
      ],
    );
  }

  bool likedByUser(List<String> likesBy) {
    final currentUser = UserProviderService().current;

    if (currentUser == null) return false;

    return likesBy.contains(currentUser.id);
  }

  Future<void> _toggleLike() async {
    final currentUser = UserProviderService().current;
    if (currentUser == null) return;

    await PostRepository().toggleLike(widget.post.id);

    await widget.onPostChanged();
  }
}
