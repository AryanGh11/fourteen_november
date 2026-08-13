// Prefixed: appwrite's models export `User` and `Row`, which collide with
// this app's User model and Flutter's Row widget.
import 'package:appwrite/models.dart' as models;
import 'package:hive_flutter/hive_flutter.dart';

part 'alert_model.g.dart';

/// A message shown inside the app for a bounded window of time.
///
/// Unlike the other models this one is only meaningful relative to the current
/// time: the same row is worth showing before [endAt] and worth ignoring after
/// it, without anything about the row itself changing.
@HiveType(typeId: 5)
class Alert extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  /// Moment the alert becomes visible. Stored in local time.
  @HiveField(2)
  final DateTime startAt;

  /// Moment the alert stops being visible. Stored in local time.
  @HiveField(3)
  final DateTime endAt;

  @HiveField(4)
  final DateTime created;

  @HiveField(5)
  final DateTime updated;

  Alert({
    required this.id,
    required this.content,
    required this.startAt,
    required this.endAt,
    required this.created,
    required this.updated,
  });

  factory Alert.fromRow(models.Row row) {
    final data = row.data;

    return Alert(
      id: row.$id,
      content: (data["content"] as String?) ?? '',
      startAt: DateTime.parse(data["startAt"] as String).toLocal(),
      endAt: DateTime.parse(data["endAt"] as String).toLocal(),
      created: DateTime.parse(row.$createdAt).toLocal(),
      updated: DateTime.parse(row.$updatedAt).toLocal(),
    );
  }

  /// Whether the alert should be shown at [at], defaulting to now.
  ///
  /// The window is half open: an alert is live from [startAt] inclusive until
  /// [endAt] exclusive, so back to back alerts cannot both be live for the
  /// instant they meet.
  bool isActiveAt([DateTime? at]) {
    final moment = at ?? DateTime.now();

    return !moment.isBefore(startAt) && moment.isBefore(endAt);
  }

  /// Whether the window has already closed.
  bool get isExpired => !DateTime.now().isBefore(endAt);

  /// Whether the window has not opened yet.
  bool get isScheduled => DateTime.now().isBefore(startAt);

  /// Time left before the alert stops being shown.
  ///
  /// [Duration.zero] once expired, so callers can drive a countdown without
  /// having to guard against negative values.
  Duration get remaining {
    final left = endAt.difference(DateTime.now());

    return left.isNegative ? Duration.zero : left;
  }
}
