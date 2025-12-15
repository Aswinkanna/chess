import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.updateDisplayName(displayName);
    await _userService.ensureUserDoc(
      uid: cred.user!.uid,
      email: email,
      displayName: displayName,
    );
    return cred;
  }

  Future<void> signOut() => _auth.signOut();
}

