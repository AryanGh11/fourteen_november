// Prefixed: appwrite's models export `User` and `Row`, which collide with
// this app's User model and Flutter's Row widget.
import 'package:appwrite/models.dart' as models;
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/user/user.dart';

part 'period_model.g.dart';

/// A single menstrual period entry.
@HiveType(typeId: 8)
class Period extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  /// The start date of the period.
  @HiveField(2)
  final DateTime periodDate;

  /// Number of days since the previous period (cycle length).
  /// This is calculated and stored for quick access.
  @HiveField(3)
  final int? daysFromPrevious;

  /// The calculated cycle length in days (days between this period and the next).
  /// This will be updated when the next period is added.
  @HiveField(4, defaultValue: 0)
  final int cycleLength;

  @HiveField(5)
  final DateTime created;

  @HiveField(6)
  final DateTime updated;

  Period({
    required this.id,
    required this.userId,
    required this.periodDate,
    this.daysFromPrevious,
    this.cycleLength = 0,
    required this.created,
    required this.updated,
  });

  factory Period.fromRow(models.Row row) {
    final data = row.data;

    return Period(
      id: row.$id,
      userId: (data["userId"] as String?) ?? '',
      periodDate: DateTime.parse(data["periodDate"] as String).toLocal(),
      daysFromPrevious: (data["daysFromPrevious"] as num?)?.toInt(),
      cycleLength: (data["cycleLength"] as num?)?.toInt() ?? 0,
      created: DateTime.parse(row.$createdAt).toLocal(),
      updated: DateTime.parse(row.$updatedAt).toLocal(),
    );
  }

  User get user {
    final user = UserRepository().getOne(userId);
    if (user == null) {
      throw ArgumentError("User for period $id not found");
    }
    return user;
  }

  /// Whether this period has a previous period to calculate cycle from.
  bool get hasPreviousPeriod => daysFromPrevious != null;

  /// Whether the cycle length has been calculated (next period exists).
  bool get hasCycleLength => cycleLength > 0;

  /// Formatted period date for display.
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final periodDay = DateTime(periodDate.year, periodDate.month, periodDate.day);

    if (periodDay == today) return "امروز";
    if (periodDay == today.subtract(const Duration(days: 1))) return "دیروز";
    if (periodDay == today.add(const Duration(days: 1))) return "فردا";

    return "${periodDate.day} ${_monthName(periodDate.month)} ${periodDate.year}";
  }

  String _monthName(int month) {
    const months = [
      'ژانویه', 'فوریه', 'مارس', 'آوریل', 'مه', 'ژوئن',
      'ژوئیه', 'اوت', 'سپتامبر', 'اکتبر', 'نوامبر', 'دسامبر'
    ];
    return months[month - 1];
  }
}