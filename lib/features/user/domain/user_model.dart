import 'package:pocketbase/pocketbase.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';
import 'package:fourteen_november/features/user/domain/user_model_extension.dart';

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

  User({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.email,
    required this.emailVisibility,
    required this.verified,
    required this.created,
    required this.updated,
  });

  factory User.fromRecordModel(RecordModel model) {
    return User(
      id: model.id,
      name: model.getStringValue("name"),
      avatarPath: model.getStringValue("avatar"),
      email: model.getStringValue("email"),
      emailVisibility: model.getBoolValue("emailVisibility"),
      verified: model.getBoolValue("verified"),
      created: DateTime.parse(model.get("created")),
      updated: DateTime.parse(model.get("updated")),
    );
  }

  Future<String> get avatarUrl async {
    final pb = PocketBaseService.I.instance;
    final recordModel = await toRecordModel();

    return pb.files.getURL(recordModel, avatarPath).toString();
  }
}
