import 'package:pocketbase/pocketbase.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

part 'background_model.g.dart';

@HiveType(typeId: 2)
class Background extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(3)
  final DateTime created;

  @HiveField(4)
  final DateTime updated;

  @HiveField(5)
  final String imageUrl;

  Background({
    required this.id,
    required this.imagePath,
    required this.created,
    required this.updated,
    required this.imageUrl,
  });

  factory Background.fromRecordModel(RecordModel model) {
    final pb = PocketBaseService.I.instance;

    final imagePath = model.getStringValue("image");
    final url = pb.files.getURL(model, imagePath).toString();

    return Background(
      id: model.id,
      imagePath: imagePath,
      created: DateTime.parse(model.get("created")),
      updated: DateTime.parse(model.get("updated")),
      imageUrl: url,
    );
  }
}
