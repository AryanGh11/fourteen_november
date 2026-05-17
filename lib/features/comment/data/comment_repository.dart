import 'package:fourteen_november/features/comment/comment.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

class CommentRepository {
  final String _collectionName = "comments";

  final _pb = PocketBaseService.I.instance;

  Future<List<Comment>> getAll() async {
    final res = await _pb.collection(_collectionName).getFullList();
    final comments = res.map((item) => Comment.fromRecordModel(item)).toList();
    return comments;
  }

  Future<List<Comment>> getMany(List<String> ids) async {
    final res = await _pb
        .collection(_collectionName)
        .getFullList(query: {"id": ids});
    final comments = res.map((item) => Comment.fromRecordModel(item)).toList();
    return comments;
  }

  Future<Comment?> getOne(String id) async {
    final res = await _pb.collection(_collectionName).getOne(id);
    final comment = Comment.fromRecordModel(res);
    return comment;
  }
}
