import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keeper/screens/navigation_screen.dart';
import 'package:keeper/screens/auth_screen.dart';

class GoogleSignInWrapper extends StatefulWidget {
  const GoogleSignInWrapper({super.key});

  @override
  State<GoogleSignInWrapper> createState() => _GoogleSignInWrapperState();
}

class _GoogleSignInWrapperState extends State<GoogleSignInWrapper> {
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
          return const AuthScreen();
        }

        // Signed in
        return const NavigationScreen();
      },
    );
  }
} 