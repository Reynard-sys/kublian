import 'package:flutter/material.dart';
import 'package:kublian/widgets/resources/resources_header.dart';

class GroundingExerciseCard extends StatelessWidget {
  const GroundingExerciseCard({super.key});

  static const _steps = [
    (n: 5, icon: Icons.visibility_outlined, sense: 'things you see',
      tip: 'Acknowledge five objects in your environment.', iconColor: Color(0xFF006B5F), iconBgColor: Color(0x332DD4BF)),
    (n: 4, icon: Icons.back_hand_outlined, sense: 'things you can touch',
      tip: 'Focus on textures — clothing, furniture, air.', iconColor: Color(0xFF566342), iconBgColor: Color(0x33D7E5BB)),
    (n: 3, icon: Icons.hearing_outlined, sense: 'things you can hear',
      tip: 'Listen for distant or subtle background noises.', iconColor: Color(0xFF8D4F00), iconBgColor: Color(0x33FFAC5A)),
    (n: 2, icon: Icons.air_outlined, sense: 'things you can smell',
      tip: 'Breathe deeply; notice the aroma of the room.', iconColor: Color(0xFF006B5F), iconBgColor: Color(0x332DD4BF)),
    (n: 1, icon: Icons.restaurant_outlined, sense: 'thing you can taste',
      tip: 'Focus on the current sensation in your mouth.', iconColor: Color(0xFF566342), iconBgColor: Color(0x33D7E5BB)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 6),
            child: Text('SENSORY FOCUS',
                style: TextStyle(
                    color: kResPrimaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5)),
          ),
          const Text('5-4-3-2-1\nGrounding',
              style: TextStyle(
                  fontFamily: 'Newsreader',
                  color: kResTextDark,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.2)),
          const SizedBox(height: 20),
          ..._steps.map((step) => _GroundingStep(
                number: step.n,
                icon: step.icon,
                sense: step.sense,
                tip: step.tip,
                iconColor: step.iconColor,
                iconBgColor: step.iconBgColor,
              )),
        ],
      ),
    );
  }
}

class _GroundingStep extends StatelessWidget {
  final int number;
  final IconData icon;
  final String sense;
  final String tip;
  final Color iconColor;
  final Color iconBgColor;

  const _GroundingStep({
    required this.number,
    required this.icon,
    required this.sense,
    required this.tip,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFFEE),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: kResTextDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    children: [
                      TextSpan(text: '$number '),
                      TextSpan(
                          text: sense,
                          style: const TextStyle(
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(tip,
                    style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans', color: kResTextMid, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
