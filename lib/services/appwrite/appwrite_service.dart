import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:fourteen_november/services/appwrite/appwrite_constants.dart';

/// Singleton wrapper around the Appwrite client.
///
/// Mirrors the shape of the former PocketBaseService so repositories keep
/// reaching the backend through a single initialized entry point.
///
/// Unlike the PocketBase setup this needs no runtime configuration: the
/// endpoint is permanent, so there is no url to fetch, cache or paste.
class AppwriteService {
  static AppwriteService? _instance;

  late final Client client;
  late final TablesDB tablesDB;
  late final Storage storage;

  AppwriteService._internal();

  static Future<AppwriteService> init() async {
    final instance = AppwriteService._internal();

    instance.client = Client()
        .setEndpoint(AppwriteConstants.endpoint)
        .setProject(AppwriteConstants.projectId);

    instance.tablesDB = TablesDB(instance.client);
    instance.storage = Storage(instance.client);

    _instance = instance;

    return instance;
  }

  static AppwriteService get I {
    if (_instance == null) {
      throw Exception("AppwriteService not initialized");
    }

    return _instance!;
  }

  /// Rows fetched per request while paging. Appwrite's own maximum.
  static const int _pageSize = 100;

  /// Fetches every row of a table, following pagination to the end.
  ///
  /// `listRows` returns only the first 25 rows unless told otherwise, so
  /// calling it directly silently truncates any table that outgrows a single
  /// page - records exist remotely but never reach the local cache. This is
  /// the equivalent of PocketBase's `getFullList()`, which paged internally.
  ///
  /// Cursor paging is used rather than offsets so that rows created while the
  /// sync is running cannot shift the window and cause skips or duplicates.
  static Future<List<models.Row>> listAllRows(String tableId) async {
    final rows = <models.Row>[];

    String? cursor;

    while (true) {
      final page = await I.tablesDB.listRows(
        databaseId: AppwriteConstants.databaseId,
        tableId: tableId,
        queries: [
          Query.limit(_pageSize),
          if (cursor != null) Query.cursorAfter(cursor),
        ],
      );

      rows.addAll(page.rows);

      if (page.rows.length < _pageSize) break;

      cursor = page.rows.last.$id;
    }

    return rows;
  }

  /// Builds a publicly viewable url for a stored file.
  ///
  /// The Dart SDK's `getFileView` downloads the bytes instead of returning a
  /// url, so the view endpoint is composed by hand here. This is the direct
  /// replacement for PocketBase's `pb.files.getURL(...)`.
  ///
  /// Returns an empty string for an empty [fileId] so models can keep
  /// representing "no file" the same way they did before.
  static String fileUrl(String fileId, {String? bucketId}) {
    if (fileId.isEmpty) return '';

    final bucket = bucketId ?? AppwriteConstants.mediaBucketId;

    return '${AppwriteConstants.endpoint}'
        '/storage/buckets/$bucket/files/$fileId/view'
        '?project=${AppwriteConstants.projectId}';
  }
}
