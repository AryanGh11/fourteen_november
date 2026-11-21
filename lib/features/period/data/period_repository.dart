import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/period/period.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/core/base_repository/base_repository.dart';
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';
import 'package:fourteen_november/services/appwrite/appwrite_constants.dart';

/// Repository responsible for managing cached [Period] data.
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
class PeriodRepository implements BaseRepository<Period> {
  /// Appwrite tables API used for remote requests.
  TablesDB get db => AppwriteService.I.tablesDB;

  /// Appwrite storage API used for file uploads.
  Storage get files => AppwriteService.I.storage;

  /// Local Hive box containing cached [Period] models.
  static Box<Period> get _box => Hive.box<Period>(HiveService.periodsBoxKey);

  @override
  /// Returns all cached periods from local storage, sorted by date (newest first).
  ///
  /// This method is completely offline and does not perform
  /// any network requests.
  List<Period> getAll() {
    final periods = _box.values.toList();
    periods.sort((a, b) => b.periodDate.compareTo(a.periodDate));
    return periods;
  }

  /// Returns all cached periods sorted by date (oldest first).
  /// Useful for calculating cycle lengths.
  List<Period> getAllSortedOldestFirst() {
    final periods = _box.values.toList();
    periods.sort((a, b) => a.periodDate.compareTo(b.periodDate));
    return periods;
  }

  @override
  /// Returns a single cached period by its id.
  ///
  /// Returns `null` if the item does not exist locally.
  Period? getOne(String id) {
    return _box.get(id);
  }

  @override
  /// Returns a reactive Hive box listenable.
  ///
  /// Used by UI to automatically rebuild when data changes.
  ValueListenable<Box<Period>> listenableBox() {
    return _box.listenable();
  }

  @override
  /// Returns all items from a given Hive box.
  ///
  /// Utility method for generic access when working with external boxes.
  List<Period> getAllFromBox(Box<Period> box) {
    return box.values.toList().cast<Period>();
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

      final rows = await AppwriteService.listAllRows(AppwriteTables.periods);

      final periods = rows.map((e) => Period.fromRow(e)).toList();

      for (final item in periods) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint("Period sync failed: $e");
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
      final rows = await AppwriteService.listAllRows(AppwriteTables.periods);

      final periods = rows.map((e) => Period.fromRow(e)).toList();

      await _box.clear();

      for (final item in periods) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint("Period refresh failed: $e");
    }
  }

  /// Creates a new period record and calculates days from previous period.
  ///
  /// This method works offline-first:
  /// - Creates the period locally immediately (works without internet)
  /// - Calculates days from previous period
  /// - Updates previous period's cycle length locally
  /// - Attempts to sync to Appwrite in background (non-blocking)
  /// - Returns the cached instance
  Future<Period> create(PeriodCreatePayload payload) async {
    try {
      final userId = UserProviderService().current?.id;

      if (userId == null) {
        throw ArgumentError("User not found");
      }

      // Find the previous period to calculate days from previous
      final allPeriods = getAllSortedOldestFirst();
      Period? previousPeriod;
      int? daysFromPrevious;

      for (final period in allPeriods) {
        if (period.periodDate.isBefore(payload.periodDate)) {
          previousPeriod = period;
        }
      }

      if (previousPeriod != null) {
        daysFromPrevious = payload.periodDate.difference(previousPeriod.periodDate).inDays;

        // Update the previous period's cycle length locally
        final updatedPrevious = Period(
          id: previousPeriod.id,
          userId: previousPeriod.userId,
          periodDate: previousPeriod.periodDate,
          daysFromPrevious: previousPeriod.daysFromPrevious,
          cycleLength: daysFromPrevious,
          created: previousPeriod.created,
          updated: DateTime.now(),
        );
        await _box.put(updatedPrevious.id, updatedPrevious);

        // Try to update in Appwrite (non-blocking)
        _syncPreviousPeriodCycleLength(previousPeriod.id, daysFromPrevious);
      }

      // Create new period locally with a local ID first
      final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();
      final newPeriod = Period(
        id: localId,
        userId: userId,
        periodDate: payload.periodDate,
        daysFromPrevious: daysFromPrevious,
        cycleLength: 0,
        created: now,
        updated: now,
      );

      // Save locally immediately - this works offline!
      await _box.put(newPeriod.id, newPeriod);

      // Try to sync to Appwrite in background (non-blocking)
      _syncPeriodToAppwrite(newPeriod, userId);

      return newPeriod;
    } catch (e) {
      debugPrint("Period create failed: $e");
      rethrow;
    }
  }

  /// Sync a period to Appwrite in background (non-blocking)
  void _syncPeriodToAppwrite(Period period, String userId) {
    Future(() async {
      try {
        final row = await db.createRow(
          databaseId: AppwriteConstants.databaseId,
          tableId: AppwriteTables.periods,
          rowId: ID.unique(),
          data: {
            "userId": userId,
            "periodDate": period.periodDate.toIso8601String(),
            "daysFromPrevious": period.daysFromPrevious,
            "cycleLength": period.cycleLength,
          },
        );

        // Replace local entry with server entry
        final serverPeriod = Period.fromRow(row);
        await _box.delete(period.id);
        await _box.put(serverPeriod.id, serverPeriod);
      } catch (e) {
        debugPrint("Background sync failed for period ${period.id}: $e");
        // Keep local entry, will retry on next hardRefresh
      }
    });
  }

  /// Sync previous period's cycle length to Appwrite in background
  void _syncPreviousPeriodCycleLength(String periodId, int cycleLength) {
    Future(() async {
      try {
        await db.updateRow(
          databaseId: AppwriteConstants.databaseId,
          tableId: AppwriteTables.periods,
          rowId: periodId,
          data: {"cycleLength": cycleLength},
        );
      } catch (e) {
        debugPrint("Background sync failed for previous period cycle length: $e");
      }
    });
  }

  /// Deletes a period record.
  ///
  /// This method:
  /// - Sends delete request to Appwrite
  /// - Deletes the model locally inside Hive
  ///
  /// Note: This does not recalculate cycle lengths for adjacent periods.
  /// For a better UX, consider implementing a full recalculation.
  Future<void> delete(String id) async {
    try {
      await db.deleteRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteTables.periods,
        rowId: id,
      );

      await _box.delete(id);
    } catch (e) {
      debugPrint("Period delete failed: $e");
      rethrow;
    }
  }

  /// Gets the average cycle length from all periods that have cycle data.
  double? getAverageCycleLength() {
    final periods = getAll();
    final periodsWithCycle = periods.where((p) => p.hasCycleLength).toList();

    if (periodsWithCycle.isEmpty) return null;

    final sum = periodsWithCycle.fold<int>(0, (sum, p) => sum + p.cycleLength);
    return sum / periodsWithCycle.length;
  }

  /// Gets the latest period entry.
  Period? getLatestPeriod() {
    final periods = getAll();
    if (periods.isEmpty) return null;
    return periods.first;
  }

  /// Gets the estimated next period date based on average cycle length.
  DateTime? getEstimatedNextPeriod() {
    final latest = getLatestPeriod();
    final avgCycle = getAverageCycleLength();

    if (latest == null || avgCycle == null) return null;

    return latest.periodDate.add(Duration(days: avgCycle.round()));
  }
}