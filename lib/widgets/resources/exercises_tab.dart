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
    _pageController.animateToPage(next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    setState(() => _page = next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              BreathingExerciseCard(),
              GroundingExerciseCard(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Row(
            children: [
              Row(
                children: List.generate(
                    2,
                    (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 6),
                          width: _page == i ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                _page == i ? kResPrimary : kResChipBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
              ),
              const Spacer(),
              _ArrowButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => _go(-1),
                enabled: _page > 0,
              ),
              const SizedBox(width: 10),
              _ArrowButton(
                icon: Icons.arrow_forward_rounded,
                onTap: () => _go(1),
                enabled: _page < 1,
              ),
            ],
          ),
        ),
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
