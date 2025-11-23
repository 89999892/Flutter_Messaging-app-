import '../../common/models/user_model.dart';
import '../providers/firebase_auth_provider.dart';

/// Authentication Repository
/// Abstracts authentication operations
abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(
      String email, String password, String displayName);
  Future<void> signOut();
  Future<void> resetPassword(String email);
}

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthProvider _authProvider;

  AuthRepositoryImpl(this._authProvider);

  @override
  Stream<UserModel?> get authStateChanges {
    return _authProvider.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        // Get full user data from Firestore
        final userDoc = await _authProvider.getUserData(firebaseUser.uid);
        return userDoc;
      } catch (e) {
        return null;
      }
    });
  }

  @override
  UserModel? get currentUser {
    final firebaseUser = _authProvider.currentUser;
    if (firebaseUser == null) return null;

    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoURL: firebaseUser.photoURL,
    );
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    return await _authProvider.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    return await _authProvider.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<void> signOut() async {
    await _authProvider.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _authProvider.resetPassword(email);
  }
}
