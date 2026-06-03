// lib/models/user_model.dart
// Pure Dart user model for local cache and Supabase profile rows.
class UserModel {
  final String id;
  String username;
  String avatarInitials;
  String bio;
  String? avatarUrl;
  int    totalXp;
  int    gamesWon;
  int    gamesPlayed;
  int    followersCount;
  int    followingCount;
  int    likesReceived;
  int    streakDays;
  Map<String, int> bestScores;
  List<String>     badges;
  DateTime createdAt;
  DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.avatarInitials,
    this.bio          = '',
    this.avatarUrl,
    this.totalXp     = 0,
    this.gamesWon    = 0,
    this.gamesPlayed = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.likesReceived  = 0,
    this.streakDays     = 0,
    Map<String, int>? bestScores,
    List<String>?     badges,
    DateTime?         createdAt,
    DateTime?         updatedAt,
  })  : bestScores = bestScores ?? {},
        badges     = badges     ?? [],
        createdAt  = createdAt  ?? DateTime.now(),
        updatedAt  = updatedAt  ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map, String id) =>
      UserModel(
        id:             id,
        username:       map['username']       ?? 'Player',
        avatarInitials: map['avatarInitials'] ?? map['avatar_initials'] ?? 'PL',
        bio:            map['bio']            ?? '',
        avatarUrl:      map['avatarUrl']      ?? map['avatar_url'],
        totalXp:        map['totalXp']        ?? map['total_xp']        ?? 0,
        gamesWon:       map['gamesWon']       ?? map['games_won']       ?? 0,
        gamesPlayed:    map['gamesPlayed']    ?? map['games_played']    ?? 0,
        followersCount: map['followersCount'] ?? map['followers_count'] ?? 0,
        followingCount: map['followingCount'] ?? map['following_count'] ?? 0,
        likesReceived:  map['likesReceived']  ?? map['likes_received']  ?? 0,
        streakDays:     map['streakDays']     ?? map['streak_days']     ?? 0,
        bestScores:     Map<String, int>.from(map['bestScores'] ?? map['best_scores'] ?? {}),
        badges:         List<String>.from(map['badges'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'id':             id,
        'username':       username,
        'avatar_initials': avatarInitials,
        'bio':            bio,
        'avatar_url':     avatarUrl,
        'total_xp':       totalXp,
        'games_won':      gamesWon,
        'games_played':   gamesPlayed,
        'followers_count': followersCount,
        'following_count': followingCount,
        'likes_received': likesReceived,
        'streak_days':    streakDays,
        'best_scores':    bestScores,
        'badges':         badges,
        'created_at':     createdAt.toIso8601String(),
        'updated_at':     DateTime.now().toIso8601String(),
      };

  UserModel copyWith({
    String?           id,
    String?           username,
    String?           avatarInitials,
    String?           bio,
    String?           avatarUrl,
    int?              totalXp,
    int?              gamesWon,
    int?              gamesPlayed,
    int?              followersCount,
    int?              followingCount,
    int?              likesReceived,
    int?              streakDays,
    Map<String, int>? bestScores,
    List<String>?     badges,
  }) =>
      UserModel(
        id:             id             ?? this.id,
        username:       username       ?? this.username,
        avatarInitials: avatarInitials ?? this.avatarInitials,
        bio:            bio            ?? this.bio,
        avatarUrl:      avatarUrl      ?? this.avatarUrl,
        totalXp:        totalXp        ?? this.totalXp,
        gamesWon:       gamesWon       ?? this.gamesWon,
        gamesPlayed:    gamesPlayed    ?? this.gamesPlayed,
        followersCount: followersCount ?? this.followersCount,
        followingCount: followingCount ?? this.followingCount,
        likesReceived:  likesReceived  ?? this.likesReceived,
        streakDays:     streakDays     ?? this.streakDays,
        bestScores:     bestScores     ?? Map.from(this.bestScores),
        badges:         badges         ?? List.from(this.badges),
        createdAt:      createdAt,
      );
}
