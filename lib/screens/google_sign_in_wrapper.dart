import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keeper/screens/navigation_screen.dart';
import 'package:keeper/screens/google_sign_in_screen.dart';

class GoogleSignInWrapper extends StatelessWidget {
  const GoogleSignInWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Not signed in
        if (!snapshot.hasData) {
          return const GoogleSignInScreen();
        }

        // Signed in
        return const NavigationScreen();
      },
    );
  }
} 