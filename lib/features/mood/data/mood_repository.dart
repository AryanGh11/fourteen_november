import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/core/base_repository/base_repository.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_collections.dart';

/// Repository responsible for managing cached [Mood] data.
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
class MoodRepository implements BaseRepository<Mood> {
  @override
  /// PocketBase instance used for remote requests.
  PocketBase get pb => PocketBaseService.I.instance;

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
          .collection(PocketBaseCollections.moods)
          .getFullList();

      final moods = records.map((e) => Mood.fromRecordModel(e)).toList();

      for (final item in moods) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint("Mood sync failed: $e");
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
          .collection(PocketBaseCollections.moods)
          .getFullList();

      final moods = records.map((e) => Mood.fromRecordModel(e)).toList();

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
  /// - Sends create request to PocketBase
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

      final body = {
        "userId": userId,
        "note": payload.note.isEmpty ? null : payload.note,
        "value": payload.value,
      };

      final record = await pb
          .collection(PocketBaseCollections.moods)
          .create(body: body);

      final mood = await Mood.fromRecordModel(record);

      await _box.put(mood.id, mood);

      return mood;
    } catch (e) {
      debugPrint("Mood create failed: $e");
      rethrow;
    }
  }
}
