import 'package:flutter/material.dart';
import 'package:kublian/widgets/resources/resources_header.dart';
import 'package:kublian/screens/support/support_form_view.dart';
import 'package:kublian/screens/support/support_matching_view.dart';
import 'package:kublian/screens/support/support_matched_view.dart';
import 'package:kublian/screens/chat_screen.dart';

enum SupportState { form, matching, matched }

class SupportFlowScreen extends StatefulWidget {
  final VoidCallback onNavigateToLibrary;

  const SupportFlowScreen({super.key, required this.onNavigateToLibrary});

  @override
  State<SupportFlowScreen> createState() => _SupportFlowScreenState();
}

class _SupportFlowScreenState extends State<SupportFlowScreen> {
  SupportState _currentState = SupportState.form;

  void _startMatching() {
    setState(() => _currentState = SupportState.matching);
  }

  void _onMatchFound() {
    setState(() => _currentState = SupportState.matched);
  }

  void _startSession() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
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

  Widget _buildCurrentView() {
    switch (_currentState) {
      case SupportState.form:
        return SupportFormView(
          key: const ValueKey('form'),
          onSubmit: _startMatching,
          onNavigateToLibrary: widget.onNavigateToLibrary,
        );
      case SupportState.matching:
        return SupportMatchingView(
          key: const ValueKey('matching'),
          onMatchFound: _onMatchFound,
        );
      case SupportState.matched:
        return SupportMatchedView(
          key: const ValueKey('matched'),
          onStartSession: _startSession,
        );
    }
  }
}
