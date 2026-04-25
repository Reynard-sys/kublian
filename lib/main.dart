import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KublianApp());
}

class KublianApp extends StatelessWidget {
  const KublianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kublian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B5EA8),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Outfit',
      ),
      // Auth gate: routes to SignInScreen or HomeScreen based on Firebase auth state.
      // Replace placeholders with actual screen imports as screens are built.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }
          if (snapshot.hasData) {
            // TODO: Replace with HomeScreen() once built
            return const _PlaceholderScreen(label: 'Home');
          }
          // TODO: Replace with SignInScreen() once built
          return const _PlaceholderScreen(label: 'Sign In');
        },
      ),
    );
  }
}

/// Splash shown while Firebase auth state is resolving.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1628),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'kublian',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB8A4E8),
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Color(0xFF6B5EA8)),
          ],
        ),
      ),
    );
  }
}

/// Temporary placeholder — remove once real screens are wired in.
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1628),
      body: Center(
        child: Text(
          'Kublian — $label\n(screen coming soon)',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFB8A4E8), fontSize: 18),
        ),
      ),
    );
  }
}
