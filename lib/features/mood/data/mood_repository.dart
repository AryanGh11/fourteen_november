import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/core/base_repository/base_repository.dart';
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';
import 'package:fourteen_november/services/appwrite/appwrite_constants.dart';

/// Repository responsible for managing cached [Mood] data.
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
class MoodRepository implements BaseRepository<Mood> {
  /// Appwrite tables API used for remote requests.
  TablesDB get db => AppwriteService.I.tablesDB;

  /// Appwrite storage API used for file uploads.
  Storage get files => AppwriteService.I.storage;

  /// Local Hive box containing cached [Mood] models.
  static Box<Mood> get _box => Hive.box<Mood>(HiveService.moodsBoxKey);

  @override
  /// Returns all cached moods from local storage.
  ///
  /// This method is completely offline and does not perform
  /// any network requests.
  List<Mood> getAll() {
    return _box.values.toList();
  }

  @override
  /// Returns a single cached mood by its id.
  ///
  /// Returns `null` if the item does not exist locally.
  Mood? getOne(String id) {
    return _box.get(id);
  }

  @override
  /// Returns a reactive Hive box listenable.
  ///
  /// Used by UI to automatically rebuild when data changes.
  ValueListenable<Box<Mood>> listenableBox() {
    return _box.listenable();
  }

  @override
  /// Returns all items from a given Hive box.
  ///
  /// Utility method for generic access when working with external boxes.
  List<Mood> getAllFromBox(Box<Mood> box) {
    return box.values.toList().cast<Mood>();
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

      final result = await db.listRows(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteTables.moods,
      );

      final moods = result.rows.map((e) => Mood.fromRow(e)).toList();

      for (final item in moods) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint("Mood sync failed: $e");
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
      final result = await db.listRows(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteTables.moods,
      );

      final moods = result.rows.map((e) => Mood.fromRow(e)).toList();

      await _box.clear();

      for (final item in moods) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint("Mood refresh failed: $e");
    }
  }

  /// Creates a new mood record.
  ///
  /// This method:
  /// - Sends create request to Appwrite
  /// - Converts response into a [Mood] model
  /// - Stores the model locally inside Hive
  /// - Returns the cached instance
  ///
  /// This keeps local cache and remote state synchronized.
  Future<Mood> create(MoodCreatePayload payload) async {
    try {
      final userId = UserProviderService().current?.id;

      if (userId == null) {
        throw ArgumentError("User not found");
      }

      final row = await db.createRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteTables.moods,
        rowId: ID.unique(),
        data: {
          "userId": userId,
          "note": payload.note,
          "value": payload.value,
        },
      );

      final mood = Mood.fromRow(row);

      await _box.put(mood.id, mood);

      return mood;
    } catch (e) {
      debugPrint("Mood create failed: $e");
      rethrow;
    }
  }

  /// Deletes a mood record.
  ///
  /// This method:
  /// - Sends delete request to Appwrite
  /// - Deletes the model locally inside Hive
  ///
  /// This keeps local cache and remote state synchronized.
  Future<void> delete(String id) async {
    try {
      await db.deleteRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteTables.moods,
        rowId: id,
      );

      await _box.delete(id);
    } catch (e) {
      debugPrint("Mood delete failed: $e");
      rethrow;
    }
  }
}
