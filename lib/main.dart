import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iotcw06/screen/auth_gate_.dart';
import 'firebase_options.dart';

// The main function is the entry point for your Flutter application.
Future<void> main() async {
  // Ensure that the Flutter widget binding is initialized before running any other code.
  WidgetsFlutterBinding.ensureInitialized();

  // Load the environment variables from the .env file (for the Gemini API key).
  await dotenv.load(fileName: ".env");

  // Initialize Firebase with the platform-specific options.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the main application widget.
  runApp(const MyApp());
}

// MyApp is the root widget of your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Hides the debug banner in the top-right corner.
      debugShowCheckedModeBanner: false,
      // The AuthGate widget will decide which screen to show based on
      // whether the user is logged in or not.
      home: AuthGate(),
    );
  }
}
