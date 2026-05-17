import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fourteen_november/features/user/user.dart';

class HiveService {
  static final String sharedPerformanceBoxKey = "sharedPerformanceBox";

  static Future<void> initialize() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Adapters
    Hive.registerAdapter(UserAdapter());

    // Boxes
    await Hive.openBox(sharedPerformanceBoxKey);
  }
}
