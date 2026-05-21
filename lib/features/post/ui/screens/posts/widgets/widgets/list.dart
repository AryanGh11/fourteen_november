part of '../../posts_screen.dart';

class _List extends StatelessWidget {
  final List<Post> posts;

  const _List({required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        final post = posts[index];
        return _Post(post: post);
      },
      separatorBuilder: (_, __) => SizedBox(height: 30),
      itemCount: posts.length,
    );
  }
}
