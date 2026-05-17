import 'package:pocketbase/pocketbase.dart';
import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

extension MoodModelExtension on Mood {
  Future<RecordModel> toRecordModel() async {
    final String collectionName = "moods";
    final pb = PocketBaseService.I.instance;

    return await pb.collection(collectionName).getOne(id);
  }
}
