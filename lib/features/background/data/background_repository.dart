import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
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

      final rows = await AppwriteService.listAllRows(
        AppwriteTables.backgrounds,
      );

      final backgrounds = rows.map((e) => Background.fromRow(e)).toList();

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
      final rows = await AppwriteService.listAllRows(
        AppwriteTables.backgrounds,
      );

      final backgrounds = rows.map((e) => Background.fromRow(e)).toList();

      await _box.clear();

      for (final item in backgrounds) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint("Background refresh failed: $e");
    }
  }

  /// Uploads an image from the device and adds it as a new background.
  ///
  /// The image is uploaded first, since storage and rows are separate in
  /// Appwrite and the row stores the resulting file id. If writing the row
  /// then fails, the uploaded file is deleted again, so a half-finished add
  /// does not leave an orphaned image taking up the bucket's free space.
  ///
  /// The new background lands in the local cache straight away, so it shows
  /// on the backgrounds screen and joins the home screen's rotation without
  /// a refresh.
  ///
  /// Throws any Appwrite/network related exception.
  Future<Background> create(String imagePath) async {
    String? fileId;

    try {
      final file = await files.createFile(
        bucketId: AppwriteConstants.mediaBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: imagePath),
      );

      fileId = file.$id;

      final row = await db.createRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteTables.backgrounds,
        rowId: ID.unique(),
        data: {"imageId": fileId},
      );

      final background = Background.fromRow(row);

      await _box.put(background.id, background);

      return background;
    } catch (e) {
      debugPrint("Background create failed: $e");

      if (fileId != null) {
        try {
          await files.deleteFile(
            bucketId: AppwriteConstants.mediaBucketId,
            fileId: fileId,
          );
        } catch (cleanupError) {
          debugPrint("Background upload cleanup failed: $cleanupError");
        }
      }

      rethrow;
    }
  }

  /// Deletes a background, along with its image file.
  ///
  /// The row goes first: once it is gone the background disappears for both
  /// people. The file is then removed explicitly, since storage is not tied to
  /// rows and would otherwise be orphaned in the bucket. A failure on that
  /// second step is only logged, because the background itself is already
  /// deleted and reporting an error would suggest otherwise.
  ///
  /// Throws any Appwrite/network related exception from deleting the row.
  Future<void> delete(String id) async {
    try {
      final background = getOne(id);

      await db.deleteRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteTables.backgrounds,
        rowId: id,
      );

      final imageId = background?.imagePath ?? '';
      if (imageId.isNotEmpty) {
        try {
          await files.deleteFile(
            bucketId: AppwriteConstants.mediaBucketId,
            fileId: imageId,
          );
        } catch (e) {
          debugPrint("Background image delete failed: $e");
        }
      }

      await _box.delete(id);
    } catch (e) {
      debugPrint("Background delete failed: $e");
      rethrow;
    }
  }
}
