class GameComment {
  final String id;
  final String gameId;
  final String userId;
  final String username;
  final String avatarInitials;
  final String text;
  final DateTime createdAt;
  final String? parentCommentId;

  const GameComment({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.username,
    required this.avatarInitials,
    required this.text,
    required this.createdAt,
    this.parentCommentId,
  });

  factory GameComment.fromMap(
    Map<String, dynamic>? map, {
    required String id,
  }) {
    final rawCreatedAt = map?['createdAt'] ?? map?['created_at'];
    final createdAt = switch (rawCreatedAt) {
      String isoString => DateTime.tryParse(isoString) ?? DateTime.now(),
      DateTime dateTime => dateTime,
      _ => DateTime.now(),
    };

    return GameComment(
      id: id,
      gameId: map?['gameId'] ?? map?['game_id'] ?? '',
      userId: map?['userId'] ?? map?['user_id'] ?? '',
      username: map?['username'] ?? 'Player',
      avatarInitials: map?['avatarInitials'] ?? map?['avatar_initials'] ?? 'PL',
      text: map?['text'] ?? '',
      createdAt: createdAt,
      parentCommentId: map?['parentCommentId'] ?? map?['parent_comment_id'],
    );
  }

  Map<String, dynamic> toMap() => {
        'game_id': gameId,
        'user_id': userId,
        'username': username,
        'avatar_initials': avatarInitials,
        'text': text,
        'created_at': createdAt.toIso8601String(),
        if (parentCommentId != null) 'parent_comment_id': parentCommentId,
      };
}
