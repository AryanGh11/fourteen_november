import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/features/comment/comment.dart';
import 'package:fourteen_november/features/background/background.dart';

class HiveService {
  static final String sharedPerformanceBoxKey = "sharedPerformanceBox";
  static final String backgroundsBoxKey = "backgroundsBox";
  static final String commentsBoxKey = "commentsBox";
  static final String moodsBoxKey = "moodsBox";
  static final String postsBoxKey = "postsBox";
  static final String usersBoxKey = "usersBox";

  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Adapters
    Hive.registerAdapter(BackgroundAdapter());
    Hive.registerAdapter(CommentAdapter());
    Hive.registerAdapter(MoodAdapter());
    Hive.registerAdapter(PostAdapter());
    Hive.registerAdapter(UserAdapter());

    // Boxes
    await Hive.openBox(sharedPerformanceBoxKey);
    await Hive.openBox<Background>(backgroundsBoxKey);
    await Hive.openBox<Comment>(commentsBoxKey);
    await Hive.openBox<Mood>(moodsBoxKey);
    await Hive.openBox<Post>(postsBoxKey);
    await Hive.openBox<User>(usersBoxKey);
  }
}
