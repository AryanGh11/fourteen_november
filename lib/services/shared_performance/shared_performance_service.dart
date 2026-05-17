import 'package:hive_flutter/hive_flutter.dart';
import 'package:fourteen_november/services/hive/hive_service.dart';

class SharedPerformanceService {
  static Box get _box => Hive.box(HiveService.sharedPerformanceBoxKey);

  static T? get<T>(String key) {
    return _box.get(key);
  }

  static Future<void> put<T>(String key, T value) {
    return _box.put(key, value);
  }
}
