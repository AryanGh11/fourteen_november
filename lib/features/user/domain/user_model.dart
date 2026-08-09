// Prefixed: appwrite's models export `User` and `Row`, which collide with
// this app's User model and Flutter's Row widget.
import 'package:appwrite/models.dart' as models;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String avatarPath;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final bool emailVisibility;

  @HiveField(5)
  final bool verified;

  @HiveField(6)
  final DateTime created;

  @HiveField(7)
  final DateTime updated;

  @HiveField(8)
  final String avatarUrl;

  @HiveField(9, defaultValue: '')
  final String cityName;

  @HiveField(10, defaultValue: 0)
  final double locationLat;

  @HiveField(11, defaultValue: 0)
  final double locationLng;

  User({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.email,
    required this.emailVisibility,
    required this.verified,
    required this.created,
    required this.updated,
    required this.avatarUrl,
    required this.cityName,
    required this.locationLat,
    required this.locationLng,
  });

  factory User.fromRow(models.Row row) {
    final data = row.data;

    // Holds the Appwrite storage file id, which the view url is built from.
    final avatarPath = (data["avatarId"] as String?) ?? '';

    return User(
      id: row.$id,
      name: (data["name"] as String?) ?? '',
      avatarPath: avatarPath,
      email: (data["email"] as String?) ?? '',
      // Not stored remotely: the app has no login, so these were always
      // constant. Kept on the model so the Hive adapter stays unchanged.
      emailVisibility: true,
      verified: true,
      created: DateTime.parse(row.$createdAt).toLocal(),
      updated: DateTime.parse(row.$updatedAt).toLocal(),
      avatarUrl: AppwriteService.fileUrl(avatarPath),
      cityName: (data["cityName"] as String?) ?? '',
      locationLat: (data["locationLat"] as num?)?.toDouble() ?? 0,
      locationLng: (data["locationLng"] as num?)?.toDouble() ?? 0,
    );
  }
}
