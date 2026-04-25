import 'package:flutter/material.dart';

// ─── Shared Design Tokens ────────────────────────────────────────────────────
// These constants are re-exported from this file so any widget/screen can do:
//   import 'package:kublian/widgets/resources/resources_header.dart';
// and get both the widget AND the tokens in one import.

const Color kResBg = Color(0xFFF5F0E8);
const Color kResPrimary = Color(0xFF1D5050);
const Color kResPrimaryLight = Color(0xFF2E7070);
const Color kResSurface = Color(0xFFFFFFFF);
const Color kResAccent = Color(0xFFCC4438);
const Color kResTextDark = Color(0xFF1A2E2E);
const Color kResTextMid = Color(0xFF5A7070);
const Color kResTextLight = Color(0xFF9EB5B5);
const Color kResChipBg = Color(0xFFE8E2D8);
const Color kResDivider = Color(0xFFE0DAD0);
const Color kResPrimaryLightBg = Color(0xFF2A6262);

class ResourcesHeader extends StatelessWidget {
  const ResourcesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: kResPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: Colors.white70, size: 14),
                    SizedBox(width: 4),
                    Text('resources',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            letterSpacing: 1.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Pahinga Muna.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 1.2),
          ),
          const SizedBox(height: 10),
          const Text(
            "This is your safe space. Let us know how you're feeling so we "
            "can find the right companion for your heart.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white70, fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
