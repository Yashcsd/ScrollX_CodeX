class GameSocialStats {
  final int likes;
  final int saves;
  final int shares;
  final int plays;

  const GameSocialStats({
    this.likes = 0,
    this.saves = 0,
    this.shares = 0,
    this.plays = 0,
  });

  int get ratingCount => likes + saves + shares;

  double get rating {
    final score = 3.8 + (likes * 0.012) + (saves * 0.018) + (shares * 0.01);
    return score.clamp(3.8, 5.0);
  }

  factory GameSocialStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const GameSocialStats();
    return GameSocialStats(
      likes: map['likes'] ?? 0,
      saves: map['saves'] ?? 0,
      shares: map['shares'] ?? 0,
      plays: map['plays'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'likes': likes,
        'saves': saves,
        'shares': shares,
        'plays': plays,
      };
}

class GameUserSocialState {
  final bool liked;
  final bool saved;

  const GameUserSocialState({
    this.liked = false,
    this.saved = false,
  });

  factory GameUserSocialState.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const GameUserSocialState();
    return GameUserSocialState(
      liked: map['liked'] ?? false,
      saved: map['saved'] ?? false,
    );
  }
}
