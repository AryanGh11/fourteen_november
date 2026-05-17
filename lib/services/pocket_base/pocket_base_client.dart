import "package:http/http.dart" as http;

import 'package:pocketbase/pocketbase.dart';

class PocketBaseClient {
  final PocketBase _pb;

  PocketBaseClient(String baseUrl) : _pb = PocketBase(baseUrl);

  Future<T> send<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic> body = const {},
    Map<String, String> headers = const {},
    List<http.MultipartFile> files = const [],
    Map<String, dynamic> query = const {},
  }) {
    return _pb.send<T>(
      path,
      method: method,
      body: body,
      files: files,
      query: query,
      headers: {...headers, "ngrok-skip-browser-warning": "true"},
    );
  }

  // expose original instance if needed
  PocketBase get raw => _pb;
}
