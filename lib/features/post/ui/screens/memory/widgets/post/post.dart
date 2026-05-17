part of '../../memory_screen.dart';

class _Post extends StatefulWidget {
  final Post post;
  final Future<void> Function() onPostChanged;

  const _Post({required this.post, required this.onPostChanged});

  @override
  State<_Post> createState() => _PostState();
}

class _PostState extends State<_Post> {
  String? _attachmentUrl;
  User? _postUser;
  String? _postUserAvatarUrl;

  @override
  void initState() {
    _fetchStates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 1 / 1,
              child: _attachmentUrl != null
                  ? CustomCachedNetworkImage(
                      imageUrl: _attachmentUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(color: colors.surfaceContainer),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _Content(
                post: widget.post,
                postUser: _postUser,
                postUserAvatarUrl: _postUserAvatarUrl,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        _CTAButtons(post: widget.post, onPostChanged: widget.onPostChanged),
        SizedBox(height: 4),
        _DescriptionRow(post: widget.post, postUser: _postUser),
      ],
    );
  }

  Future<void> _fetchStates() async {
    final attachmentRes = await widget.post.attachmentUrl;
    final postUserRes = await widget.post.user;
    final postUserAvatarRes = await postUserRes.avatarUrl;

    setState(() {
      _attachmentUrl = attachmentRes;
      _postUser = postUserRes;
      _postUserAvatarUrl = postUserAvatarRes;
    });
  }
}
