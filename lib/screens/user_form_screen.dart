import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/user_service.dart';

class UserFormScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const UserFormScreen({super.key, required this.onCompleted});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  static const _teal = Color(0xFF016A66);
  static const _surface = Color(0xFFFBFFE6);
  static const _panel = Colors.white;
  static const _ink = Color(0xFF1A2B1C);
  static const _muted = Color(0xFF607264);

  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  late final TextEditingController _aliasController;
  final _locationController = TextEditingController();
  final _aboutController = TextEditingController();
  final _historyController = TextEditingController();

  late String _generatedAlias;
  String? _selectedAgeRange;
  String? _selectedGenderIdentity;
  bool _isSaving = false;

  static const _ageRanges = [
    '13-17',
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55+',
  ];

  static const _genderIdentities = [
    'Woman',
    'Man',
    'Non-binary',
    'Trans woman',
    'Trans man',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _generatedAlias = _userService.generateAlias();
    _aliasController = TextEditingController(text: _generatedAlias);
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _teal,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
              child: Column(
                children: [
                  _buildLogo(),
                  const SizedBox(height: 16),
                  Text(
                    'Kublian',
                    style: GoogleFonts.newsreader(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lihim. Ligtas. Lunas.',
                    style: GoogleFonts.newsreader(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionLabel('Nickname (Optional)'),
                              const SizedBox(height: 8),
                              _AliasField(
                                controller: _aliasController,
                                onRegenerate: _regenerateAlias,
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: _DropdownField(
                                      label: 'Age Range',
                                      hint: 'Select age range',
                                      value: _selectedAgeRange,
                                      items: _ageRanges,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedAgeRange = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _DropdownField(
                                      label: 'Gender Identity',
                                      hint: 'Select gender',
                                      value: _selectedGenderIdentity,
                                      items: _genderIdentities,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGenderIdentity = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              _SectionLabel('Location (City)'),
                              const SizedBox(height: 8),
                              _InputCard(
                                child: TextFormField(
                                  controller: _locationController,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. Quezon City, Metro Manila',
                                    border: InputBorder.none,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your city.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 22),
                              _SectionLabel('About Me'),
                              const SizedBox(height: 8),
                              _InputCard(
                                child: TextFormField(
                                  controller: _aboutController,
                                  minLines: 4,
                                  maxLines: 6,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Briefly share what brings you here today...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),
                              _SectionLabel('Previous Case / History (Optional)'),
                              const SizedBox(height: 8),
                              _InputCard(
                                child: TextFormField(
                                  controller: _historyController,
                                  minLines: 4,
                                  maxLines: 6,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Mention any past contexts that might be helpful for your care plan...',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: SizedBox(
                          height: 56,
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isSaving ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: _teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Confirm'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.18),
      ),
      child: const Icon(
        Icons.spa_outlined,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  void _regenerateAlias() {
    setState(() {
      _generatedAlias = _userService.generateAlias();
      _aliasController.text = _generatedAlias;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No authenticated user found.')),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final alias = _aliasController.text.trim().isEmpty
          ? _generatedAlias
          : _aliasController.text.trim();

      await _userService.createUserProfile(
        uid: user.uid,
        alias: alias,
        ageGroup: _selectedAgeRange!,
        cityLocation: _locationController.text.trim(),
        genderIdentity: _selectedGenderIdentity,
        aboutMe: _aboutController.text.trim(),
        previousHistory: _historyController.text.trim(),
      );

      if (!mounted) {
        return;
      }
      widget.onCompleted();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save your profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _UserFormScreenState._ink,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final Widget child;

  const _InputCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _UserFormScreenState._panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE3EBD7)),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _UserFormScreenState._ink,
        ),
        child: child,
      ),
    );
  }
}

class _AliasField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onRegenerate;

  const _AliasField({
    required this.controller,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return _InputCard(
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'StarlingMist42',
              ),
            ),
          ),
          IconButton(
            onPressed: onRegenerate,
            icon: const Icon(Icons.refresh_rounded),
            color: _UserFormScreenState._teal,
            tooltip: 'Generate alias',
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 8),
        _InputCard(
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            hint: Text(
              hint,
              style: const TextStyle(
                fontSize: 16,
                color: _UserFormScreenState._muted,
              ),
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            validator: validator,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
      ],
    );
  }
}
