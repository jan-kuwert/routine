import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Create a new user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred';
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String displayName) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
      } else {
        throw 'No user currently signed in';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e.toString();
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw 'No user currently signed in';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
      } else {
        throw 'No user currently signed in';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Verify the current user's password
  Future<bool> verifyPassword(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw 'No user currently signed in';
      }

      // Get user email
      final email = user.email;
      if (email == null) {
        throw 'User has no email address';
      }

      // Try to reauthenticate with the given password
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return true; // If we get here, reauthentication was successful
    } on FirebaseAuthException {
      return false;
    } catch (e) {
      throw e.toString();
    }
  }

  //Verify the current user's email
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      } else {
        throw 'No user currently signed in';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
