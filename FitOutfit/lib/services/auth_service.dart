import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email & Password Sign In
  static Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult(success: true, user: credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  // Email & Password Sign Up
  static Future<AuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(fullName);

      return AuthResult(success: true, user: credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  // Google Sign In
  static Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(success: false, error: 'Sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return AuthResult(success: true, user: userCredential.user);
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Google sign in failed. Please try again.',
      );
    }
  }

  // Password Reset
  static Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(
        success: true,
        message: 'Password reset email sent successfully',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to send reset email. Please try again.',
      );
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  // Get user-friendly error messages
  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? message;

  AuthResult({required this.success, this.user, this.error, this.message});
}
