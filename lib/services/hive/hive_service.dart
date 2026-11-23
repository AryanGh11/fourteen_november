import 'package:path_provider/path_provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/alert/alert.dart';
import 'package:fourteen_november/features/stats/stats.dart';
import 'package:fourteen_november/features/period/period.dart';
import 'package:fourteen_november/features/comment/comment.dart';
import 'package:fourteen_november/features/background/background.dart';

class HiveService {
  static final String sharedPerformanceBoxKey = "sharedPerformanceBox";
  static final String alertsBoxKey = "alertsBox";
  static final String backgroundsBoxKey = "backgroundsBox";
  static final String commentsBoxKey = "commentsBox";
  static final String generalStatsBoxKey = "generalStatsBox";
  static final String moodsBoxKey = "moodsBox";
  static final String gymBoxKey = "gymBox";
  static final String periodsBoxKey = "periodsBox";
  static final String postsBoxKey = "postsBox";
  static final String usersBoxKey = "usersBox";

  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Adapters
    Hive.registerAdapter(AlertAdapter());
    Hive.registerAdapter(AlertKindAdapter());
    Hive.registerAdapter(BackgroundAdapter());
    Hive.registerAdapter(CommentAdapter());
    Hive.registerAdapter(GeneralStatsAdapter());
    Hive.registerAdapter(MoodAdapter());
    Hive.registerAdapter(PeriodAdapter());
    Hive.registerAdapter(PostAdapter());
    Hive.registerAdapter(UserAdapter());

    // Boxes
    await Hive.openBox(sharedPerformanceBoxKey);
    await Hive.openBox<Alert>(alertsBoxKey);
    await Hive.openBox<Background>(backgroundsBoxKey);
    await Hive.openBox<Comment>(commentsBoxKey);
    await Hive.openBox<GeneralStats>(generalStatsBoxKey);
    await Hive.openBox<Mood>(moodsBoxKey);
    await Hive.openBox<Period>(periodsBoxKey);
    await Hive.openBox(gymBoxKey);
    await Hive.openBox<Post>(postsBoxKey);
    await Hive.openBox<User>(usersBoxKey);
  }

  static Future<void> hardRefreshBoxes() async {
    await AlertRepository().hardRefresh();
    await BackgroundRepository().hardRefresh();
    await CommentRepository().hardRefresh();
    await GeneralStatsRepository().hardRefresh();
    await MoodRepository().hardRefresh();
    await PeriodRepository().hardRefresh();
    await PostRepository().hardRefresh();
    await UserRepository().hardRefresh();
  }
}
