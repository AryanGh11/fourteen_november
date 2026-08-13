import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/alert/alert.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';
import 'package:fourteen_november/core/base_repository/base_repository.dart';
import 'package:fourteen_november/services/appwrite/appwrite_constants.dart';

/// Repository responsible for managing cached [Alert] data.
///
/// Follows the same offline-first shape as the other repositories, with two
/// deliberate differences that come from alerts being time bound:
///
/// - Expired alerts are dropped rather than cached indefinitely, both by the
///   remote query and again locally on read. Filtering only on the server
///   would leave a cached alert showing forever once the device went offline.
/// - [syncIfNeeded] always fetches instead of skipping a populated box. A set
///   of alerts goes stale purely through time passing, so "already have some"
///   says nothing about whether they are still the right ones.
class AlertRepository implements BaseRepository<Alert> {
  /// Local Hive box containing cached [Alert] models.
  static Box<Alert> get _box => Hive.box<Alert>(HiveService.alertsBoxKey);

  @override
  /// Returns the alerts that are live right now, newest window first.
  ///
  /// Filtered on read rather than trusted from the cache, so an alert that
  /// expired while the app was open or offline stops being returned without
  /// needing a refresh first.
  List<Alert> getAll() {
    return _activeFrom(_box.values);
  }

  @override
  /// Returns a single cached alert by id, or `null` if it is missing.
  ///
  /// Returns the alert regardless of its window; callers that only want live
  /// alerts should use [getAll] or check [Alert.isActiveAt].
  Alert? getOne(String id) {
    return _box.get(id);
  }

  @override
  /// Returns a reactive Hive box listenable.
  ///
  /// Rebuilds on cache changes only. A widget that must hide an alert the
  /// moment its window closes needs its own timer, since no cache write
  /// happens at that instant.
  ValueListenable<Box<Alert>> listenableBox() {
    return _box.listenable();
  }

  @override
  /// Returns the live alerts from a given box, newest window first.
  List<Alert> getAllFromBox(Box<Alert> box) {
    return _activeFrom(box.values);
  }

  @override
  /// Refreshes the cached alerts from Appwrite.
  ///
  /// Unlike the other repositories this does not skip when the box already
  /// holds something, because alerts expire on their own.
  Future<void> syncIfNeeded() async {
    try {
      await hardRefresh();
    } catch (e) {
      debugPrint("Alert sync failed: $e");
      return;
    }
  }

  @override
  /// Replaces the cached alerts with the ones currently live remotely.
  ///
  /// The box is cleared rather than merged so alerts deleted or expired
  /// remotely do not linger locally.
  Future<void> hardRefresh() async {
    try {
      final alerts = await fetchActive();

      await _box.clear();

      for (final item in alerts) {
        await _box.put(item.id, item);
      }
    } catch (e) {
      debugPrint("Alert refresh failed: $e");
    }
  }

  /// Fetches the alerts whose window contains the current moment.
  ///
  /// Both bounds are compared server side, so expired and not yet started
  /// alerts are never sent over the network. Comparison happens in UTC, which
  /// is how Appwrite stores datetimes, so the window resolves to the same
  /// instant for both people regardless of their time zones.
  Future<List<Alert>> fetchActive() async {
    final now = DateTime.now().toUtc().toIso8601String();

    final result = await AppwriteService.I.tablesDB.listRows(
      databaseId: AppwriteConstants.databaseId,
      tableId: AppwriteTables.alerts,
      queries: [
        Query.lessThanEqual('startAt', now),
        Query.greaterThan('endAt', now),
        Query.orderDesc('startAt'),
      ],
    );

    return result.rows.map((e) => Alert.fromRow(e)).toList();
  }

  /// The single alert to show right now, or `null` if there is none.
  ///
  /// Where several windows overlap the most recently started one wins, so a
  /// newer alert takes over from one that is still running.
  Alert? current() {
    final active = getAll();

    return active.isEmpty ? null : active.first;
  }

  /// Live alerts only, newest window first.
  static List<Alert> _activeFrom(Iterable<Alert> alerts) {
    final now = DateTime.now();

    final active = alerts.where((a) => a.isActiveAt(now)).toList();

    active.sort((a, b) => b.startAt.compareTo(a.startAt));

    return active;
  }
}
