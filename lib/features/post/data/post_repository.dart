import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/user/data/user_provider_service.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

class PostRepository {
  final String _collectionName = "posts";

  final _pb = PocketBaseService.I.instance;

  Future<List<Post>> getAll() async {
    final res = await _pb.collection(_collectionName).getFullList();
    final posts = res.map((item) => Post.fromRecordModel(item)).toList();
    return posts;
  }

  Future<Post?> getOne(String id) async {
    final res = await _pb.collection(_collectionName).getOne(id);
    final post = Post.fromRecordModel(res);
    return post;
  }

  Future<Post?> like(String id, String userId) async {
    final currentPost = await getOne(id);
    final userId = UserProviderService().current?.id;

    if (currentPost == null || userId == null) return null;

    final List<String> likesBy = currentPost.likesBy;
    final alreadyLiked = currentPost.likesBy.contains(userId);

    if (alreadyLiked) {
      likesBy.remove(userId);
    } else {
      likesBy.add(userId);
    }

    final res = await _pb
        .collection(_collectionName)
        .update(id, body: {"likesBy": likesBy});

    final post = Post.fromRecordModel(res);
    return post;
  }
}
