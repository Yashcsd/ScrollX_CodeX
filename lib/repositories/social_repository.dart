import '../models/game_comment_model.dart';
import '../models/game_social_metadata.dart';
import '../models/game_social_model.dart';
import '../models/user_model.dart';
import '../services/game_social_service.dart';

class SocialRepository {
  const SocialRepository();

  Stream<GameSocialStats> stats(String gameId) => GameSocialService.statsStream(gameId);

  Stream<GameUserSocialState> userState({
    required String gameId,
    required String? userId,
  }) =>
      GameSocialService.userStateStream(gameId: gameId, userId: userId);

  Stream<List<GameComment>> comments(String gameId) =>
      GameSocialService.commentsStream(gameId);

  Future<void> like({
    required String gameId,
    required String? userId,
    required GameSocialMetadata metadata,
  }) =>
      GameSocialService.toggleLike(
        gameId: gameId,
        userId: userId,
        metadata: metadata,
      );

  Future<void> comment({
    required String gameId,
    required UserModel? user,
    required String text,
    required GameSocialMetadata metadata,
  }) =>
      GameSocialService.addComment(
        gameId: gameId,
        user: user,
        text: text,
        metadata: metadata,
      );
}
