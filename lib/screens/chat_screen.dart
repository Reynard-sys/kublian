import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/services/gemini_service.dart';
import '../core/services/session_service.dart';
import '../core/services/user_service.dart';
import '../dummy_data/volunteers.dart';
import 'support/rating_view.dart';

const _kChatTeal = Color(0xFF016A66);
const _kChatCream = Color(0xFFFCFFED);
const _kChatSurface = Color(0xFFFBFFE6);
const _kChatInk = Color(0xFF1A2B1C);
const _kChatAlert = Color(0xFFD05036);

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic>? volunteer;
  final String userLabel;
  final String? previousSummary;
  final String? sessionId;
  final String? userId;
  final ValueChanged<int>? onNavigateTab;
  final VoidCallback? onBack;
  final VoidCallback? onSessionEnded;

  const ChatScreen({
    super.key,
    this.volunteer,
    this.userLabel = 'You',
    this.previousSummary,
    this.sessionId,
    this.userId,
    this.onNavigateTab,
    this.onBack,
    this.onSessionEnded,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DateFormat _timeFormat = DateFormat('h:mm a');
  final GeminiService _geminiService = GeminiService();
  final UserService _userService = UserService();

  late final SessionService _sessionService;
  late final Map<String, dynamic> _volunteer;

  final List<_ChatMessage> _messages = <_ChatMessage>[];

  bool _isReplying = false;
  bool _isEndingSession = false;
  bool _isHardEnding = false;
  bool _hasEndedSession = false;
  int _escalationLevel = 0;

  @override
  void initState() {
    super.initState();
    _sessionService = SessionService(_geminiService);
    _volunteer = widget.volunteer ?? _defaultVolunteer();
    _composerController.addListener(_handleComposerChanged);
    _seedOpeningMessage();
  }

  @override
  void dispose() {
    _composerController.removeListener(_handleComposerChanged);
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kChatTeal,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 16),
                  _buildPrivacyBanner(),
                  const SizedBox(height: 18),
                  _buildVolunteerHero(),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: _kChatSurface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    if (_escalationLevel > 0) _buildEscalationBanner(),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        itemCount: _messages.length + (_isReplying ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isReplying && index == _messages.length) {
                            return _TypingIndicator(alias: _volunteerAlias);
                          }

                          final message = _messages[index];
                          return _MessageBubble(
                            message: message,
                            isCurrentUser: message.senderId == 'user',
                            accentColor: _kChatTeal,
                            timestamp: _timeFormat.format(message.timestamp),
                          );
                        },
                      ),
                    ),
                    _buildComposer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        InkWell(
          onTap: _handleBack,
          borderRadius: BorderRadius.circular(999),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        _buildSessionEndButton(
          label: 'Soft End',
          icon: Icons.flag_outlined,
          backgroundColor: Colors.white,
          foregroundColor: _kChatTeal,
          showProgress: _isEndingSession && !_isHardEnding,
          onPressed: _handleSoftEndSession,
        ),
        const SizedBox(width: 8),
        _buildSessionEndButton(
          label: 'Hard End',
          icon: Icons.close_rounded,
          backgroundColor: _kChatAlert,
          foregroundColor: Colors.white,
          showProgress: _isEndingSession && _isHardEnding,
          onPressed: _handleHardEndSession,
        ),
      ],
    );
  }

  Widget _buildSessionEndButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required bool showProgress,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: _isEndingSession || _hasEndedSession ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        disabledForegroundColor: foregroundColor.withOpacity(0.7),
        disabledBackgroundColor: backgroundColor.withOpacity(0.7),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      icon: showProgress
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
              ),
            )
          : Icon(icon, size: 15),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPrivacyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, size: 18, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This session is private and will not be stored. Messages vanish once you leave.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerHero() {
    final specialties =
        (_volunteer['specialtyTags'] as List<dynamic>? ?? const [])
            .take(3)
            .toList();

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.24),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _avatarLetters,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned(
              right: -10,
              bottom: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: _kChatTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_volunteer['rating'] ?? '4.8'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _kChatTeal,
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
          style: GoogleFonts.newsreader(
            fontSize: 42,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _volunteerMeta,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: specialties
              .map(
                (tag) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _humanizeTag('$tag'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEscalationBanner() {
    final isCritical = _escalationLevel == 2;
    final background = isCritical
        ? const Color(0xFFFCE0DA)
        : const Color(0xFFFFF2CF);
    final border = isCritical
        ? const Color(0xFFD05036)
        : const Color(0xFFD0A536);
    final text = isCritical
        ? 'A crisis-safe response was detected. This conversation may need urgent human follow-up.'
        : 'This conversation may need support beyond peer guidance. Consider elevating the session flow.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCritical ? Icons.warning_rounded : Icons.info_outline_rounded,
              size: 18,
              color: border,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _kChatInk,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    final canSend = _composerController.text.trim().isNotEmpty &&
        !_isReplying &&
        !_isEndingSession &&
        !_hasEndedSession;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _composerController,
              enabled: !_hasEndedSession && !_isEndingSession,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: _hasEndedSession
                    ? 'Session ended.'
                    : 'Type your heart out...',
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7A8A7C),
                ),
                filled: true,
                fillColor: _kChatCream,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: canSend ? _sendMessage : null,
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: canSend ? _kChatTeal : const Color(0xFFD7DEDB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _handleComposerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!.call();
      return;
    }

    Navigator.of(context).maybePop();
  }

  Future<void> _handleSoftEndSession() async {
    if (_isEndingSession || _hasEndedSession) {
      return;
    }

    final confirmed = await _confirmEndDialog(
      title: 'Soft end this session?',
      message:
          'This closes the session gently, prepares a handover summary, and brings the user to the rating screen.',
      actionLabel: 'Soft End',
      actionColor: _kChatTeal,
    );

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isEndingSession = true;
      _isHardEnding = false;
    });

    final summaryId = await _performSoftEnd();
    if (!mounted) {
      return;
    }

    setState(() {
      _isEndingSession = false;
      _hasEndedSession = true;
    });

    Navigator.of(context).pushReplacement<bool, bool>(
      MaterialPageRoute<bool>(
        builder: (context) => RatingView(
          volunteer: _volunteer,
          summaryId: summaryId,
          onNavigateTab: widget.onNavigateTab,
        ),
      ),
    );
  }

  Future<void> _handleHardEndSession() async {
    if (_isEndingSession || _hasEndedSession) {
      return;
    }

    final confirmed = await _confirmEndDialog(
      title: 'Hard end this session?',
      message:
          'This closes the session immediately and skips the soft-end rating flow.',
      actionLabel: 'Hard End',
      actionColor: _kChatAlert,
    );

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isEndingSession = true;
      _isHardEnding = true;
    });

    await _performHardEnd();
    if (!mounted) {
      return;
    }

    setState(() {
      _isEndingSession = false;
      _hasEndedSession = true;
    });

    await _showHardEndActions();
    if (!mounted) {
      return;
    }

    if (widget.onSessionEnded != null) {
      widget.onSessionEnded!.call();
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<bool> _confirmEndDialog({
    required String title,
    required String message,
    required String actionLabel,
    required Color actionColor,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: actionColor,
                  ),
                  child: Text(actionLabel),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _sendMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty || _isReplying || _isEndingSession || _hasEndedSession) {
      return;
    }

    FocusScope.of(context).unfocus();
    _composerController.clear();

    final userMessage = _ChatMessage(
      senderId: 'user',
      senderLabel: widget.userLabel,
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isReplying = true;
    });
    _scrollToBottom();
    await _mirrorMessageToSession(userMessage);

    String reply;
    try {
      reply = await _geminiService.generateChatResponse(
        _geminiHistory,
        _volunteer,
        widget.previousSummary,
      );
    } catch (_) {
      reply =
          'Sorry, nagkakaroon ako ng slight connection issue. Dito lang ako, please give me a moment.';
    }

    if (!mounted) {
      return;
    }

    final escalationLevel = _extractEscalationLevel(reply);
    final cleanedReply = _stripTriggerTags(reply).trim();

    final volunteerMessage = _ChatMessage(
      senderId: _volunteer['id'] as String? ?? 'volunteer',
      senderLabel: _volunteerAlias,
      text: cleanedReply.isEmpty ? "I'm here for you." : cleanedReply,
      timestamp: DateTime.now(),
    );

    setState(() {
      _isReplying = false;
      _messages.add(volunteerMessage);
      if (escalationLevel > _escalationLevel) {
        _escalationLevel = escalationLevel;
      }
    });
    _scrollToBottom();
    await _mirrorMessageToSession(volunteerMessage);

    if (escalationLevel > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
              escalationLevel == 2 ? const Color(0xFFB43A21) : _kChatInk,
          content: Text(
            escalationLevel == 2
                ? 'Critical support signal detected from Gemini response.'
                : 'Escalation signal detected from Gemini response.',
          ),
        ),
      );
    }
  }

  Future<void> _mirrorMessageToSession(_ChatMessage message) async {
    if (widget.sessionId == null) {
      return;
    }

    try {
      await _sessionService.sendMessage(
        sessionId: widget.sessionId!,
        senderId: message.senderId,
        text: message.text,
      );
    } catch (_) {
      // The screen still works in local-only mode when Firestore is absent.
    }
  }

  Future<String?> _performSoftEnd() async {
    if (widget.sessionId != null && widget.userId != null) {
      try {
        final result = await _sessionService.endSessionUserInitiated(
          sessionId: widget.sessionId!,
          userId: widget.userId!,
          volunteerData: _volunteer,
        );
        return result.summaryId;
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  Future<void> _performHardEnd() async {
    if (widget.sessionId == null || widget.userId == null) {
      return;
    }

    try {
      await _sessionService.endSessionForce(
        sessionId: widget.sessionId!,
        userId: widget.userId!,
      );
    } catch (_) {
      // Keep the local flow responsive even when Firestore writes fail.
    }
  }

  Future<void> _showHardEndActions() async {
    if (widget.userId == null) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) {
        return _HardEndActionsSheet(
          volunteerAlias: _volunteerAlias,
          onReport: () => _applyHardEndAction(
            report: true,
            block: false,
          ),
          onBlock: () => _applyHardEndAction(
            report: false,
            block: true,
          ),
          onReportAndBlock: () => _applyHardEndAction(
            report: true,
            block: true,
          ),
        );
      },
    );
  }

  Future<void> _applyHardEndAction({
    required bool report,
    required bool block,
  }) async {
    Navigator.of(context).pop();

    final messenger = ScaffoldMessenger.of(context);
    final volunteerId = _volunteer['id'] as String?;
    final userId = widget.userId;
    if (volunteerId == null || userId == null) {
      return;
    }

    try {
      if (report) {
        await _sessionService.createVolunteerReport(
          userId: userId,
          volunteerId: volunteerId,
          sessionId: widget.sessionId,
          details: 'User selected ${block ? 'report_and_block' : 'report'} after hard ending the session.',
        );
      }

      if (block) {
        await _userService.blockVolunteer(userId, volunteerId);
      }

      if (!mounted) {
        return;
      }

      final message = switch ((report, block)) {
        (true, true) => 'Volunteer reported and blocked.',
        (true, false) => 'Volunteer reported.',
        (false, true) => 'Volunteer blocked from future matches.',
        _ => 'Action saved.',
      };

      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text('Unable to save action: $e')),
      );
    }
  }

  void _seedOpeningMessage() {
    _messages.add(
      _ChatMessage(
        senderId: _volunteer['id'] as String? ?? 'volunteer',
        senderLabel: _volunteerAlias,
        text:
            "Hello there. I'm here to listen if you'd like to share what's on your mind today.",
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  List<Map<String, dynamic>> get _geminiHistory {
    return _messages
        .map(
          (message) => {
            'senderId': message.senderId == 'user'
                ? 'user'
                : (_volunteer['id'] as String? ?? 'volunteer'),
            'text': message.text,
          },
        )
        .toList();
  }

  Map<String, dynamic> _defaultVolunteer() {
    return dummyVolunteers.firstWhere(
      (volunteer) => volunteer['id'] == 'v_003',
      orElse: () => dummyVolunteers.first,
    );
  }

  int _extractEscalationLevel(String text) {
    if (text.contains('[TRIGGER_ESCALATE_L2]')) {
      return 2;
    }
    if (text.contains('[TRIGGER_ESCALATE_L1]')) {
      return 1;
    }
    return 0;
  }

  String _stripTriggerTags(String text) {
    return text
        .replaceAll('[TRIGGER_ESCALATE_L1]', '')
        .replaceAll('[TRIGGER_ESCALATE_L2]', '');
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

  String get _volunteerAlias => _volunteer['alias'] as String? ?? 'QuietPine';

  String get _volunteerMeta {
    final role = _volunteer['role'] as String? ?? 'Peer Volunteer';
    final sessions = _volunteer['totalSessions'];
    if (sessions == null) {
      return role;
    }
    return '$role | $sessions sessions';
  }

  String get _avatarLetters {
    final alias = _volunteerAlias;
    final capitals = alias.replaceAll(RegExp(r'[^A-Z]'), '');
    if (capitals.length >= 2) {
      return capitals.substring(0, 2);
    }
    return alias.characters.take(2).toString().toUpperCase();
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool isCurrentUser;
  final Color accentColor;
  final String timestamp;

  const _MessageBubble({
    required this.message,
    required this.isCurrentUser,
    required this.accentColor,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isCurrentUser ? accentColor : Colors.white;
    final textColor = isCurrentUser ? Colors.white : _kChatInk;
    final metaColor = isCurrentUser
        ? const Color(0xFF6C7C70)
        : const Color(0xFF7A8A7C);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: Radius.circular(isCurrentUser ? 22 : 8),
                  bottomRight: Radius.circular(isCurrentUser ? 8 : 22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  height: 1.55,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${message.senderLabel} | $timestamp',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: metaColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final String alias;

  const _TypingIndicator({required this.alias});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(),
                SizedBox(width: 6),
                _TypingDot(),
                SizedBox(width: 6),
                _TypingDot(),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$alias is typing...',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7A8A7C),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatelessWidget {
  const _TypingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Color(0x7A316763),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _HardEndActionsSheet extends StatelessWidget {
  final String volunteerAlias;
  final VoidCallback onReport;
  final VoidCallback onBlock;
  final VoidCallback onReportAndBlock;

  const _HardEndActionsSheet({
    required this.volunteerAlias,
    required this.onReport,
    required this.onBlock,
    required this.onReportAndBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              'Session with $volunteerAlias ended',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _kChatInk,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You can leave now, or take an action on this volunteer before closing the session.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF56645A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _HardEndActionButton(
              label: 'Report Volunteer',
              color: const Color(0xFFF5E5C7),
              textColor: _kChatInk,
              onPressed: onReport,
            ),
            const SizedBox(height: 10),
            _HardEndActionButton(
              label: 'Block Volunteer',
              color: const Color(0xFFE7EFEA),
              textColor: _kChatInk,
              onPressed: onBlock,
            ),
            const SizedBox(height: 10),
            _HardEndActionButton(
              label: 'Report and Block',
              color: _kChatAlert,
              textColor: Colors.white,
              onPressed: onReportAndBlock,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kChatInk,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HardEndActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const _HardEndActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String senderId;
  final String senderLabel;
  final String text;
  final DateTime timestamp;

  const _ChatMessage({
    required this.senderId,
    required this.senderLabel,
    required this.text,
    required this.timestamp,
  });
}
