import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/core/base_repository/base_repository.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_collections.dart';

/// Repository responsible for managing cached [Post] data.
///
/// This repository follows an offline-first architecture:
/// - Hive is used as the primary local data source.
/// - PocketBase is used as the remote source of truth.
/// - UI reads data directly from local cache for fast and stable rendering.
/// - Remote synchronization happens manually through refresh methods.
///
/// The repository provides:
/// - Instant local reads
/// - Initial synchronization
/// - Manual remote refresh support
/// - Persistent offline access
class PostRepository implements BaseRepository<Post> {
  @override
  /// PocketBase instance used for remote requests.
  PocketBase get pb => PocketBaseService.I.instance;

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
  /// Performs the initial synchronization with PocketBase.
  ///
  /// This method only fetches remote data when the local cache
  /// is empty. It is mainly intended to run during app startup
  /// or splash initialization.
  ///
  /// Existing cached data will remain untouched.
  Future<void> syncIfNeeded() async {
    try {
      if (_box.isNotEmpty) return;

      final records = await pb
          .collection(PocketBaseCollections.posts)
          .getFullList();

      final posts = records.map((e) => Post.fromRecordModel(e)).toList();

      for (final item in posts) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint("Post sync failed: $e");
      rethrow;
    }
  }

  @override
  /// Fully refreshes local cache using the latest remote data.
  ///
  /// This method:
  /// - Fetches all records from PocketBase
  /// - Clears existing local cache
  /// - Replaces cache with fresh remote data
  ///
  /// Intended for pull-to-refresh actions or manual updates.
  Future<void> hardRefresh() async {
    try {
      final records = await pb
          .collection(PocketBaseCollections.posts)
          .getFullList();

      final posts = records.map((e) => Post.fromRecordModel(e)).toList();

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
  /// - Sends create request to PocketBase
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

      final attachment = await http.MultipartFile.fromPath(
        'attachment',
        payload.attachmentPath,
      );

      final body = {
        "userId": userId,
        "description": payload.description,
        "commentsIds": [],
        "likesBy": [],
      };

      final record = await pb
          .collection(PocketBaseCollections.posts)
          .create(body: body, files: [attachment]);

      final post = Post.fromRecordModel(record);

      await _box.put(post.id, post);

      return post;
    } catch (e) {
      debugPrint("Post create failed: $e");
      rethrow;
    }
  }

  /// Toggles like state for a post.
  ///
  /// This method:
  /// - Reads the cached post locally
  /// - Checks whether current user already liked the post
  /// - Adds or removes the user from `likesBy`
  /// - Updates PocketBase record
  /// - Replaces local cached post with fresh remote data
  ///
  /// Returns the updated [Post] instance.
  ///
  /// Throws:
  /// - [ArgumentError] if user or post is missing
  /// - Any PocketBase/network related exception
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

      final record = await pb
          .collection(PocketBaseCollections.posts)
          .update(postId, body: {"likesBy": likesBy});

      final updatedPost = Post.fromRecordModel(record);

      /// Update local cache with latest remote state.
      await _box.put(updatedPost.id, updatedPost);

      return updatedPost;
    } catch (e) {
      debugPrint("Post like toggle failed: $e");
      rethrow;
    }
  }
}
