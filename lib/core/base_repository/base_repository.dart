import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Base contract for all offline-first repositories.
///
/// Repositories implementing this interface are responsible for:
/// - Managing local cached data
/// - Communicating with PocketBase
/// - Providing synchronous local reads
/// - Handling remote synchronization and refresh operations
///
/// Architecture flow:
/// PocketBase (remote source of truth)
///        ↓
/// Repository sync/refresh
///        ↓
/// Hive local cache
///        ↓
/// UI reads from local storage
abstract class BaseRepository<T> {
  /// PocketBase instance used for remote API requests.
  abstract final PocketBase pb;

  /// Returns all locally cached models.
  ///
  /// This method should not perform network requests.
  List<T> getAll();

  /// Returns a single locally cached model by id.
  ///
  /// Returns `null` if the item does not exist.
  T? getOne(String id);

  /// Returns a live listenable Hive box for the cached models.
  ///
  /// This allows the UI to reactively update when the underlying
  /// Hive data changes (insert, update, delete).
  ///
  /// Use this instead of manually calling setState when possible,
  /// as it enables automatic UI rebuilds via ValueListenableBuilder.
  ///
  /// This method does not perform any network requests and only
  /// reflects the current local cache state.
  ValueListenable<Box<T>> listenableBox();

  /// Returns all cached items from the provided Hive box.
  ///
  /// This is a helper method used when working directly with a Hive box
  /// instance instead of the repository’s internal box.
  ///
  /// It should not perform any transformation or network request,
  /// and should simply expose the current stored values.
  List<T> getAllFromBox(Box<T> box);

  /// Performs an initial synchronization if local cache is empty.
  ///
  /// Intended for app startup or splash initialization.
  /// Existing local data should remain untouched.
  Future<void> syncIfNeeded();

  /// Forces a full refresh from the remote source.
  ///
  /// This method should replace local cached data
  /// with the latest remote data.
  Future<void> hardRefresh();
}
