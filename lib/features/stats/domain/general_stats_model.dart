// Prefixed: appwrite's models export `User` and `Row`, which collide with
// this app's User model and Flutter's Row widget.
import 'package:appwrite/models.dart' as models;
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'general_stats_model.g.dart';

/// The relationship dates the stats screen counts from.
///
/// Held on the server as a single row rather than in the app, so they can be
/// updated after a visit without shipping a new build, and so both phones
/// count from the same instant.
@HiveType(typeId: 6)
class GeneralStats extends HiveObject {
  @HiveField(0)
  final String id;

  /// When the two of us last saw each other.
  @HiveField(1)
  final DateTime lastHugAt;

  /// When the relationship began.
  @HiveField(2)
  final DateTime togetherSince;

  @HiveField(3)
  final DateTime created;

  @HiveField(4)
  final DateTime updated;

  GeneralStats({
    required this.id,
    required this.lastHugAt,
    required this.togetherSince,
    required this.created,
    required this.updated,
  });

  factory GeneralStats.fromRow(models.Row row) {
    final data = row.data;

    return GeneralStats(
      id: row.$id,
      // Stored as UTC; converted on the way in so every consumer works in the
      // phone's own time, as the rest of the models do.
      lastHugAt: DateTime.parse(data["lastHugAt"] as String).toLocal(),
      togetherSince: DateTime.parse(data["togetherSince"] as String).toLocal(),
      created: DateTime.parse(row.$createdAt).toLocal(),
      updated: DateTime.parse(row.$updatedAt).toLocal(),
    );
  }
}
