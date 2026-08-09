import 'package:pocketbase/pocketbase.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

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

  factory User.fromRecordModel(RecordModel model) {
    final pb = PocketBaseService.I.instance;

    final avatarPath = model.getStringValue("avatar");
    final url = pb.files.getURL(model, avatarPath).toString();

    return User(
      id: model.id,
      name: model.getStringValue("name"),
      avatarPath: avatarPath,
      email: model.getStringValue("email"),
      emailVisibility: model.getBoolValue("emailVisibility"),
      verified: model.getBoolValue("verified"),
      created: DateTime.parse(model.get("created")).toLocal(),
      updated: DateTime.parse(model.get("updated")).toLocal(),
      avatarUrl: url,
      cityName: model.getStringValue("cityName"),
      locationLat: model.getDoubleValue("locationLat"),
      locationLng: model.getDoubleValue("locationLng"),
    );
  }
}
