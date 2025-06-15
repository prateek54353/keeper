import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keeper/screens/login_screen.dart';
import 'package:keeper/screens/navigation_screen.dart';
import 'package:keeper/screens/email_verification_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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
          return const LoginScreen();
        }

        // Check email verification
        final user = snapshot.data!;
        if (!user.emailVerified) {
          return const EmailVerificationScreen();
        }

        // Signed in and verified
        return const NavigationScreen();
      },
    );
  }
} 