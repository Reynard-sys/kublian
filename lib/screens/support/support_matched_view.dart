import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportMatchedView extends StatelessWidget {
  final VoidCallback onStartSession;

  const SupportMatchedView({super.key, required this.onStartSession});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const SizedBox(height: 60),
          _buildAvatar(),
          const SizedBox(height: 24),
          Text(
            'QuietPine',
            style: GoogleFonts.newsreader(
              fontSize: 42,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF114D4D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Peer Volunteer since 2022',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2E2E),
            ),
          ),
          const SizedBox(height: 20),
          _buildTags(),
          const Spacer(),
          _buildStartButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/images/user-placeholder.png'), // Will fallback if missing, but we can just use a colored container with an icon
              fit: BoxFit.cover,
            ),
            color: const Color(0xFF1A2E2E),
          ),
          child: const Icon(Icons.person, size: 80, color: Color(0xFF3B5757)), // Fallback
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF114D4D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                Text(
                  '4.8',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _buildTag('Anxiety Specialist', const Color(0xFFAEF0E6)),
        _buildTag('Grief Support', const Color(0xFFAEF0E6)),
        _buildTag('Mindfulness', const Color(0xFFE2D4F0)),
      ],
    );
  }

  Widget _buildTag(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF1A2E2E),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: onStartSession,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFD05036),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Start Session',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
