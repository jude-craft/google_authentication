import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // Initialize Firebase and Google
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<User?> signInWithGoogle() async {
    try {
      // Initializing google sign in
      await _googleSignIn.initialize();

      // auntheticate user
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // get user tokenID
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Get access  token  (permissions/Authorization)
      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
      ]);

      // Create firebase credentials using both tokens
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

      // Sign in to firebase(create account if doesn't exists)
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } on FirebaseException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Google sign in error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
