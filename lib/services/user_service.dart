import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final int balance;
  final int rating;
  final String? avatarColor;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.balance,
    required this.rating,
    this.avatarColor,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'displayName': displayName,
        'balance': balance,
        'rating': rating,
        'avatarColor': avatarColor,
      };

  static UserProfile fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      balance: (data['balance'] ?? 0) as int,
      rating: (data['rating'] ?? 1200) as int,
      avatarColor: data['avatarColor'] as String?,
    );
  }
}

class UserService {
  UserService._internal();
  static final UserService instance = UserService._internal();

  final _db = FirebaseFirestore.instance.collection('users');

  Future<void> ensureUserDoc({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    final doc = await _db.doc(uid).get();
    if (!doc.exists) {
      await _db.doc(uid).set({
        'email': email,
        'displayName': displayName,
        'balance': 1000,
        'rating': 1200,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<UserProfile?> watchProfile(String uid) {
    return _db.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromDoc(doc);
    });
  }

  Future<void> updateDisplayName(String uid, String name) {
    return _db.doc(uid).update({'displayName': name});
  }

  Future<void> adjustBalance(String uid, int delta) {
    return _db.doc(uid).update({'balance': FieldValue.increment(delta)});
  }
}

