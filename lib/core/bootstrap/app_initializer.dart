import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/alert/alert.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/features/comment/comment.dart';
import 'package:fourteen_november/features/stats/stats.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';
import 'package:fourteen_november/features/background/background.dart';
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';

class AppInitializer {
  /// How long startup waits for alerts before carrying on without them.
  ///
  /// Alerts are incidental, so a slow connection should not hold the splash
  /// screen for them. A fetch that outlives this wait is not abandoned: it
  /// still lands in the cache, and the home screen picks it up from there.
  static const Duration _alertWait = Duration(seconds: 4);

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
      AlertRepository().syncIfNeeded().timeout(_alertWait, onTimeout: () {}),
      BackgroundRepository().syncIfNeeded(),
      CommentRepository().syncIfNeeded(),
      GeneralStatsRepository().syncIfNeeded(),
      MoodRepository().syncIfNeeded(),
      PostRepository().syncIfNeeded(),
    ]);
  }
}
