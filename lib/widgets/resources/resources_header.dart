import 'package:flutter/material.dart';

// ─── Shared Design Tokens ────────────────────────────────────────────────────
// These constants are re-exported from this file so any widget/screen can do:
//   import 'package:kublian/widgets/resources/resources_header.dart';
// and get both the widget AND the tokens in one import.

const Color kResBg = Color(0xFFFCFFEE);
const Color kResPrimary = Color(0xFF016A66);
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
      color: kResPrimary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 16,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'Kublian',
            style: TextStyle(
              fontFamily: 'Newsreader',
              color: Colors.white,
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
