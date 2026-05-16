// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/game_social_model.dart';
import '../models/score_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  FirestoreService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _scores =>
      _db.collection('scores');

  CollectionReference<Map<String, dynamic>> get _gameStats =>
      _db.collection('game_stats');

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String id) async {
    final doc = await _users.doc(id).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return UserModel.fromMap(data, doc.id);
  }

  Stream<List<UserModel>> leaderboardStream({int limit = 50}) {
    return _users
        .orderBy('totalXp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _users.doc(id).set({
      ...data,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<String> saveScore(ScoreModel score) async {
    final doc = await _scores.add(score.toMap());
    return doc.id;
  }

  Stream<GameSocialStats> gameStatsStream(String gameId) {
    return _gameStats.doc(gameId).snapshots().map(
          (doc) => GameSocialStats.fromMap(doc.data()),
        );
  }

  Stream<GameUserSocialState> gameUserSocialStream({
    required String gameId,
    required String userId,
  }) {
    return _gameStats
        .doc(gameId)
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => GameUserSocialState.fromMap(doc.data()));
  }

  Future<void> seedGameStats({
    required String gameId,
    required int plays,
    required double rating,
  }) async {
    final doc = _gameStats.doc(gameId);
    final likes = (plays * (rating / 10)).round();
    final saves = (likes * 0.18).round();
    final shares = (likes * 0.08).round();

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      if (snapshot.exists) return;

      final now = DateTime.now().toIso8601String();
      transaction.set(doc, {
        'likes': likes,
        'saves': saves,
        'shares': shares,
        'plays': plays,
        'createdAt': now,
        'updatedAt': now,
      });
    });
  }

  Future<void> incrementGamePlays(String gameId) {
    return _gameStats.doc(gameId).set({
      'plays': FieldValue.increment(1),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> toggleGameLike({
    required String gameId,
    required String userId,
    required bool currentlyLiked,
  }) async {
    final batch = _db.batch();
    final gameRef = _gameStats.doc(gameId);
    final userRef = gameRef.collection('users').doc(userId);

    batch.set(gameRef, {
      'likes': FieldValue.increment(currentlyLiked ? -1 : 1),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
    batch.set(userRef, {
      'liked': !currentlyLiked,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> toggleGameSave({
    required String gameId,
    required String userId,
    required bool currentlySaved,
  }) async {
    final batch = _db.batch();
    final gameRef = _gameStats.doc(gameId);
    final userRef = gameRef.collection('users').doc(userId);

    batch.set(gameRef, {
      'saves': FieldValue.increment(currentlySaved ? -1 : 1),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
    batch.set(userRef, {
      'saved': !currentlySaved,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> incrementGameShares(String gameId) {
    return _gameStats.doc(gameId).set({
      'shares': FieldValue.increment(1),
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteScore(String id) async {
    await _scores.doc(id).delete();
  }

  Future<void> deleteUser(String userId) async {
    final scores = await _scores.where('userId', isEqualTo: userId).get();
    final batch = _db.batch();

    for (final doc in scores.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_users.doc(userId));

    await batch.commit();
  }
}
