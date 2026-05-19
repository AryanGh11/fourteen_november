import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/services/shared_performance/shared_performance_service.dart';

class UserProviderService {
  final String _userIdKey = "userId";

  Future<void> update(String id) async {
    await SharedPerformanceService.put(_userIdKey, id);
  }

  User? get current {
    final id = SharedPerformanceService.get(_userIdKey);
    if (id == null) return null;
    final user = UserRepository().getOne(id);
    return user;
  }
}
