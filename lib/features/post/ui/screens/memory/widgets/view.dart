part of '../memory_screen.dart';

class _View extends StatelessWidget {
  final List<Post>? posts;
  final Future<void> Function() onPostChanged;

  const _View({required this.posts, required this.onPostChanged});

  @override
  Widget build(BuildContext context) {
    return posts == null
        ? CircularProgressIndicator()
        : ListView.separated(
            itemBuilder: (context, index) {
              final post = posts![index];
              return _Post(post: post, onPostChanged: onPostChanged);
            },
            separatorBuilder: (_, __) => SizedBox(height: 10),
            itemCount: posts!.length,
          );
  }
}
