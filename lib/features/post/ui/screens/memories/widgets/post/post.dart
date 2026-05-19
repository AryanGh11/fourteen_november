part of '../../memories_screen.dart';

class _Post extends StatelessWidget {
  final Post post;
  final Future<void> Function() onPostChanged;

  const _Post({required this.post, required this.onPostChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 1 / 1,
              child: CustomCachedNetworkImage(
                imageUrl: post.attachmentUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(top: 0, left: 0, right: 0, child: _Content(post: post)),
          ],
        ),
        SizedBox(height: 8),
        _CTAButtons(post: post, onPostChanged: onPostChanged),
        SizedBox(height: 4),
        _DescriptionRow(post: post),
      ],
    );
  }
}
