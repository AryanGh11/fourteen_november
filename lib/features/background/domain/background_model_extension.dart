import 'package:pocketbase/pocketbase.dart';
import 'package:fourteen_november/features/background/background.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

extension BackgroundModelExtension on Background {
  Future<RecordModel> toRecordModel() async {
    final String collectionName = "backgrounds";
    final pb = PocketBaseService.I.instance;

    return await pb.collection(collectionName).getOne(id);
  }
}
