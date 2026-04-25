import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kublian/core/services/user_service.dart';
import 'firebase_options.dart';
import 'screens/agreement_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/user_form_screen.dart';
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
          if (snapshot.hasData) {
            // Logged in — go to main app shell
            return _AuthenticatedFlow(key: ValueKey(snapshot.data!.uid));
          }
          // Not logged in — show sign-in screen
          return const SignInScreen();
        },
      ),
    );
  }
}

/// Bottom navigation shell — grows as screens are built.
class _AuthenticatedFlow extends StatefulWidget {
  const _AuthenticatedFlow({super.key});

  @override
  State<_AuthenticatedFlow> createState() => _AuthenticatedFlowState();
}

class _AuthenticatedFlowState extends State<_AuthenticatedFlow> {
  final _userService = UserService();
  bool _hasAcceptedAgreement = false;
  bool _isCheckingProfile = true;
  bool _hasUserProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfileStatus();
  }

  Future<void> _loadProfileStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isCheckingProfile = false;
        _hasUserProfile = false;
      });
      return;
    }

    final exists = await _userService.userProfileExists(user.uid);
    if (!mounted) {
      return;
    }
    setState(() {
      _isCheckingProfile = false;
      _hasUserProfile = exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingProfile) {
      return const _SplashScreen();
    }

    if (!_hasAcceptedAgreement) {
      return AgreementScreen(
        onAccepted: () {
          setState(() => _hasAcceptedAgreement = true);
        },
      );
    }

    if (!_hasUserProfile) {
      return UserFormScreen(
        onCompleted: () {
          setState(() => _hasUserProfile = true);
        },
      );
    }

    return const _AppShell();
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _index = 3; // Start on Library tab for demo

  static const _items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book_outlined),
      activeIcon: Icon(Icons.book),
      label: 'Journal',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline),
      activeIcon: Icon(Icons.chat_bubble),
      label: 'Support',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.local_library_outlined),
      activeIcon: Icon(Icons.local_library),
      label: 'Library',
    ),
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
      bottomNavigationBar: _CustomBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CustomBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (icon: Icons.home_outlined, activeIcon: Icons.home_outlined, label: 'Home'),
      (icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_outlined, label: 'Journal'),
      (icon: Icons.forum_outlined, activeIcon: Icons.forum_outlined, label: 'Support'),
      (icon: Icons.local_library_outlined, activeIcon: Icons.local_library_outlined, label: 'Library'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF042F2E),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(48),
          topRight: Radius.circular(48),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;
            final item = items[index];
            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF115E59) : Colors.transparent,
                  borderRadius: BorderRadius.circular(32),
                  border: isSelected ? Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.3), width: 1) : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? const Color(0xFFCCFBF1) : const Color(0xFF0F766E),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFCCFBF1) : const Color(0xFF0F766E),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontFamily: 'Newsreader',
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
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
      backgroundColor: Color(0xFFFCFEEF),
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
