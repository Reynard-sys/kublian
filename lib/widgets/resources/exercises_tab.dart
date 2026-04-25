import 'package:flutter/material.dart';
import 'package:kublian/widgets/resources/resources_header.dart';
import 'package:kublian/widgets/resources/breathing_exercise_card.dart';
import 'package:kublian/widgets/resources/grounding_exercise_card.dart';

class ExercisesTab extends StatefulWidget {
  const ExercisesTab({super.key});

  @override
  State<ExercisesTab> createState() => _ExercisesTabState();
}

class _ExercisesTabState extends State<ExercisesTab> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = (_page + delta).clamp(0, 1);
    if (next == _page) return;
    setState(() => _page = next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(48),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _page == 0 ? const BreathingExerciseCard(key: ValueKey('breathe')) : const GroundingExerciseCard(key: ValueKey('ground')),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ArrowButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => _go(-1),
              enabled: _page > 0,
            ),
            const SizedBox(width: 16),
            _ArrowButton(
              icon: Icons.arrow_forward_rounded,
              onTap: () => _go(1),
              enabled: _page < 1,
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _ArrowButton(
      {required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: enabled ? kResPrimary : kResChipBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: enabled ? Colors.white : kResTextLight, size: 20),
      ),
    );
  }
}
