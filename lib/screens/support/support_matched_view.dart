import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/volunteer_service.dart';

class SupportMatchedView extends StatelessWidget {
  final VoidCallback onStartSession;
  final Map<String, dynamic> volunteer;
  final bool isStartingSession;

  const SupportMatchedView({
    super.key,
    required this.onStartSession,
    required this.volunteer,
    this.isStartingSession = false,
  });

  @override
  Widget build(BuildContext context) {
    final specialties =
        (volunteer['specialtyTags'] as List<dynamic>? ?? const [])
            .take(3)
            .map((tag) => _humanizeTag('$tag'))
            .where((tag) => tag.isNotEmpty)
            .toList();
    final feedbackSnippets =
        (volunteer['feedbackSnippets'] as List<dynamic>? ?? const [])
            .map((snippet) => '$snippet'.trim())
            .where((snippet) => snippet.isNotEmpty)
            .take(3)
            .toList();
    final displayTags = specialties.isEmpty
        ? <String>[volunteer['role'] as String? ?? 'Support']
        : specialties;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildAvatar(),
                  const SizedBox(height: 24),
                  Text(
                    volunteer['alias'] as String? ?? 'Matched Volunteer',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.newsreader(
                      fontSize: 42,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF114D4D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _buildMetaLine(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A2E2E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTags(displayTags),
                  if (feedbackSnippets.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildFeedbackSection(feedbackSnippets),
                  ],
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
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
            color: const Color(0xFF1A2E2E),
          ),
          child: Center(
            child: Text(
              _avatarLetters(),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
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
                  VolunteerService.formatRating(volunteer),
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

  Widget _buildTags(List<String> tags) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: tags
          .map((tag) => _buildTag(tag, const Color(0xFFAEF0E6)))
          .toList(),
    );
  }

  Widget _buildFeedbackSection(List<String> feedbackSnippets) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF114D4D).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What people say',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF114D4D),
            ),
          ),
          const SizedBox(height: 12),
          ...feedbackSnippets.map(_buildFeedbackCard),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF114D4D),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.format_quote_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A2E2E),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
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
      onTap: isStartingSession ? null : onStartSession,
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
          child: isStartingSession
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
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

  String _buildMetaLine() {
    final role = volunteer['role'] as String? ?? 'Peer Volunteer';
    final totalSessions = volunteer['totalSessions'];
    if (totalSessions == null) {
      return role;
    }
    return '$role | $totalSessions sessions';
  }

  String _humanizeTag(String tag) {
    return tag
        .split('-')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  String _avatarLetters() {
    final alias = volunteer['alias'] as String? ?? 'KV';
    final capitals = alias.replaceAll(RegExp(r'[^A-Z]'), '');
    if (capitals.length >= 2) {
      return capitals.substring(0, 2);
    }
    return alias.length >= 2
        ? alias.substring(0, 2).toUpperCase()
        : alias.toUpperCase();
  }
}
