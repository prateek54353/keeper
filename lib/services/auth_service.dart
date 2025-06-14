import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _usernamesCollection = FirebaseFirestore.instance.collection('usernames');
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    final doc = await _usernamesCollection.doc(username.toLowerCase()).get();
    return !doc.exists;
  }

  // Reserve username
  Future<void> _reserveUsername(String username, String uid) async {
    await _usernamesCollection.doc(username.toLowerCase()).set({
      'uid': uid,
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String emailOrUsername, String password) async {
    try {
      String email;
      
      // Check if input is username
      if (!emailOrUsername.contains('@')) {
        final usernameDoc = await _usernamesCollection.doc(emailOrUsername.toLowerCase()).get();
        if (!usernameDoc.exists) {
          throw Exception('Username not found');
        }
        final userData = await _firestore.collection('users').doc(usernameDoc['uid']).get();
        email = userData['email'];
      } else {
        email = emailOrUsername;
      }

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        throw Exception('Please verify your email before signing in. Check your inbox for a verification link.');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      // Check if username is available
      if (!await isUsernameAvailable(username)) {
        throw Exception('Username is already taken');
      }

      // Create user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reserve username
      await _reserveUsername(username, userCredential.user!.uid);

      // Store user data
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Sign out
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Create a username from the email (remove @domain.com)
        final email = userCredential.user!.email!;
        final username = email.split('@')[0];
        
        // Check if username is available, if not, append a random number
        String finalUsername = username;
        int counter = 1;
        while (!await isUsernameAvailable(finalUsername)) {
          finalUsername = '$username${counter++}';
        }

        // Reserve username
        await _reserveUsername(finalUsername, userCredential.user!.uid);

        // Store user data
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'username': finalUsername,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
} 