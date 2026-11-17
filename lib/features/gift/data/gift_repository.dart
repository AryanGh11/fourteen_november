import 'package:appwrite/appwrite.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:fourteen_november/features/gift/gift.dart';
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';
import 'package:fourteen_november/services/appwrite/appwrite_constants.dart';

/// Why the gift's PDF could not be saved.
enum GiftSaveFailure {
  /// Android 9 and older only: storage permission was refused.
  permissionDenied,

  /// The download itself did not complete.
  downloadFailed,

  /// Downloaded, but could not be moved into the Downloads folder.
  saveFailed,
}

class GiftSaveException implements Exception {
  final GiftSaveFailure failure;

  const GiftSaveException(this.failure);

  @override
  String toString() => 'GiftSaveException($failure)';
}

/// Repository for gifts.
///
/// Deliberately not offline-first and not cached in Hive: a gift's video is
/// streamed and its PDF downloaded, so opening one needs a connection anyway,
/// and a cached row could outlive a gift being withdrawn or replaced.
class GiftRepository {
  static const String _pdfMimeType = 'application/pdf';

  /// Appwrite tables API used for remote requests.
  TablesDB get db => AppwriteService.I.tablesDB;

  /// The gift with [id], or `null` if it does not exist or cannot be opened
  /// yet.
  ///
  /// The opening time is checked on the server, so a gift set up ahead of
  /// its day is not returned at all until then.
  Future<Gift?> fetch(String id) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final result = await db.listRows(
      databaseId: AppwriteConstants.databaseId,
      tableId: AppwriteTables.gifts,
      queries: [
        Query.equal('\$id', id),
        Query.lessThanEqual('availableAt', now),
        Query.limit(1),
      ],
    );

    return result.rows.isEmpty ? null : Gift.fromRow(result.rows.first);
  }

  /// The most recently opened-up gift, or `null` if none is available yet.
  Future<Gift?> latestAvailable() async {
    final now = DateTime.now().toUtc().toIso8601String();

    final result = await db.listRows(
      databaseId: AppwriteConstants.databaseId,
      tableId: AppwriteTables.gifts,
      queries: [
        Query.lessThanEqual('availableAt', now),
        Query.orderDesc('availableAt'),
        Query.limit(1),
      ],
    );

    return result.rows.isEmpty ? null : Gift.fromRow(result.rows.first);
  }

  /// Downloads the gift's PDF into the device's Downloads folder.
  ///
  /// Returns the saved file's path. Android 10 and newer need no permission
  /// for this; older versions are asked for storage access first.
  ///
  /// Throws a [GiftSaveException] naming the step that failed.
  Future<String> savePdfToDownloads(Gift gift) async {
    final permissions = FileDownloader().permissions;

    var status = await permissions.status(PermissionType.androidSharedStorage);

    if (status != PermissionStatus.granted) {
      status = await permissions.request(PermissionType.androidSharedStorage);
    }

    if (status != PermissionStatus.granted) {
      throw const GiftSaveException(GiftSaveFailure.permissionDenied);
    }

    final task = DownloadTask(
      url: gift.pdfUrl,
      filename: gift.pdfName,
      // Not applicationDocuments: Android cannot open files from there, and
      // this is only a staging area before the move to Downloads anyway.
      baseDirectory: BaseDirectory.applicationSupport,
      retries: 3,
    );

    final result = await FileDownloader().download(task);

    if (result.status != TaskStatus.complete) {
      throw const GiftSaveException(GiftSaveFailure.downloadFailed);
    }

    final path = await FileDownloader().moveToSharedStorage(
      task,
      SharedStorage.downloads,
      mimeType: _pdfMimeType,
    );

    if (path == null) {
      throw const GiftSaveException(GiftSaveFailure.saveFailed);
    }

    return path;
  }

  /// Opens a saved PDF in whatever PDF viewer the device has.
  ///
  /// Returns `false` if it could not be opened, e.g. no viewer is installed;
  /// the file is still saved in Downloads in that case.
  Future<bool> openPdf(String path) {
    return FileDownloader().openFile(filePath: path, mimeType: _pdfMimeType);
  }
}
