import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/features/background/background.dart';
import 'package:fourteen_november/core/base_repository/base_repository.dart';
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';
import 'package:fourteen_november/services/appwrite/appwrite_constants.dart';

/// Repository responsible for managing cached [Background] data.
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
class BackgroundRepository implements BaseRepository<Background> {
  /// Appwrite tables API used for remote requests.
  TablesDB get db => AppwriteService.I.tablesDB;

  /// Appwrite storage API used for file uploads.
  Storage get files => AppwriteService.I.storage;

  /// Local Hive box containing cached [Background] models.
  static Box<Background> get _box =>
      Hive.box<Background>(HiveService.backgroundsBoxKey);

  @override
  /// Returns all cached backgrounds from local storage.
  ///
  /// This method is completely offline and does not perform
  /// any network requests.
  List<Background> getAll() {
    return _box.values.toList();
  }

  @override
  /// Returns a single cached background by its id.
  ///
  /// Returns `null` if the item does not exist locally.
  Background? getOne(String id) {
    return _box.get(id);
  }

  @override
  /// Returns a reactive Hive box listenable.
  ///
  /// Used by UI to automatically rebuild when data changes.
  ValueListenable<Box<Background>> listenableBox() {
    return _box.listenable();
  }

  @override
  /// Returns all items from a given Hive box.
  ///
  /// Utility method for generic access when working with external boxes.
  List<Background> getAllFromBox(Box<Background> box) {
    return box.values.toList().cast<Background>();
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
        tableId: AppwriteTables.backgrounds,
      );

      final backgrounds = result.rows
          .map((e) => Background.fromRow(e))
          .toList();

      for (final item in backgrounds) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint("Background sync failed: $e");
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
        tableId: AppwriteTables.backgrounds,
      );

      final backgrounds = result.rows
          .map((e) => Background.fromRow(e))
          .toList();

      await _box.clear();

      for (final item in backgrounds) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint("Background refresh failed: $e");
    }
  }
}
