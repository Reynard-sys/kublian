import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kublian/widgets/resources/resources_header.dart';
import 'package:kublian/core/services/gemini_service.dart';
import 'package:kublian/core/services/session_service.dart';
import 'package:kublian/core/services/user_service.dart';
import 'package:kublian/core/services/volunteer_service.dart';
import 'package:kublian/screens/support/support_form_view.dart';
import 'package:kublian/screens/support/support_matching_view.dart';
import 'package:kublian/screens/support/support_matched_view.dart';
import 'package:kublian/screens/chat_screen.dart';

enum SupportState { form, matching, matched }

class SupportFlowScreen extends StatefulWidget {
  final VoidCallback onNavigateToLibrary;
  final ValueChanged<int>? onNavigateTab;

  const SupportFlowScreen({
    super.key,
    required this.onNavigateToLibrary,
    this.onNavigateTab,
  });

  @override
  State<SupportFlowScreen> createState() => _SupportFlowScreenState();
}

class _SupportFlowScreenState extends State<SupportFlowScreen> {
  SupportState _currentState = SupportState.form;
  final _geminiService = GeminiService();
  final _userService = UserService();
  final _volunteerService = VolunteerService();

  Map<String, dynamic>? _intakeForm;
  Map<String, dynamic>? _matchedVolunteer;
  Map<String, dynamic>? _userProfile;
  bool _isStartingSession = false;

  void _resetFlow() {
    _currentState = SupportState.form;
    _intakeForm = null;
    _matchedVolunteer = null;
    _userProfile = null;
    _isStartingSession = false;
  }

  void _startMatching(Map<String, dynamic> intakeForm) {
    setState(() {
      _intakeForm = intakeForm;
      _matchedVolunteer = null;
      _currentState = SupportState.matching;
    });
    _runMatching();
  }

  Future<void> _runMatching() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('You need to be signed in before matching starts.');
      return;
    }

    final profile = await _userService.getUserProfile(user.uid);
    if (!mounted) {
      return;
    }
    if (profile == null) {
      _showError('We could not load your user profile for matching.');
      return;
    }

    final blockedIds = (profile['blockedVolunteers'] as List<dynamic>? ?? const [])
        .map((id) => '$id')
        .toList();
    final intakeForm = {
      ...?_intakeForm,
      'lastSessionSummary': profile['lastSessionSummary'],
    };

    final pool = await _volunteerService.getAvailableVolunteers(
      blockedIds,
      allowFallback: false,
    );
    if (!mounted) {
      return;
    }
    if (pool.isEmpty) {
      _showError('No available volunteers were found right now.');
      return;
    }

    // Shuffle the pool so Gemini sees candidates in a random order,
    // encouraging dynamic random matching among equally qualified volunteers.
    pool.shuffle();

    final matchedVolunteerId =
        await _geminiService.matchVolunteer(intakeForm, pool);
    if (!mounted) {
      return;
    }

    Map<String, dynamic>? volunteer;
    if (matchedVolunteerId != null) {
      for (final candidate in pool) {
        if ('${candidate['id']}' == matchedVolunteerId) {
          volunteer = candidate;
          break;
        }
      }
    }

    volunteer ??= _volunteerService.highestRatedFallback(pool, blockedIds);
    if (volunteer == null) {
      _showError('Matching failed. Please try again.');
      return;
    }

    setState(() {
      _intakeForm = intakeForm;
      _userProfile = profile;
      _matchedVolunteer = volunteer;
      _currentState = SupportState.matched;
    });
  }

  Future<void> _startSession() async {
    if (_matchedVolunteer == null || _userProfile == null || _intakeForm == null) {
      _showError('Missing match context. Please start matching again.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('You need to be signed in before starting a session.');
      return;
    }

    setState(() => _isStartingSession = true);

    try {
      final sessionService = SessionService(_geminiService);
      final sessionId = await sessionService.createSession(
        userId: user.uid,
        userAlias: _userProfile!['alias'] as String? ?? 'Anonymous',
        volunteerId: _matchedVolunteer!['id'] as String,
        intakeForm: _intakeForm!,
      );

      if (!mounted) {
        return;
      }

      final sessionEnded = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            volunteer: _matchedVolunteer,
            userLabel: _userProfile!['alias'] as String? ?? 'You',
            previousSummary: _userProfile!['lastSessionSummary'] as String?,
            sessionId: sessionId,
            userId: user.uid,
            onNavigateTab: widget.onNavigateTab,
            onBack: () => Navigator.of(context).pop(),
            onSessionEnded: () => Navigator.of(context).pop(true),
          ),
        ),
      );

      if (mounted && (sessionEnded ?? false)) {
        setState(_resetFlow);
      }
    } catch (e) {
      if (mounted) {
        _showError('Unable to start the session: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isStartingSession = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _resetFlow();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentState) {
      case SupportState.form:
        return SupportFormView(
          key: const ValueKey('form'),
          onSubmit: _startMatching,
          onNavigateToLibrary: widget.onNavigateToLibrary,
        );
      case SupportState.matching:
        return const SupportMatchingView(
          key: ValueKey('matching'),
        );
      case SupportState.matched:
        return SupportMatchedView(
          key: const ValueKey('matched'),
          volunteer: _matchedVolunteer!,
          isStartingSession: _isStartingSession,
          onStartSession: _startSession,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ResourcesHeader(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentView(),
          ),
        ),
      ],
    );
  }

}
