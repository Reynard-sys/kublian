import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:kublian/screens/resources_screen.dart';
import 'package:kublian/widgets/resources/resources_header.dart'
    show kResPrimary, kResBg;

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
          seedColor: kResPrimary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: kResBg,
        fontFamily: 'Outfit',
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }
          // TODO: Gate on user profile exists → SignInScreen → AliasSetupScreen
          return const _AppShell();
        },
      ),
    );
  }
}

/// Bottom navigation shell — grows as screens are built.
class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _index = 3; // Start on Library tab for demo

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Journal'),
    BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Support'),
    BottomNavigationBarItem(icon: Icon(Icons.local_library_outlined), activeIcon: Icon(Icons.local_library), label: 'Library'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kResBg,
      body: IndexedStack(
        index: _index,
        children: const [
          _PlaceholderScreen(label: 'Home'),
          _PlaceholderScreen(label: 'Journal'),
          _PlaceholderScreen(label: 'Support'),
          ResourcesScreen(), // Library tab → Resources screen
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: kResPrimary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: _items,
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
