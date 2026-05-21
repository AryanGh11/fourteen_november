part of '../../../../posts_screen.dart';

class _CTAButtons extends StatefulWidget {
  final Post post;

  const _CTAButtons({required this.post});

  @override
  State<_CTAButtons> createState() => _CTAButtonsState();
}

class _CTAButtonsState extends State<_CTAButtons> {
  bool _liking = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final likesBy = widget.post.likesBy;

    return Row(
      spacing: 16,
      children: [
        PostScreenCTAButton(
          count: likesBy.length,
          icon: Icon(
            likedByUser(likesBy) ? Icons.favorite : Icons.favorite_outline,
            color: likedByUser(likesBy) ? Colors.redAccent : colors.onSurface,
          ),
          onTap: _toggleLike,
          loading: _liking,
        ),
        PostScreenCTAButton(
          count: widget.post.commentsIds.length,
          icon: Icon(LucideIcons.messageCircle, color: colors.onSurface),
          onTap: null,
          loading: false,
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
    setState(() {
      _liking = true;
    });

    try {
      final currentUser = UserProviderService().current;
      if (currentUser == null) return;

      await PostRepository().toggleLike(widget.post.id);
    } finally {
      setState(() {
        _liking = false;
      });
    }
  }
}
