import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportMatchingView extends StatefulWidget {
  final VoidCallback onMatchFound;

  const SupportMatchingView({super.key, required this.onMatchFound});

  @override
  State<SupportMatchingView> createState() => _SupportMatchingViewState();
}

class _SupportMatchingViewState extends State<SupportMatchingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) widget.onMatchFound();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildPulsingHeart(),
          const SizedBox(height: 60),
          Text(
            'Finding someone who\nunderstands...',
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF114D4D),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Gemini is matching you with a peer\nsupporter based on your current\nfeelings.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A2E2E),
              height: 1.5,
            ),
          ),
          const Spacer(),
          _buildTipCard(),
        ],
      ),
    );
  }

  Widget _buildPulsingHeart() {
    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                _buildCircle(_controller.value * 200, 1.0 - _controller.value),
                _buildCircle(
                    ((_controller.value + 0.5) % 1.0) * 200,
                    1.0 - ((_controller.value + 0.5) % 1.0)),
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(0xFF114D4D),
                    size: 24,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFD2DECC).withValues(alpha: opacity * 0.5),
        border: Border.all(
          color: const Color(0xFFD2DECC).withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFBFE5DF), // Light teal background
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.air, color: Color(0xFF114D4D), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRACTICE PAHINGA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF114D4D),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Focus on your breath while we find your match. You are in a safe space.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1A2E2E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
