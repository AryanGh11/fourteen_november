import 'package:pocketbase/pocketbase.dart';
import 'package:fourteen_november/features/comment/comment.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

extension CommentModelExtension on Comment {
  Future<RecordModel> toRecordModel() async {
    final String collectionName = "comments";
    final pb = PocketBaseService.I.instance;

    return await pb.collection(collectionName).getOne(id);
  }
}
