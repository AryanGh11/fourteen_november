// Prefixed: appwrite's models export `User` and `Row`, which collide with
// this app's User model and Flutter's Row widget.
import 'package:appwrite/models.dart' as models;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/comment/comment.dart';
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';

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

  @HiveField(8)
  final String attachmentUrl;

  Post({
    required this.id,
    required this.userId,
    required this.attachmentPath,
    required this.description,
    required this.likesBy,
    required this.commentsIds,
    required this.created,
    required this.updated,
    required this.attachmentUrl,
  });

  factory Post.fromRow(models.Row row) {
    final data = row.data;

    // Holds the Appwrite storage file id, which the view url is built from.
    final attachmentPath = (data["attachmentId"] as String?) ?? '';

    return Post(
      id: row.$id,
      userId: (data["userId"] as String?) ?? '',
      attachmentPath: attachmentPath,
      description: (data["description"] as String?) ?? '',
      likesBy: _stringList(data["likesBy"]),
      commentsIds: _stringList(data["commentsIds"]),
      created: DateTime.parse(row.$createdAt).toLocal(),
      updated: DateTime.parse(row.$updatedAt).toLocal(),
      attachmentUrl: AppwriteService.fileUrl(attachmentPath),
    );
  }

  /// Appwrite returns array columns as `List<dynamic>`.
  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).toList();
  }

  List<Comment> get comments {
    final comments = CommentRepository()
        .getAll()
        .where((c) => commentsIds.contains(c.id))
        .toList();
    return comments;
  }

  User get user {
    final user = UserRepository().getOne(userId);
    if (user == null) {
      throw ArgumentError("User for post $id not found");
    }
    return user;
  }
}
