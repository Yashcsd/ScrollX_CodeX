// lib/services/firestore_service.dart
//
// This file is a PLACEHOLDER until you set up Firebase.
// It compiles cleanly without the firebase packages.
// When you are ready to add Firebase:
//   1. Uncomment firebase packages in pubspec.yaml
//   2. Run: flutter pub get
//   3. Run: flutterfire configure
//   4. Replace this file with the Firebase version below
//
// ═══════════════════════════════════════════════════════════════
// FIREBASE VERSION (replace this whole file when ready):
// ═══════════════════════════════════════════════════════════════
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/user_model.dart';
// import '../models/score_model.dart';
//
// class FirestoreService {
//   final _db = FirebaseFirestore.instance;
//   CollectionReference<Map<String,dynamic>> get _users  => _db.collection('users');
//   CollectionReference<Map<String,dynamic>> get _scores => _db.collection('scores');
//
//   // CREATE
//   Future<void> createUser(UserModel user) => _users.doc(user.id).set(user.toMap());
//   Future<String> saveScore(ScoreModel s) async {
//     final d = await _scores.add(s.toMap()); return d.id;
//   }
//
//   // READ
//   Future<UserModel?> getUser(String id) async {
//     final d = await _users.doc(id).get();
//     if (!d.exists) return null;
//     return UserModel.fromMap(d.data()!, d.id);
//   }
//   Stream<List<UserModel>> leaderboardStream() => _users
//       .orderBy('totalXp', descending: true).limit(50).snapshots()
//       .map((s) => s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
//
//   // UPDATE
//   Future<void> updateUser(String id, Map<String,dynamic> data) =>
//       _users.doc(id).update({...data, 'updatedAt': FieldValue.serverTimestamp()});
//
//   // DELETE
//   Future<void> deleteScore(String id) => _scores.doc(id).delete();
//   Future<void> deleteUser(String userId) async {
//     final scores = await _scores.where('userId', isEqualTo: userId).get();
//     final batch = _db.batch();
//     for (final d in scores.docs) batch.delete(d.reference);
//     batch.delete(_users.doc(userId));
//     await batch.commit();
//   }
// }

// Stub class — keeps imports in other files from breaking
class FirestoreService {
  FirestoreService();
  // All methods are stubs — they do nothing until Firebase is connected
  Future<void> createUser(dynamic user) async {}
  Future<String> saveScore(dynamic score) async => '';
  Future<dynamic> getUser(String id) async => null;
  Stream<List<dynamic>> leaderboardStream() => const Stream.empty();
  Future<void> updateUser(String id, Map<String, dynamic> data) async {}
  Future<void> deleteScore(String id) async {}
  Future<void> deleteUser(String id) async {}
}
