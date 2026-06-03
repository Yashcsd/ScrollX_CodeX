import '../models/user_model.dart';
import 'profile_service.dart';

class LeaderboardService {
  LeaderboardService._();

  static Stream<List<UserModel>> globalXp({String period = 'all_time'}) {
    return ProfileService.leaderboardStream(period: period);
  }
}
