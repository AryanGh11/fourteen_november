import 'dart:io';
import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  static final _http = HttpClient();
  static final String _configJsonUrl =
      "https://raw.githubusercontent.com/AryanGh11/fourteen_november/refs/heads/main/config.json";

  static PocketBaseService? _instance;

  late final PocketBase instance;

  PocketBaseService._internal();

  static Future<PocketBaseService> initialize() async {
    final request = await _http.getUrl(Uri.parse(_configJsonUrl));
    final response = await request.close();

    final body = await response.transform(utf8.decoder).join();
    final url = jsonDecode(body)['pocketBaseUrl'];

    _instance ??= PocketBaseService._internal();
    _instance!.instance = PocketBase(url);

    return _instance!;
  }

  static PocketBaseService get I {
    if (_instance == null) {
      throw Exception("PocketBaseService not initialized");
    }

    return _instance!;
  }
}
