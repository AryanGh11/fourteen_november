import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/features/comment/comment.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/features/background/background.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

class AppInitializer {
  static Future<void> init() async {
    // Initialize hive
    await HiveService.init();

    // Initialize pocket base
    await PocketBaseService.init();

    // Check if any of models needs to be synced
    await Future.wait([
      UserRepository().syncIfNeeded(),

      BackgroundRepository().syncIfNeeded(),
      CommentRepository().syncIfNeeded(),
      MoodRepository().syncIfNeeded(),
      PostRepository().syncIfNeeded(),
    ]);
  }
}
