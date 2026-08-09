// Prefixed: appwrite's models export `User` and `Row`, which collide with
// this app's User model and Flutter's Row widget.
import 'package:appwrite/models.dart' as models;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';

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

  factory Background.fromRow(models.Row row) {
    // Holds the Appwrite storage file id, which the view url is built from.
    final imagePath = (row.data["imageId"] as String?) ?? '';

    return Background(
      id: row.$id,
      imagePath: imagePath,
      created: DateTime.parse(row.$createdAt).toLocal(),
      updated: DateTime.parse(row.$updatedAt).toLocal(),
      imageUrl: AppwriteService.fileUrl(imagePath),
    );
  }
}
