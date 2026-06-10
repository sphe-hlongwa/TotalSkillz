import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isAdminCache = false;

  AuthService() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          final doc = await _db.collection('users').doc(user.uid).get();
          _isAdminCache = doc.data()?['role'] == 'admin';
        } catch (e) {
          _isAdminCache = false;
        }
      } else {
        _isAdminCache = false;
      }
      notifyListeners();
    });
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isLoggedIn => currentUser != null;
  bool get isAdmin => _isAdminCache;

  /// Email + password login
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Email + password sign up
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
    await _createUserProfile(cred.user!, displayName: displayName);
    return cred;
  }

  /// Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = (await GoogleSignIn.instance.authenticate()) as GoogleSignInAccount?;
      if (googleUser == null) return null;

      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: null, // accessToken is separated in v7.0.0+, idToken is sufficient for Firebase
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      // Create profile if first sign in
      final userDoc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!userDoc.exists) {
        await _createUserProfile(cred.user!,
            displayName: googleUser.displayName ?? '');
      }
      return cred;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Delete the user account and associated data
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // 1. Delete Firestore data
      await _db.collection('users').doc(user.uid).delete();
      // 2. Delete Auth account
      await user.delete();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try { await GoogleSignIn.instance.signOut(); } catch (_) {}
    await _auth.signOut();
    notifyListeners();
  }

  /// Create initial Firestore user document
  Future<void> _createUserProfile(User user, {required String displayName}) async {
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'displayName': displayName,
      'email': user.email ?? '',
      'photoURL': user.photoURL ?? '',
      'role': 'student',
      'xp': 0,
      'streak': 0,
      'topics': {},
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
