// lib/models/score_model.dart
// No Firebase imports — pure Dart model
class ScoreModel {
  final String   id;
  final String   userId;
  final String   username;
  final String   gameId;
  final String   gameName;
  final int      score;
  final int      timeTakenSeconds;
  final DateTime playedAt;

  ScoreModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.gameId,
    required this.gameName,
    required this.score,
    required this.timeTakenSeconds,
    DateTime? playedAt,
  }) : playedAt = playedAt ?? DateTime.now();

  factory ScoreModel.fromMap(Map<String, dynamic> map, String id) =>
      ScoreModel(
        id:               id,
        userId:           map['userId']           ?? '',
        username:         map['username']         ?? '',
        gameId:           map['gameId']           ?? '',
        gameName:         map['gameName']         ?? '',
        score:            map['score']            ?? 0,
        timeTakenSeconds: map['timeTakenSeconds'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'userId':           userId,
        'username':         username,
        'gameId':           gameId,
        'gameName':         gameName,
        'score':            score,
        'timeTakenSeconds': timeTakenSeconds,
        'playedAt':         playedAt.toIso8601String(),
      };
}
