import 'package:pocketbase/pocketbase.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/user/user.dart';

part 'comment_model.g.dart';

@HiveType(typeId: 3)
class Comment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String postId;

  @HiveField(3)
  final String body;

  @HiveField(4)
  final DateTime created;

  @HiveField(5)
  final DateTime updated;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.body,
    required this.created,
    required this.updated,
  });

  factory Comment.fromRecordModel(RecordModel model) {
    return Comment(
      id: model.id,
      userId: model.getStringValue("userId"),
      postId: model.getStringValue("postId"),
      body: model.getStringValue("body"),
      created: DateTime.parse(model.get("created")),
      updated: DateTime.parse(model.get("updated")),
    );
  }

  User get user {
    final user = UserRepository().getOne(userId);
    if (user == null) {
      throw ArgumentError("User for post $id not found");
    }
    return user;
  }

  Post get post {
    final post = PostRepository().getOne(postId);
    if (post == null) {
      throw ArgumentError("Post for post $id not found");
    }
    return post;
  }
}
