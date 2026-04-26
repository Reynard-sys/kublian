import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kublian/core/services/journal_service.dart';
import 'package:kublian/widgets/resources/resources_header.dart';

const _kJournalPaper = Color(0xFFFFFCF5);
const _kJournalSage = Color(0xFFD6E4D2);
const _kJournalTeal = Color(0xFF016A66);
const _kJournalInk = Color(0xFF1A2E2E);
const _kJournalMuted = Color(0xFF5C716C);
const _kJournalAccent = Color(0xFFD05036);

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService _journalService = JournalService();
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy | h:mm a');

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: kResBg,
      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              onPressed: () => _openComposer(uid: user.uid),
              backgroundColor: _kJournalAccent,
              foregroundColor: Colors.white,
              elevation: 3,
              child: const Icon(Icons.edit_note_rounded, size: 26),
            ),
      body: Column(
        children: [
          const ResourcesHeader(),
          Expanded(
            child: user == null
                ? _buildSignedOutState()
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _journalService.getEntries(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: _kJournalTeal,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildErrorState();
                      }

                      final entries =
                          snapshot.data ?? const <Map<String, dynamic>>[];
                      return _buildJournalContent(
                        uid: user.uid,
                        entries: entries,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignedOutState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Text(
          'Sign in to open your private journal.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _kJournalMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 34,
                color: _kJournalAccent,
              ),
              const SizedBox(height: 14),
              Text(
                'Your journal could not load right now.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kJournalInk,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try again in a moment. Journal entries remain private to your account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _kJournalMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalContent({
    required String uid,
    required List<Map<String, dynamic>> entries,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
      children: [
        _buildHero(entries.length),
        const SizedBox(height: 22),
        if (entries.isEmpty)
          _buildEmptyState(uid)
        else
          ...entries.map((entry) => _buildEntryCard(uid: uid, entry: entry)),
      ],
    );
  }

  Widget _buildHero(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF7FBF0),
            Color(0xFFE7F1EC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_rounded,
                  size: 14,
                  color: _kJournalTeal,
                ),
                const SizedBox(width: 6),
                Text(
                  'Only you can read these entries',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kJournalTeal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Dear Self.',
            style: GoogleFonts.newsreader(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: _kJournalInk,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Capture what today felt like, what you survived, and what you want to remember.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _kJournalMuted,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '$count ${count == 1 ? 'entry' : 'entries'} in your private space',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _kJournalInk,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String uid) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              color: _kJournalSage,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 34,
              color: _kJournalTeal,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Your first page is waiting.',
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _kJournalInk,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start with a thought, a moment, or a feeling. You can edit or delete any entry later.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _kJournalMuted,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _openComposer(uid: uid),
            style: FilledButton.styleFrom(
              backgroundColor: _kJournalTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: const Icon(Icons.edit_note_rounded),
            label: Text(
              'Write First Entry',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard({
    required String uid,
    required Map<String, dynamic> entry,
  }) {
    final createdAt = _dateLabel(_asDateTime(entry['createdAt']));
    final updatedAt = _asDateTime(entry['updatedAt']);
    final isEdited = updatedAt != null &&
        _asDateTime(entry['createdAt']) != null &&
        updatedAt.isAfter(_asDateTime(entry['createdAt'])!);
    final moodTag = _humanizeMood('${entry['moodTag'] ?? 'Reflective'}');
    final moodScore = (entry['moodScore'] as num?)?.toInt() ?? 5;
    final moodColor = _moodColor(moodScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildEntryChip(
                      icon: Icons.favorite_rounded,
                      label: moodTag,
                      color: moodColor,
                      foreground: Colors.white,
                    ),
                    _buildEntryChip(
                      icon: Icons.tune_rounded,
                      label: '$moodScore/10',
                      color: _kJournalPaper,
                      foreground: _kJournalInk,
                    ),
                    _buildEntryChip(
                      icon: Icons.lock_outline_rounded,
                      label: 'Private',
                      color: const Color(0xFFE9F3EF),
                      foreground: _kJournalTeal,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _openComposer(uid: uid, entry: entry);
                  } else if (value == 'delete') {
                    _confirmDelete(uid: uid, entryId: '${entry['id']}');
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.more_horiz_rounded,
                    color: _kJournalMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${entry['text'] ?? ''}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _kJournalInk,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: _kJournalMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isEdited ? '$createdAt • edited' : createdAt,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kJournalMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntryChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openComposer({
    required String uid,
    Map<String, dynamic>? entry,
  }) async {
    final draft = await showModalBottomSheet<_JournalDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _JournalComposerSheet(entry: entry),
    );

    if (draft == null) {
      return;
    }

    try {
      if (entry == null) {
        await _journalService.addEntry(
          uid: uid,
          moodScore: draft.moodScore,
          moodTag: draft.moodTag,
          text: draft.text,
        );
      } else {
        await _journalService.updateEntry(
          uid: uid,
          entryId: '${entry['id']}',
          moodScore: draft.moodScore,
          moodTag: draft.moodTag,
          text: draft.text,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save journal entry: $e')),
      );
    }
  }

  Future<void> _confirmDelete({
    required String uid,
    required String entryId,
  }) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete this entry?'),
              content: const Text(
                'This removes the journal entry from your private journal.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kJournalAccent,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    try {
      await _journalService.deleteEntry(uid, entryId);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete journal entry: $e')),
      );
    }
  }

  DateTime? _asDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  String _dateLabel(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Saving...';
    }
    return _dateFormat.format(dateTime);
  }

  String _humanizeMood(String mood) {
    return mood
        .split('-')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  Color _moodColor(int moodScore) {
    if (moodScore <= 3) {
      return const Color(0xFFD05036);
    }
    if (moodScore <= 6) {
      return const Color(0xFFD58D2C);
    }
    return _kJournalTeal;
  }
}

class _JournalComposerSheet extends StatefulWidget {
  final Map<String, dynamic>? entry;

  const _JournalComposerSheet({this.entry});

  @override
  State<_JournalComposerSheet> createState() => _JournalComposerSheetState();
}

class _JournalComposerSheetState extends State<_JournalComposerSheet> {
  static const _moodOptions = [
    'Heavy',
    'Anxious',
    'Drained',
    'Reflective',
    'Hopeful',
    'Calm',
    'Joyful',
    'Grateful',
    'Frustrated',
    'Overwhelmed',
    'Content',
    'Energetic',
  ];

  late final TextEditingController _textController;
  late int _moodScore;
  late String _moodTag;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.entry?['text'] as String? ?? '',
    );
    _moodScore = (widget.entry?['moodScore'] as num?)?.toInt() ?? 5;
    _moodTag = widget.entry?['moodTag'] as String? ?? 'Reflective';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7DEDB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEditing ? 'Edit Journal Entry' : 'New Journal Entry',
                  style: GoogleFonts.newsreader(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: _kJournalInk,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Write freely. This space stays attached only to your account.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _kJournalMuted,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _textController,
                  minLines: 8,
                  maxLines: 12,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText:
                        'What did today feel like? What do you want to let out or hold onto?',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: _kJournalMuted,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: _kJournalPaper,
                    contentPadding: const EdgeInsets.all(18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Mood',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kJournalInk,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _moodOptions
                      .map((option) => _buildMoodChip(option))
                      .toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Intensity',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kJournalInk,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$_moodScore/10',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kJournalTeal,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: _kJournalTeal,
                    inactiveTrackColor: _kJournalSage,
                    thumbColor: _kJournalTeal,
                    overlayColor: _kJournalTeal.withValues(alpha: 0.1),
                  ),
                  child: Slider(
                    value: _moodScore.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    onChanged: (value) {
                      setState(() => _moodScore = value.round());
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: _kJournalAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Update Entry' : 'Save Entry',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodChip(String option) {
    final isSelected = _moodTag == option;
    return GestureDetector(
      onTap: () => setState(() => _moodTag = option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _kJournalTeal : _kJournalPaper,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          option,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : _kJournalInk,
          ),
        ),
      ),
    );
  }

  void _save() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something before saving.')),
      );
      return;
    }

    Navigator.of(context).pop(
      _JournalDraft(
        text: text,
        moodTag: _moodTag,
        moodScore: _moodScore,
      ),
    );
  }
}

class _JournalDraft {
  final String text;
  final String moodTag;
  final int moodScore;

  const _JournalDraft({
    required this.text,
    required this.moodTag,
    required this.moodScore,
  });
}
