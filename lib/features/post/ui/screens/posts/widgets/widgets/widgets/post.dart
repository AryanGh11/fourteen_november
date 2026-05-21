part of '../../../posts_screen.dart';

class _Post extends StatelessWidget {
  final Post post;

  const _Post({required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            _Attachment(url: post.attachmentUrl),
            Positioned(top: 0, left: 0, right: 0, child: _Content(post: post)),
          ],
        ),
        SizedBox(height: 8),
        _CTAButtons(post: post),
        SizedBox(height: 4),
        _DescriptionRow(post: post),
      ],
    );
  }
}
