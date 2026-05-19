import 'package:pocketbase/pocketbase.dart';
import 'package:fourteen_november/services/shared_performance/shared_performance_service.dart';

class PocketBaseService {
  static final String _fallbackPocketBaseUrl = 'http://172.20.10.8:8090';
  static PocketBaseService? _instance;

  late final PocketBase instance;

  PocketBaseService._internal();

  static Future<PocketBaseService> init() async {
    final String? url = SharedPerformanceService.get('pocketBaseUrl');

    if (url == null) {
      await SharedPerformanceService.put(
        'pocketBaseUrl',
        _fallbackPocketBaseUrl,
      );
    }

    _instance ??= PocketBaseService._internal();
    _instance!.instance = PocketBase("https://6056-92-246-87-191.ngrok-free.app");

    return _instance!;
  }

  static PocketBaseService get I {
    if (_instance == null) {
      throw Exception("PocketBaseService not initialized");
    }

    return _instance!;
  }
}
