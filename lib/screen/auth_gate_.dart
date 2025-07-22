import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Startpage.dart';
import 'home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens for real-time authentication state changes.
    return StreamBuilder<User?>(
      // The stream is provided by FirebaseAuth.instance.authStateChanges().
      // It will emit a new value (either a User object or null) whenever
      // a user signs in or signs out.
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While the stream is connecting, you could show a loading indicator,
        // but the connection is usually very fast.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if the snapshot has data. If it does, it means a User object
        // was received, so the user is logged in.
        if (snapshot.hasData) {
          // If logged in, show the main HomePage of the app.
          return const HomePage();
        }
        // If the snapshot has no data, it means the stream emitted null,
        // so the user is logged out.
        else {
          // If logged out, show the initial StartPage.
          return const StartPage();
        }
      },
    );
  }
}
