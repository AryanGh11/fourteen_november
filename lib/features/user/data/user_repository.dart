import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

class UserRepository {
  final String _collectionName = "users";

  final _pb = PocketBaseService.I.instance;

  Future<List<User>> getAll() async {
    final res = await _pb.collection(_collectionName).getFullList();
    final users = res.map((item) => User.fromRecordModel(item)).toList();
    return users;
  }

  Future<User?> getOne(String id) async {
    final res = await _pb.collection(_collectionName).getOne(id);
    final user = User.fromRecordModel(res);
    return user;
  }
}
