import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/user/user.dart';
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
  /// Appwrite tables API used for remote requests.
  TablesDB get db => AppwriteService.I.tablesDB;

  /// Upper bound on a single fetch.
  ///
  /// Without it a request on a dropped connection never settles, and because
  /// refreshes are shared through [_inFlight], one hung request would silently
  /// swallow every later refresh until the app restarted.
  static const Duration _fetchTimeout = Duration(seconds: 10);

  /// The refresh currently running, shared by every caller.
  ///
  /// Startup and the home screen both ask for alerts within moments of each
  /// other; sharing the request avoids two overlapping writes to the box.
  static Future<void>? _inFlight;

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
  /// Never throws. On failure the cache is left exactly as it was, so the app
  /// keeps showing what it already knew instead of losing it to a bad
  /// connection; expired alerts still drop out, since reads filter by time.
  Future<void> hardRefresh() {
    return _inFlight ??= _refresh().whenComplete(() => _inFlight = null);
  }

  Future<void> _refresh() async {
    try {
      final alerts = await fetchActive();

      final fresh = {for (final alert in alerts) alert.id: alert};
      final stale = _box.keys.where((key) => !fresh.containsKey(key)).toList();

      // New set written before the old one is removed, rather than clearing
      // first: a still-live alert briefly missing from the box would read as
      // having expired, and close its dialog mid-view.
      await _box.putAll(fresh);
      await _box.deleteAll(stale);
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

    final result = await AppwriteService.I.tablesDB
        .listRows(
          databaseId: AppwriteConstants.databaseId,
          tableId: AppwriteTables.alerts,
          queries: [
            Query.lessThanEqual('startAt', now),
            Query.greaterThan('endAt', now),
            Query.orderDesc('startAt'),
          ],
        )
        .timeout(_fetchTimeout);

    return result.rows.map((e) => Alert.fromRow(e)).toList();
  }

  /// The single alert to show right now, or `null` if there is none.
  ///
  /// Excludes alerts the current user has already dismissed, plus any ids in
  /// [excluding]. Where several windows overlap the most recently started one
  /// wins, so a newer alert takes over from one that is still running.
  Alert? current({Iterable<String> excluding = const []}) {
    final userId = UserProviderService().current?.id;

    final visible = getAll().where((a) {
      if (excluding.contains(a.id)) return false;

      // With no current user nothing has been dismissed yet, so the time
      // window alone decides.
      return userId == null || !a.isDismissedBy(userId);
    });

    return visible.isEmpty ? null : visible.first;
  }

  /// Records that the current user has closed [id].
  ///
  /// Stored remotely rather than on the device so a dismissal survives a
  /// reinstall, and so dismissing on one phone does not hide the alert from
  /// the other person.
  ///
  /// Returns the updated [Alert], or the unchanged one when it is not
  /// dismissible or was already dismissed by this user.
  ///
  /// Throws:
  /// - [ArgumentError] if the user or alert is missing
  /// - Any Appwrite/network related exception
  Future<Alert> dismiss(String id) async {
    try {
      final alert = getOne(id);
      final userId = UserProviderService().current?.id;

      if (alert == null || userId == null) {
        throw ArgumentError("User or alert not found");
      }

      if (!alert.dismissible || alert.isDismissedBy(userId)) return alert;

      /// Create immutable copy to avoid mutating cached list reference.
      final dismissedBy = List<String>.from(alert.dismissedBy)..add(userId);

      final row = await db.updateRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteTables.alerts,
        rowId: id,
        data: {"dismissedBy": dismissedBy},
      );

      final updated = Alert.fromRow(row);

      /// Update local cache with latest remote state.
      await _box.put(updated.id, updated);

      return updated;
    } catch (e) {
      debugPrint("Alert dismiss failed: $e");
      rethrow;
    }
  }

  /// Live alerts only, newest window first.
  static List<Alert> _activeFrom(Iterable<Alert> alerts) {
    final now = DateTime.now();

    final active = alerts.where((a) => a.isActiveAt(now)).toList();

    active.sort((a, b) => b.startAt.compareTo(a.startAt));

    return active;
  }
}
