import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  const ProfileRepository();

  Future<UserModel?> getProfile(String userId) => ProfileService.getProfile(userId);
  Future<UserModel> saveProfile(UserModel user) => ProfileService.upsertProfile(user);
  Stream<List<UserModel>> leaderboard({String period = 'all_time'}) =>
      ProfileService.leaderboardStream(period: period);
}
