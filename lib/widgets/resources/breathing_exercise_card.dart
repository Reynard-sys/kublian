import 'package:flutter/material.dart';
import 'package:kublian/widgets/resources/resources_header.dart';

class BreathingExerciseCard extends StatefulWidget {
  const BreathingExerciseCard({super.key});

  @override
  State<BreathingExerciseCard> createState() => _BreathingExerciseCardState();
}

class _BreathingExerciseCardState extends State<BreathingExerciseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _running = false;

  // 4s inhale + 7s hold + 8s exhale = 19s total per cycle
  static const _totalMs = 19000;
  static const _inhaleEnd = 4 / 19;
  static const _holdEnd = 11 / 19;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.55, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 4,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 7),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.55)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 8,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _running) {
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _controller.forward(from: 0);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  String get _phaseLabel {
    final t = _controller.value;
    if (!_running) return 'Ready';
    if (t < _inhaleEnd) return 'Inhale';
    if (t < _holdEnd) return 'Hold';
    return 'Exhale';
  }

  String get _secondsLabel {
    final t = _controller.value;
    if (!_running) return '';
    if (t < _inhaleEnd) return '${(4 - t * 19).ceil()} SECONDS';
    if (t < _holdEnd) return '${(11 - t * 19).ceil()} SECONDS';
    return '${(19 - t * 19).ceil()} SECONDS';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 6),
            child: Text('TECHNIQUE',
                style: TextStyle(
                    color: kResPrimaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5)),
          ),
          const Text('Breathing Exercise',
              style: TextStyle(
                  fontFamily: 'Newsreader',
                  color: kResTextDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('The 4-7-8 method for immediate relaxation.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: kResTextMid, fontSize: 13)),
          const SizedBox(height: 28),

          // Animated breathing circle
          Center(
            child: AnimatedBuilder(
              animation: _scaleAnim,
              builder: (context, _) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kResBg,
                    border: Border.all(color: kResDivider, width: 1.5),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: Duration.zero,
                      width: 160 * _scaleAnim.value,
                      height: 160 * _scaleAnim.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          kResPrimary.withValues(alpha: 0.85),
                          kResPrimaryLight.withValues(alpha: 0.65),
                        ]),
                        boxShadow: [
                          BoxShadow(
                            color: kResPrimary.withValues(alpha: 0.3),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_phaseLabel,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700)),
                          if (_secondsLabel.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(_secondsLabel,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 10)),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PhaseChip(label: '4s', sub: 'INHALE'),
              const SizedBox(width: 12),
              _PhaseChip(label: '7s', sub: 'HOLD'),
              const SizedBox(width: 12),
              _PhaseChip(label: '8s', sub: 'EXHALE'),
            ],
          ),
          const SizedBox(height: 28),

          Center(
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 14),
                decoration: BoxDecoration(
                  color: _running ? kResTextMid : kResAccent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  _running ? 'Stop Exercise' : 'Start Exercise',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  final String label;
  final String sub;
  const _PhaseChip({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: kResTextDark,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        Text(sub,
            style: const TextStyle(
                color: kResTextMid, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }
}
