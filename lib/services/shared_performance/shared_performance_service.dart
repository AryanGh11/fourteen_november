import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';

class SharedPerformanceService {
  static Box get _box => Hive.box(HiveService.sharedPerformanceBoxKey);

  static String? get(String key) {
    return _box.get(key);
  }

  static Future<void> put(String key, String value) {
    return _box.put(key, value);
  }
}
