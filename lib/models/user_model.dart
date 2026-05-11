// lib/models/user_model.dart
// No Firebase imports — works fully offline
class UserModel {
  final String id;
  String username;
  String avatarInitials;
  int    totalXp;
  int    gamesWon;
  int    gamesPlayed;
  Map<String, int> bestScores;
  List<String>     badges;
  DateTime createdAt;
  DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.avatarInitials,
    this.totalXp     = 0,
    this.gamesWon    = 0,
    this.gamesPlayed = 0,
    Map<String, int>? bestScores,
    List<String>?     badges,
    DateTime?         createdAt,
    DateTime?         updatedAt,
  })  : bestScores = bestScores ?? {},
        badges     = badges     ?? [],
        createdAt  = createdAt  ?? DateTime.now(),
        updatedAt  = updatedAt  ?? DateTime.now();

  // For Firestore (used only when Firebase is enabled)
  factory UserModel.fromMap(Map<String, dynamic> map, String id) =>
      UserModel(
        id:             id,
        username:       map['username']       ?? 'Player',
        avatarInitials: map['avatarInitials'] ?? 'PL',
        totalXp:        map['totalXp']        ?? 0,
        gamesWon:       map['gamesWon']       ?? 0,
        gamesPlayed:    map['gamesPlayed']    ?? 0,
        bestScores:     Map<String, int>.from(map['bestScores'] ?? {}),
        badges:         List<String>.from(map['badges'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'username':       username,
        'avatarInitials': avatarInitials,
        'totalXp':        totalXp,
        'gamesWon':       gamesWon,
        'gamesPlayed':    gamesPlayed,
        'bestScores':     bestScores,
        'badges':         badges,
        'createdAt':      createdAt.toIso8601String(),
        'updatedAt':      DateTime.now().toIso8601String(),
      };

  UserModel copyWith({
    String?           username,
    String?           avatarInitials,
    int?              totalXp,
    int?              gamesWon,
    int?              gamesPlayed,
    Map<String, int>? bestScores,
    List<String>?     badges,
  }) =>
      UserModel(
        id:             id,
        username:       username       ?? this.username,
        avatarInitials: avatarInitials ?? this.avatarInitials,
        totalXp:        totalXp        ?? this.totalXp,
        gamesWon:       gamesWon       ?? this.gamesWon,
        gamesPlayed:    gamesPlayed    ?? this.gamesPlayed,
        bestScores:     bestScores     ?? Map.from(this.bestScores),
        badges:         badges         ?? List.from(this.badges),
        createdAt:      createdAt,
      );
}
