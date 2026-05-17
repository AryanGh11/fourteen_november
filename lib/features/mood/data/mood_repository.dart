import 'package:fourteen_november/features/mood/mood.dart';
import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

class MoodRepository {
  final String _collectionName = "moods";

  final _pb = PocketBaseService.I.instance;

  Future<List<Mood>> getAll() async {
    final res = await _pb.collection(_collectionName).getFullList();
    final moods = res.map((item) => Mood.fromRecordModel(item)).toList();
    return moods;
  }

  Future<Mood?> getOne(String id) async {
    final res = await _pb.collection(_collectionName).getOne(id);
    final mood = Mood.fromRecordModel(res);
    return mood;
  }

  Future<Mood> create(MoodCreatePayload payload) async {
    final userId = UserProviderService().current?.id;

    if (userId == null) {
      throw ArgumentError("User not found");
    }

    final body = {
      "userId": userId,
      "note": payload.note.isEmpty ? null : payload.note,
      "value": payload.value,
    };

    final res = await _pb.collection(_collectionName).create(body: body);

    final mood = Mood.fromRecordModel(res);
    return mood;
  }
}
