import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/features/comment/comment.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/features/background/background.dart';
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';

class AppInitializer {
  static Future<void> init() async {
    // Initialize timezone
    tz.initializeDatabase([]);
    tz_data.initializeTimeZones();

    // Initialize hive
    await HiveService.init();

    // Initialize appwrite
    await AppwriteService.init();

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
