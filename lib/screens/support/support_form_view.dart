import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportFormView extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSubmit;
  final VoidCallback onNavigateToLibrary;

  const SupportFormView({
    super.key,
    required this.onSubmit,
    required this.onNavigateToLibrary,
  });

  @override
  State<SupportFormView> createState() => _SupportFormViewState();
}

class _SupportFormViewState extends State<SupportFormView> {
  double _heartValue = 0.5;
  Set<String> _selectedMinds = {'Relationships'};
  String _selectedGender = 'Female';
  String _selectedHelp = 'I just want to vent';

  final _mindOptions = [
    'Academic Stress',
    'Relationships',
    'Loneliness',
    'Grief',
    'Family',
    'Career Pressure'
  ];

  final _genderOptions = ['Female', 'Male', 'Other'];

  final _helpOptions = [
    (icon: Icons.chat_bubble_outline, text: 'I just want to vent'),
    (icon: Icons.lightbulb_outline, text: 'I need advice'),
    (icon: Icons.self_improvement, text: 'Help me stay grounded'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          Text(
            'Pahinga Muna.',
            style: GoogleFonts.newsreader(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2E2E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This is your safe space. Let us know how you\'re feeling so we can find the right companion for your heart.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2E2E),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFD2DECC), // Matches the sage green background
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('How is your heart today?'),
                const SizedBox(height: 16),
                _buildSlider(),
                const SizedBox(height: 32),
                _buildSectionHeader('What\'s on your mind?'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _mindOptions.map((opt) => _buildMindChip(opt)).toList(),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('Gender Preference'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _genderOptions.map((opt) => _buildGenderChip(opt)).toList(),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('How can we help?'),
                const SizedBox(height: 16),
                ..._helpOptions.map((opt) => _buildHelpTile(opt.icon, opt.text)),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 20),
                Center(
                  child: InkWell(
                    onTap: widget.onNavigateToLibrary,
                    child: Text.rich(
                      TextSpan(
                        text: 'Not ready to talk yet? ',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF1A2E2E), fontSize: 11, fontWeight: FontWeight.w500),
                        children: [
                          TextSpan(
                            text: 'Explore other\nresources',
                            style: GoogleFonts.plusJakartaSans(decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A2E2E),
      ),
    );
  }

  Widget _buildSlider() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.sentiment_very_dissatisfied, color: Color(0xFFC62828)), // Hard Red
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 8,
                  activeTrackColor: Color.lerp(const Color(0xFFC62828), const Color(0xFF016A66), _heartValue),
                  inactiveTrackColor: Color.lerp(const Color(0xFFC62828), const Color(0xFF016A66), _heartValue)?.withValues(alpha: 0.3),
                  thumbColor: Color.lerp(const Color(0xFFC62828), const Color(0xFF016A66), _heartValue),
                  overlayColor: Color.lerp(const Color(0xFFC62828), const Color(0xFF016A66), _heartValue)?.withValues(alpha: 0.1),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: Slider(
                  value: _heartValue,
                  onChanged: (val) => setState(() => _heartValue = val),
                ),
              ),
            ),
            const Icon(Icons.sentiment_very_satisfied, color: Color(0xFF016A66)), // Dark Green
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mabigat (Heavy)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1A2E2E))),
              Text('Payapa (Peaceful)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1A2E2E))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMindChip(String label) {
    final isSelected = _selectedMinds.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedMinds.remove(label);
          } else {
            _selectedMinds.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD05036) : const Color(0xFFB9C4B7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1A2E2E),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChip(String label) {
    final isSelected = _selectedGender == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD05036) : const Color(0xFFB9C4B7).withValues(alpha: 0.6), // Active is red/orange like mind options
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1A2E2E),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildHelpTile(IconData icon, String text) {
    final isSelected = _selectedHelp == text;
    return GestureDetector(
      onTap: () => setState(() => _selectedHelp = text),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF114D4D),
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_outline, color: Color(0xFF2DD4BF), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: () => widget.onSubmit(_buildIntakeForm()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF86BFA4), Color(0xFF114D4D)], // Light teal to dark teal
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Find a Peer Supporter',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _buildIntakeForm() {
    return {
      'moodScore': (_heartValue * 9).round() + 1,
      'situationTags': _selectedMinds.map(_normalizeTag).toList(),
      'genderPreference': _selectedGender,
      'supportType': _selectedHelp,
      'lastSessionSummary': null,
    };
  }

  String _normalizeTag(String value) {
    return value.toLowerCase().replaceAll(' ', '-');
  }
}
