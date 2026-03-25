import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // 1. Use the Singleton instance instead of a new constructor
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<User?> signInWithGoogle() async {
    try {
      // 2. Mandatory initialization step in v7.0+
      await _googleSignIn.initialize();

      // 3. 'authenticate()' replaces the old 'signIn()' method
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      

      // 4. Get the ID Token (Identity / Authentication)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 5. Get the Access Token (Permissions / Authorization)
      // We request a basic scope to generate the access token for Firebase
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email']);

      // 6. Create the Firebase credential using both tokens
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

      // 7. Sign in to Firebase (Creates account if it doesn't exist)
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign Out Error: $e');
    }
  }
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}