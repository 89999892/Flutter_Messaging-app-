import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../common/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Authentication Provider
/// Handles direct interaction with Firebase Authentication SDK
class FirebaseAuthProvider {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthProvider({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get current user
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  /// Auth state changes stream
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed');
      }

      // Update user online status
      await _updateUserStatus(credential.user!.uid, isOnline: true);

      // Get user data from Firestore
      return await getUserData(credential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed');
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      // Create user document in Firestore
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        isOnline: true,
        lastSeen: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toJson());

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      if (currentUser != null) {
        await _updateUserStatus(currentUser!.uid, isOnline: false);
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Get user data from Firestore
  Future<UserModel> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (!doc.exists) {
      throw Exception('User data not found');
    }

    return UserModel.fromJson(doc.data()!);
  }

  /// Update user online status
  Future<void> _updateUserStatus(String userId,
      {required bool isOnline}) async {
    await _firestore.collection('users').doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
