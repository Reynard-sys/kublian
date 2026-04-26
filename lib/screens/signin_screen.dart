import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/services/auth_service.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFFFCFFED),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── TEAL FRAME ─────────────────────────────────────────────────
            // Top is flush, only bottom corners are smoothly rounded.
            // The frame wraps its content so badges below are truly outside.
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF016A66),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── 48px from status bar ──────────────────────────────
                      const SizedBox(height: 48),

                      // ── Logo image ────────────────────────────────────────
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.18),
                        ),
                        child: const Icon(
                          Icons.spa_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── "Kublian" — Newsreader 600 Italic ─────────────────
                      Text(
                        'Kublian',
                        style: GoogleFonts.newsreader(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ── Tagline — Newsreader 500 ──────────────────────────
                      Text(
                        'Lihim. Ligtas. Lunas.',
                        style: GoogleFonts.newsreader(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),

                      // ── 48px before cream card ────────────────────────────
                      const SizedBox(height: 48),

                      // ── Cream card: all auth content ──────────────────────
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFFBFFE6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Anonymity First
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(9999),
                                    color: const Color(
                                      0xFF016A66,
                                    ).withOpacity(0.12),
                                  ),
                                  child: const Icon(
                                    Icons.visibility_off_outlined,
                                    size: 18,
                                    color: Color(0xFF016A66),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Anonymity First',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A2B1C),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Your identity remains yours. Share your journey in a space designed for complete privacy.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF4A5A4C),
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Sign in with Google
                            GestureDetector(
                              onTap: () async {
                                final user = await authService.signInWithGoogle();
                                if (user == null && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Google sign-in failed. Check the Android Firebase package name and SHA-1 config.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9999),
                                  color: const Color(0xFFD05036),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Sign in with Google',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // OR divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(
                                      0xFFBFC9C8,
                                    ).withOpacity(0.5),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF7A8A7C),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(
                                      0xFFBFC9C8,
                                    ).withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Continue as Guest — pill with cream bg + gray outline
                            GestureDetector(
                              onTap: () async {
                                final user =
                                    await authService.signInAnonymously();
                                if (user == null && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Guest sign-in failed. Check Firebase Auth configuration.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9999),
                                  color: const Color(0xFFFBFFE6),
                                  border: Border.all(
                                    color: const Color(0xFFBFC9C8),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Continue as Guest',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF4A5A4C),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── 32px gap between card and badges ──────────────────
                      const SizedBox(height: 32),

                      // ── Badges — inside the teal frame ────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _BadgeIcon(icon: Icons.lock_outline_rounded),
                          const SizedBox(width: 16),
                          _BadgeIcon(icon: Icons.favorite_border_rounded),
                          const SizedBox(width: 16),
                          _BadgeIcon(icon: Icons.shield_outlined),
                        ],
                      ),

                      // Padding so teal peeks below badges before curving
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // ── Cream background area below the teal frame ─────────────────
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Small circular icon badge used in the bottom trust-badges row.
class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  const _BadgeIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        color: Colors.white.withOpacity(0.20),
      ),
      child: Center(
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }
}
