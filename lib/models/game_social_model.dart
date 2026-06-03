class GameSocialStats {
  final int likes;
  final int comments;
  final int saves;
  final int shares;
  final int plays;
  final DateTime? updatedAt;

  const GameSocialStats({
    this.likes = 0,
    this.comments = 0,
    this.saves = 0,
    this.shares = 0,
    this.plays = 0,
    this.updatedAt,
  });

  int get ratingCount => likes + saves + shares;

  double get rating {
    final score = 3.8 + (likes * 0.012) + (saves * 0.018) + (shares * 0.01);
    return score.clamp(3.8, 5.0);
  }

  factory GameSocialStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const GameSocialStats();
    return GameSocialStats(
      likes: map['likesCount'] ?? map['likes_count'] ?? map['likes'] ?? 0,
      comments: map['commentsCount'] ?? map['comments_count'] ?? map['comments'] ?? 0,
      saves: map['saves'] ?? 0,
      shares: map['sharesCount'] ?? map['shares_count'] ?? map['shares'] ?? 0,
      plays: map['playsCount'] ?? map['plays_count'] ?? map['plays'] ?? 0,
      updatedAt: switch (map['updatedAt'] ?? map['updated_at']) {
        String isoString => DateTime.tryParse(isoString),
        DateTime dateTime => dateTime,
        _ => null,
      },
    );
  }

  Map<String, dynamic> toMap() => {
        'likes_count': likes,
        'comments_count': comments,
        'saves': saves,
        'shares_count': shares,
        'plays_count': plays,
        'updated_at': updatedAt?.toIso8601String(),
      };
}

class GameUserSocialState {
  final bool liked;
  final bool saved;
  final int shareCount;
  final DateTime? lastSharedAt;

  const GameUserSocialState({
    this.liked = false,
    this.saved = false,
    this.shareCount = 0,
    this.lastSharedAt,
  });

  factory GameUserSocialState.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const GameUserSocialState();
    return GameUserSocialState(
      liked: map['liked'] ?? false,
      saved: map['saved'] ?? false,
      shareCount: map['shareCount'] ?? map['share_count'] ?? 0,
      lastSharedAt: switch (map['lastSharedAt'] ?? map['last_shared_at']) {
        String isoString => DateTime.tryParse(isoString),
        DateTime dateTime => dateTime,
        _ => null,
      },
    );
  }
}
