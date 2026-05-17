import 'package:fourteen_november/features/user/user.dart';
import 'package:fourteen_november/services/shared_performance/shared_performance_service.dart';

class UserProviderService {
  final String _userKey = "user";

  Future<void> update(User user) async {
    await SharedPerformanceService.put<User>(_userKey, user);
  }

  User? get current {
    return SharedPerformanceService.get<User?>(_userKey);
  }
}
