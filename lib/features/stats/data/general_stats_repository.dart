import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/stats/stats.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/core/base_repository/base_repository.dart';
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';
import 'package:fourteen_november/services/appwrite/appwrite_constants.dart';

/// Repository responsible for the cached [GeneralStats] row.
///
/// Offline-first like the other repositories, so the stats screen keeps
/// counting without a connection. The remote table holds a single row, read
/// directly by id; [current] is the way to read it.
///
/// Read only: the dates are changed on the server, never from the app.
class GeneralStatsRepository implements BaseRepository<GeneralStats> {
  /// Id of the one row in the `generalStats` table.
  static const String rowId = 'main';

  /// Appwrite tables API used for remote requests.
  TablesDB get db => AppwriteService.I.tablesDB;

  /// Local Hive box containing the cached [GeneralStats].
  static Box<GeneralStats> get _box =>
      Hive.box<GeneralStats>(HiveService.generalStatsBoxKey);

  /// The cached stats, or `null` before they have ever been fetched.
  GeneralStats? get current => _box.get(rowId);

  @override
  List<GeneralStats> getAll() {
    return _box.values.toList();
  }

  @override
  GeneralStats? getOne(String id) {
    return _box.get(id);
  }

  @override
  ValueListenable<Box<GeneralStats>> listenableBox() {
    return _box.listenable();
  }

  @override
  List<GeneralStats> getAllFromBox(Box<GeneralStats> box) {
    return box.values.toList();
  }

  @override
  /// Fetches the stats only when nothing is cached yet.
  ///
  /// Startup does not need the very latest copy; the stats screen refreshes
  /// on open, which is where an updated date actually matters.
  Future<void> syncIfNeeded() async {
    if (_box.isNotEmpty) return;

    await hardRefresh();
  }

  @override
  /// Replaces the cached stats with the server's copy.
  ///
  /// Never throws. On failure the cached copy is kept rather than cleared, so
  /// the stats screen keeps counting from the last known dates.
  Future<void> hardRefresh() async {
    try {
      final row = await db.getRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteTables.generalStats,
        rowId: rowId,
      );

      final stats = GeneralStats.fromRow(row);

      await _box.put(stats.id, stats);
    } catch (e) {
      debugPrint("General stats refresh failed: $e");
    }
  }
}
