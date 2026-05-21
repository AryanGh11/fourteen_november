import 'package:flutter/material.dart';
import 'package:fourteen_november/theme/app_colors.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/user/user.dart';

part 'mood_model.g.dart';

@HiveType(typeId: 1)
class Mood extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final int value;

  @HiveField(3)
  final String? note;

  @HiveField(4)
  final DateTime created;

  @HiveField(5)
  final DateTime updated;

  Mood({
    required this.id,
    required this.userId,
    required this.value,
    required this.note,
    required this.created,
    required this.updated,
  });

  factory Mood.fromRecordModel(RecordModel model) {
    return Mood(
      id: model.id,
      userId: model.getStringValue("userId"),
      value: model.getIntValue("value"),
      note: model.get("note"),
      created: DateTime.parse(model.get("created")),
      updated: DateTime.parse(model.get("updated")),
    );
  }

  User get user {
    final user = UserRepository().getOne(userId);
    if (user == null) {
      throw ArgumentError("User for mood $id not found");
    }
    return user;
  }

  static IconData getIconForValue(int value) {
    switch (value) {
      case 1:
        return LucideIcons.frown;
      case 2:
        return LucideIcons.annoyed;
      case 3:
        return LucideIcons.meh;
      case 4:
        return LucideIcons.smile;
      case 5:
        return LucideIcons.laugh;
      default:
        return LucideIcons.laugh;
    }
  }

  static Color getColorForValue(int value) {
    switch (value) {
      case 1:
        return AppColors.moodTerrible;
      case 2:
        return AppColors.moodBad;
      case 3:
        return AppColors.moodOkay;
      case 4:
        return AppColors.moodGood;
      case 5:
        return AppColors.moodAmazing;
      default:
        return AppColors.moodAmazing;
    }
  }
}
