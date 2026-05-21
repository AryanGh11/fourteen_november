part of '../posts_screen.dart';

class _View extends StatelessWidget {
  final List<Post> posts;
  final Future<void> Function() onRefresh;

  const _View({required this.posts, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => await onRefresh(),
      child: posts.isNotEmpty
          ? _List(posts: posts)
          : Center(child: Text('یجای کار میلنگه... به جوجو اطلاع بده بوس')),
    );
  }
}
