import 'package:flutter/services.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:fourteen_november/services/shared_performance/shared_performance_service.dart';

class PocketBaseService {
  static final String _fallbackPocketBaseUrl =
      'https://bda6-2a09-bac5-2a97-246e-00-3a1-25.ngrok-free.app';
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

    _instance = PocketBaseService._internal();
    _instance!.instance = PocketBase(url ?? _fallbackPocketBaseUrl);

    return _instance!;
  }

  static PocketBaseService get I {
    if (_instance == null) {
      throw Exception("PocketBaseService not initialized");
    }

    return _instance!;
  }

  static Future<void> pasteUrl() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();

    if (text == null) return;

    final urlRegex = RegExp(
      r'^(https?:\/\/)'
      r'('
      r'(([a-zA-Z0-9_-]+\.)+[a-zA-Z]{2,})' // domain
      r'|'
      r'((\d{1,3}\.){3}\d{1,3})' // IPv4
      r'|'
      r'(localhost)' // localhost
      r')'
      r'(:\d+)?'
      r'(\/.*)?$',
    );

    if (!urlRegex.hasMatch(text)) return;

    await SharedPerformanceService.put('pocketBaseUrl', text);
    await PocketBaseService.init();
  }
}
