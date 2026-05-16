import '../models/game_social_model.dart';
import 'firestore_service.dart';

class GameSocialService {
  GameSocialService._();

  static final FirestoreService _firestore = FirestoreService();

  static Stream<GameSocialStats> statsStream(String gameId) =>
      _firestore.gameStatsStream(gameId);

  static Stream<GameUserSocialState> userStateStream({
    required String gameId,
    required String? userId,
  }) {
    if (userId == null) {
      return Stream.value(const GameUserSocialState());
    }
    return _firestore.gameUserSocialStream(gameId: gameId, userId: userId);
  }

  static Future<void> seedStats({
    required String gameId,
    required int plays,
    required double rating,
  }) =>
      _firestore.seedGameStats(gameId: gameId, plays: plays, rating: rating);

  static Future<void> recordPlay(String gameId) =>
      _firestore.incrementGamePlays(gameId);

  static Future<void> toggleLike({
    required String gameId,
    required String? userId,
    required bool currentlyLiked,
  }) async {
    if (userId == null) return;
    await _firestore.toggleGameLike(
      gameId: gameId,
      userId: userId,
      currentlyLiked: currentlyLiked,
    );
  }

  static Future<void> toggleSave({
    required String gameId,
    required String? userId,
    required bool currentlySaved,
  }) async {
    if (userId == null) return;
    await _firestore.toggleGameSave(
      gameId: gameId,
      userId: userId,
      currentlySaved: currentlySaved,
    );
  }

  static Future<void> share(String gameId) =>
      _firestore.incrementGameShares(gameId);
}
