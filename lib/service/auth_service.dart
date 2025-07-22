import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- GOOGLE SIGN IN METHOD ---
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user already exists in Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          // If new user, add their info to Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? 'Google User',
            'email': user.email,
            'age': '',
            'weight': '',
            'height': '',
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'photoUrl': user.photoURL,
          });
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Google sign in failed');
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // --- EMAIL & PASSWORD SIGN IN ---
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign in failed');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- EMAIL & PASSWORD SIGN UP ---
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String age,
    required String weight,
    required String height,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'age': age,
          'weight': weight,
          'height': height,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign up failed');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- PASSWORD RESET ---
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password reset failed');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- SIGN OUT ---
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Sign out from Google if signed in
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // --- GET CURRENT USER ---
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // --- DELETE ACCOUNT ---
  Future<void> deleteAccount() async {
    try {
      await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser?.uid)
          .delete();
      await _firebaseAuth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Account deletion failed');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
