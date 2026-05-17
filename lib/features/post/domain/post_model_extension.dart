import 'package:pocketbase/pocketbase.dart';
import 'package:fourteen_november/features/post/post.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

extension PostModelExtension on Post {
  Future<RecordModel> toRecordModel() async {
    final String collectionName = "posts";
    final pb = PocketBaseService.I.instance;

    return await pb.collection(collectionName).getOne(id);
  }
}
