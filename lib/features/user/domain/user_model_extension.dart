import 'package:pocketbase/pocketbase.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

extension UserModelExtension on User {
  Future<RecordModel> toRecordModel() async {
    final String collectionName = "users";
    final pb = PocketBaseService.I.instance;

    return await pb.collection(collectionName).getOne(id);
  }
}
