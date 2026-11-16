// Prefixed: appwrite's models export `User` and `Row`, which collide with
// this app's User model and Flutter's Row widget.
import 'package:appwrite/models.dart' as models;
import 'package:fourteen_november/services/appwrite/appwrite_service.dart';

/// A gift: a video to watch first, then a PDF that is saved and opened once it
/// has finished.
class Gift {
  final String id;
  final String title;

  /// Streamed rather than downloaded, so it starts playing straight away.
  final String videoUrl;

  final String pdfUrl;

  /// File name the PDF is saved under in the Downloads folder.
  final String pdfName;

  /// Moment the gift can first be opened. Before it, the gift is not returned
  /// at all, so it cannot be found early.
  final DateTime availableAt;

  const Gift({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.pdfUrl,
    required this.pdfName,
    required this.availableAt,
  });

  factory Gift.fromRow(models.Row row) {
    final data = row.data;

    final pdfName = (data["pdfName"] as String?) ?? '';

    return Gift(
      id: row.$id,
      title: (data["title"] as String?) ?? '',
      videoUrl: AppwriteService.fileUrl((data["videoId"] as String?) ?? ''),
      pdfUrl: AppwriteService.fileUrl((data["pdfId"] as String?) ?? ''),
      // Downloads needs a real file name with an extension to be openable.
      pdfName: pdfName.isEmpty ? 'gift.pdf' : pdfName,
      availableAt: DateTime.parse(data["availableAt"] as String).toLocal(),
    );
  }
}
