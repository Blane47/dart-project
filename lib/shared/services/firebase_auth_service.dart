import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A user-facing auth error with a message safe to show directly in the UI.
///
/// The service catches raw [FirebaseAuthException]s and rethrows these so screens
/// never have to know Firebase error codes — they just `catch (AuthException e)`
/// and display `e.message`.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thin wrapper around [FirebaseAuth] for the four flows the app needs:
/// sign up, sign in, sign out, and password reset — plus the auth-state stream
/// that the router (step 4) listens to.
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// The currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  /// Emits on sign-in / sign-out. The router uses this to gate routes.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User> signUp({required String email, required String password}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AuthException(
          'We could not create your account. Please try again.',
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  Future<User> signIn({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AuthException(
          'We could not sign you in. Please try again.',
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  /// Maps Firebase error codes to friendly, actionable copy.
  static String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address doesn\'t look right.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for that email. Try signing in.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'operation-not-allowed':
        return 'Email sign-in isn\'t enabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No connection. Check your network and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

/// Single shared instance of the auth service.
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
  (ref) => FirebaseAuthService(),
);

/// The reactive auth state used to gate routes and pick the start screen.
final authStateChangesProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthServiceProvider).authStateChanges(),
);

/// The current signed-in user (or null), derived from [authStateChangesProvider].
/// Screens behind the auth gate can read `.uid` from this safely.
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authStateChangesProvider).value,
);
