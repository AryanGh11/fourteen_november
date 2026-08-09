import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/core/base_repository/base_repository.dart';
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';
import 'package:fourteen_november/services/appwrite/appwrite_constants.dart';

/// Repository responsible for managing cached [Post] data.
///
/// This repository follows an offline-first architecture:
/// - Hive is used as the primary local data source.
/// - Appwrite is used as the remote source of truth.
/// - UI reads data directly from local cache for fast and stable rendering.
/// - Remote synchronization happens manually through refresh methods.
///
/// The repository provides:
/// - Instant local reads
/// - Initial synchronization
/// - Manual remote refresh support
/// - Persistent offline access
class PostRepository implements BaseRepository<Post> {
  /// Appwrite tables API used for remote requests.
  TablesDB get db => AppwriteService.I.tablesDB;

  /// Appwrite storage API used for file uploads.
  Storage get files => AppwriteService.I.storage;

  /// Local Hive box containing cached [Post] models.
  static Box<Post> get _box => Hive.box<Post>(HiveService.postsBoxKey);

  @override
  /// Returns all cached posts from local storage.
  ///
  /// This method is completely offline and does not perform
  /// any network requests.
  List<Post> getAll() {
    return _box.values.toList();
  }

  @override
  /// Returns a single cached post by its id.
  ///
  /// Returns `null` if the item does not exist locally.
  Post? getOne(String id) {
    return _box.get(id);
  }

  @override
  /// Returns a reactive Hive box listenable.
  ///
  /// Used by UI to automatically rebuild when data changes.
  ValueListenable<Box<Post>> listenableBox() {
    return _box.listenable();
  }

  @override
  /// Returns all items from a given Hive box.
  ///
  /// Utility method for generic access when working with external boxes.
  List<Post> getAllFromBox(Box<Post> box) {
    return box.values.toList().cast<Post>();
  }

  @override
  /// Performs the initial synchronization with Appwrite.
  ///
  /// This method only fetches remote data when the local cache
  /// is empty. It is mainly intended to run during app startup
  /// or splash initialization.
  ///
  /// Existing cached data will remain untouched.
  Future<void> syncIfNeeded() async {
    try {
      if (_box.isNotEmpty) return;

      final rows = await AppwriteService.listAllRows(AppwriteTables.posts);

      final posts = rows.map((e) => Post.fromRow(e)).toList();

      for (final item in posts) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint("Post sync failed: $e");
      return;
    }
  }

  @override
  /// Fully refreshes local cache using the latest remote data.
  ///
  /// This method:
  /// - Fetches all records from Appwrite
  /// - Clears existing local cache
  /// - Replaces cache with fresh remote data
  ///
  /// Intended for pull-to-refresh actions or manual updates.
  Future<void> hardRefresh() async {
    try {
      final rows = await AppwriteService.listAllRows(AppwriteTables.posts);

      final posts = rows.map((e) => Post.fromRow(e)).toList();

      await _box.clear();

      for (final item in posts) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint("Post refresh failed: $e");
      rethrow;
    }
  }

  /// Creates a new post record.
  ///
  /// This method:
  /// - Sends create request to Appwrite
  /// - Converts response into a [Post] model
  /// - Stores the model locally inside Hive
  /// - Returns the cached instance
  ///
  /// This keeps local cache and remote state synchronized.
  Future<Post> create(PostCreatePayload payload) async {
    try {
      final userId = UserProviderService().current?.id;

      if (userId == null) {
        throw ArgumentError("User not found");
      }

      // The attachment is uploaded first: storage and rows are separate in
      // Appwrite, so the row stores the resulting file id.
      final file = await files.createFile(
        bucketId: AppwriteConstants.mediaBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: payload.attachmentPath),
      );

      final row = await db.createRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteTables.posts,
        rowId: ID.unique(),
        data: {
          "userId": userId,
          "description": payload.description,
          "attachmentId": file.$id,
          "commentsIds": <String>[],
          "likesBy": <String>[],
        },
      );

      final post = Post.fromRow(row);

      await _box.put(post.id, post);

      return post;
    } catch (e) {
      debugPrint("Post create failed: $e");
      rethrow;
    }
  }

  /// Deletes a post record.
  ///
  /// This method:
  /// - Sends delete request to Appwrite
  /// - Deletes the model locally inside Hive
  ///
  /// This keeps local cache and remote state synchronized.
  Future<void> delete(String id) async {
    try {
      final post = getOne(id);

      await db.deleteRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteTables.posts,
        rowId: id,
      );

      // Storage is not tied to rows the way PocketBase file fields were, so the
      // attachment has to be removed explicitly or it is orphaned in the bucket.
      final attachmentId = post?.attachmentPath ?? '';
      if (attachmentId.isNotEmpty) {
        try {
          await files.deleteFile(
            bucketId: AppwriteConstants.mediaBucketId,
            fileId: attachmentId,
          );
        } catch (e) {
          debugPrint("Post attachment delete failed: $e");
        }
      }

      await _box.delete(id);
    } catch (e) {
      debugPrint("Post delete failed: $e");
      rethrow;
    }
  }

  /// Toggles like state for a post.
  ///
  /// This method:
  /// - Reads the cached post locally
  /// - Checks whether current user already liked the post
  /// - Adds or removes the user from `likesBy`
  /// - Updates Appwrite record
  /// - Replaces local cached post with fresh remote data
  ///
  /// Returns the updated [Post] instance.
  ///
  /// Throws:
  /// - [ArgumentError] if user or post is missing
  /// - Any Appwrite/network related exception
  Future<Post> toggleLike(String postId) async {
    try {
      final currentPost = getOne(postId);
      final currentUserId = UserProviderService().current?.id;

      if (currentPost == null || currentUserId == null) {
        throw ArgumentError("User or post not found");
      }

      /// Create immutable copy to avoid mutating cached list reference.
      final likesBy = List<String>.from(currentPost.likesBy);

      final alreadyLiked = likesBy.contains(currentUserId);

      if (alreadyLiked) {
        likesBy.remove(currentUserId);
      } else {
        likesBy.add(currentUserId);
      }

      final row = await db.updateRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteTables.posts,
        rowId: postId,
        data: {"likesBy": likesBy},
      );

      final updatedPost = Post.fromRow(row);

      /// Update local cache with latest remote state.
      await _box.put(updatedPost.id, updatedPost);

      return updatedPost;
    } catch (e) {
      debugPrint("Post like toggle failed: $e");
      rethrow;
    }
  }
}
