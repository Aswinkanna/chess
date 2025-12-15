import 'package:cloud_firestore/cloud_firestore.dart';

typedef MoveCallback = void Function(Map<String, dynamic> move);

class MultiplayerService {
  final _db = FirebaseFirestore.instance;

  Future<void> createRoom({
    required String roomId,
    required String hostUid,
    required int bet,
    required String hostColor,
  }) async {
    await _db.collection('rooms').doc(roomId).set({
      'created_at': FieldValue.serverTimestamp(),
      'moves': [],
      'state': 'waiting',
      'bet': bet,
      'hostUid': hostUid,
      'hostColor': hostColor,
    });
  }

  Future<void> joinRoom({
    required String roomId,
    required String guestUid,
    required String preferColor,
  }) async {
    await _db.collection('rooms').doc(roomId).update({
      'state': 'playing',
      'guestUid': guestUid,
      'guestColor': preferColor,
    });
  }

  Future<void> pushMove(String roomId, Map<String, dynamic> move) async {
    final roomRef = _db.collection('rooms').doc(roomId);
    await roomRef.update({
      'moves': FieldValue.arrayUnion([move])
    });
  }

  Stream<Map<String, dynamic>?> watchRoom(String roomId) {
    return _db.collection('rooms').doc(roomId).snapshots().map((doc) => doc.data());
  }

  // listen for moves per room
  Stream<Map<String, dynamic>?> listenForLastMove(String roomId) {
    return _db.collection('rooms').doc(roomId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      final moves = List.from(data['moves'] ?? []);
      if (moves.isEmpty) return null;
      return Map<String, dynamic>.from(moves.last);
    });
  }
}
