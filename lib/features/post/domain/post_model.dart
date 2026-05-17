import 'package:pocketbase/pocketbase.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/comment/comment.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

part 'post_model.g.dart';

@HiveType(typeId: 4)
class Post extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String attachmentPath;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final List<String> likesBy;

  @HiveField(5)
  final List<String> commentsIds;

  @HiveField(6)
  final DateTime created;

  @HiveField(7)
  final DateTime updated;

  Post({
    required this.id,
    required this.userId,
    required this.attachmentPath,
    required this.description,
    required this.likesBy,
    required this.commentsIds,
    required this.created,
    required this.updated,
  });

  factory Post.fromRecordModel(RecordModel model) {
    return Post(
      id: model.id,
      userId: model.getStringValue("userId"),
      attachmentPath: model.getStringValue("attachment"),
      description: model.getStringValue("description"),
      likesBy: model.getListValue("likesBy"),
      commentsIds: model.getListValue("commentsIds"),
      created: DateTime.parse(model.get("created")),
      updated: DateTime.parse(model.get("updated")),
    );
  }

  Future<User> get user async {
    final user = await UserRepository().getOne(userId);

    if (user == null) throw ArgumentError("User for post $id is not found");

    return user;
  }

  Future<String> get attachmentUrl async {
    final pb = PocketBaseService.I.instance;
    final recordModel = await toRecordModel();

    return pb.files.getURL(recordModel, attachmentPath).toString();
  }

  Future<List<Comment>> get comments async {
    final comments = await CommentRepository().getMany(commentsIds);
    return comments;
  }
}
