import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgreementScreen extends StatefulWidget {
  final VoidCallback onAccepted;

  const AgreementScreen({super.key, required this.onAccepted});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  bool _hasAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF016A66),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Image.asset(
                  'assets/images/kublian_logo.png',
                  width: 56,
                  height: 56,
                  errorBuilder: (_, __, ___) => Container(
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
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Kublian',
                  style: GoogleFonts.newsreader(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Lihim. Ligtas. Lunas.',
                  style: GoogleFonts.newsreader(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 56),
              const _AgreementSection(
                title: 'The Incognito Model',
                body:
                    'Unlike traditional platforms, Kublian operates on a zero-identification framework. We do not link your biometric data or emotional logs to your real-world identity. Your presence here is defined by your experiences, not your metadata.',
              ),
              const SizedBox(height: 32),
              const _AgreementSection(
                title: 'Ephemeral Presence',
                body:
                    'Data is living, and like all living things, it must pass. We implement a mandatory 30-day purge cycle for all non-essential interaction logs. You remain in control of what stays and what fades into the digital ether.',
              ),
              const SizedBox(height: 32),
              const _AgreementSection(
                title: 'Private Journaling',
                body:
                    'Your thoughts are your own. All journaling features utilize end-to-end encryption. Kublian engineers, AI models, and third-party partners have zero visibility into your personal reflections.',
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => setState(() => _hasAgreed = !_hasAgreed),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: _hasAgreed
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Color(0xFF016A66),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'I understand and agree to the Kublian Privacy Agreement',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _hasAgreed ? widget.onAccepted : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF016A66),
                    disabledBackgroundColor: Colors.white.withOpacity(0.45),
                    disabledForegroundColor: Colors.white.withOpacity(0.8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Accept and Continue'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgreementSection extends StatelessWidget {
  final String title;
  final String body;

  const _AgreementSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.88),
            height: 1.55,
          ),
        ),
      ],
    );
  }
}
