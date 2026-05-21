part of '../../../../posts_screen.dart';

class _Attachment extends StatelessWidget {
  final String url;

  const _Attachment({required this.url});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: CustomCachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
    );
  }
}
