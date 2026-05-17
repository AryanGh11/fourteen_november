import 'package:fourteen_november/features/background/background.dart';
import 'package:fourteen_november/services/pocket_base/pocket_base_service.dart';

class BackgroundRepository {
  final String _collectionName = "backgrounds";

  final _pb = PocketBaseService.I.instance;

  Future<List<Background>> getAll() async {
    final res = await _pb.collection(_collectionName).getFullList();
    final backgrounds = res
        .map((item) => Background.fromRecordModel(item))
        .toList();
    return backgrounds;
  }

  Future<Background?> getOne(String id) async {
    final res = await _pb.collection(_collectionName).getOne(id);
    final background = Background.fromRecordModel(res);
    return background;
  }
}
