import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/gemini_service.dart';
import '../../core/services/session_service.dart';
import '../../core/services/volunteer_service.dart';

const _kRatingTeal = Color(0xFF016A66);
const _kRatingCream = Color(0xFFFCFFED);
const _kRatingSurface = Color(0xFFF7FAEA);
const _kRatingInk = Color(0xFF1A2B1C);
const _kRatingMuted = Color(0xFF617169);
const _kRatingAccent = Color(0xFFD05036);
const _kRatingStar = Color(0xFFF2B63D);

class RatingView extends StatefulWidget {
  final Map<String, dynamic> volunteer;
  final String? summaryId;
  final ValueChanged<int>? onNavigateTab;

  const RatingView({
    super.key,
    required this.volunteer,
    this.summaryId,
    this.onNavigateTab,
  });

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView> {
  final TextEditingController _feedbackController = TextEditingController();
  late final SessionService _sessionService;

  int _selectedRating = 0;
  bool _isSubmitting = false;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _sessionService = SessionService(GeminiService());
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      },
      child: Scaffold(
        backgroundColor: _kRatingCream,
        bottomNavigationBar: _BottomNavBar(
          currentIndex: 0,
          onTap: _navigateToTab,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    children: [
                      _buildVolunteerCard(),
                      const SizedBox(height: 28),
                      _buildRatingCard(),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: () => _navigateToTab(0),
                        child: const Text(
                          'Back to Support',
                          style: TextStyle(
                            color: _kRatingInk,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVolunteerCard() {
    final tags = _displayTags;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      decoration: BoxDecoration(
        color: _kRatingSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFDCE7DE)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: _kRatingTeal,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  _avatarLetters,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                right: -8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFDCE7DE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: _kRatingTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        VolunteerService.formatRating(widget.volunteer),
                        style: const TextStyle(
                          color: _kRatingTeal,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _volunteerAlias,
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              fontSize: 44,
              fontWeight: FontWeight.w600,
              color: _kRatingInk,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _metaLine,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _kRatingMuted,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8ECE7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: _kRatingInk,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    final canSubmit = !_isSubmitting && !_hasSubmitted && _selectedRating > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Rate Peer Session',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _kRatingInk,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'How did this session feel for you?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _kRatingMuted,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: _hasSubmitted
                    ? null
                    : () => setState(() => _selectedRating = index + 1),
                iconSize: 36,
                splashRadius: 24,
                icon: Icon(
                  index < _selectedRating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: _kRatingStar,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _feedbackController,
            enabled: !_hasSubmitted && !_isSubmitting,
            minLines: 4,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Leave feedback for the volunteer...',
              hintStyle: const TextStyle(
                color: _kRatingMuted,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: _kRatingCream,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canSubmit ? _submitRating : null,
              style: FilledButton.styleFrom(
                backgroundColor: _kRatingAccent,
                disabledBackgroundColor: const Color(0xFFD6DAD4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _hasSubmitted ? 'Submitted' : 'Submit',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRating() async {
    if (_selectedRating <= 0 || _isSubmitting || _hasSubmitted) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final feedback = _feedbackController.text.trim();
      if (widget.summaryId != null) {
        await _sessionService.submitPostSessionRating(
          summaryId: widget.summaryId!,
          rating: _selectedRating,
          feedback: feedback.isEmpty ? null : feedback,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _hasSubmitted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.summaryId == null
                ? 'Rating captured on this device.'
                : 'Session rating submitted.',
          ),
        ),
      );

      // Auto-navigate back to Support tab after a brief delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _navigateToTab(2); // 2 is the Support tab
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to submit rating: $e')));
    }
  }

  void _navigateToTab(int index) {
    widget.onNavigateTab?.call(index);
    Navigator.of(context).pop(true);
  }

  List<String> get _displayTags {
    final tags =
        (widget.volunteer['specialtyTags'] as List<dynamic>? ?? const [])
            .take(3)
            .map((tag) => _humanizeTag('$tag'))
            .where((tag) => tag.isNotEmpty)
            .toList();

    if (tags.isNotEmpty) {
      return tags;
    }

    return <String>[widget.volunteer['role'] as String? ?? 'Support'];
  }

  String get _volunteerAlias =>
      widget.volunteer['alias'] as String? ?? 'Matched Volunteer';

  String get _metaLine {
    final role = widget.volunteer['role'] as String? ?? 'Peer Volunteer';
    final totalSessions = widget.volunteer['totalSessions'];
    if (totalSessions == null) {
      return role;
    }
    return '$role | $totalSessions sessions';
  }

  String get _avatarLetters {
    final capitals = _volunteerAlias.replaceAll(RegExp(r'[^A-Z]'), '');
    if (capitals.length >= 2) {
      return capitals.substring(0, 2);
    }

    return _volunteerAlias.length >= 2
        ? _volunteerAlias.substring(0, 2).toUpperCase()
        : _volunteerAlias.toUpperCase();
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
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const items = [
      (icon: Icons.forum_outlined, label: 'Support'),
      (icon: Icons.local_library_outlined, label: 'Resources'),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, bottomInset + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          items.length,
          (index) => Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index].icon,
                      size: 22,
                      color: index == currentIndex
                          ? _kRatingTeal
                          : _kRatingMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index].label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: index == currentIndex
                            ? _kRatingTeal
                            : _kRatingMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
