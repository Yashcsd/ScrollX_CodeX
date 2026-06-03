import '../models/game_comment_model.dart';
import '../models/game_social_metadata.dart';
import '../models/user_model.dart';
import 'game_social_service.dart';

class CommentsService {
  CommentsService._();

  static Stream<List<GameComment>> streamForGame(String gameId) {
    return GameSocialService.commentsStream(gameId);
  }

  static Future<void> addComment({
    required String gameId,
    required UserModel user,
    required String text,
    required GameSocialMetadata metadata,
    String? parentCommentId,
  }) {
    return GameSocialService.addComment(
      gameId: gameId,
      user: user,
      text: text,
      metadata: metadata,
      parentCommentId: parentCommentId,
    );
  }
}
