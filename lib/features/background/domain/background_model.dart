import 'package:pocketbase/pocketbase.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';
import 'package:fourteen_november/features/background/domain/background_model_extension.dart';

part 'background_model.g.dart';

@HiveType(typeId: 2)
class Background extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(6)
  final DateTime created;

  @HiveField(7)
  final DateTime updated;

  Background({
    required this.id,
    required this.imagePath,
    required this.created,
    required this.updated,
  });

  factory Background.fromRecordModel(RecordModel model) {
    return Background(
      id: model.id,
      imagePath: model.getStringValue("image"),
      created: DateTime.parse(model.get("created")),
      updated: DateTime.parse(model.get("updated")),
    );
  }

  Future<String> get imageUrl async {
    final pb = PocketBaseService.I.instance;
    final recordModel = await toRecordModel();

    return pb.files.getURL(recordModel, imagePath).toString();
  }
}
