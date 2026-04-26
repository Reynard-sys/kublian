import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kublian/widgets/resources/resources_header.dart';
import 'package:kublian/models/resources/hotline.dart';
import 'package:kublian/data/resources/resources_static_data.dart';

class HotlinesTab extends StatelessWidget {
  const HotlinesTab({super.key});

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number.replaceAll('-', ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: kResAccent, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text('Emergency Hotlines',
                  style: TextStyle(
                      color: kResTextDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          ...kEmergencyHotlines.map((h) =>
              _HotlineCard(hotline: h, onCall: () => _call(h.number))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kResAccent.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kResAccent.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.info_outline_rounded,
                      color: kResAccent, size: 18),
                  const SizedBox(width: 8),
                  const Text('When to call?',
                      style: TextStyle(
                          color: kResAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ]),
                const SizedBox(height: 8),
                Text(kWhenToCallText,
                    style: const TextStyle(
                        color: kResTextMid, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HotlineCard extends StatelessWidget {
  final Hotline hotline;
  final VoidCallback onCall;

  const _HotlineCard({required this.hotline, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kResSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotline.name,
                    style: const TextStyle(
                        color: kResTextMid,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(hotline.number,
                    style: const TextStyle(
                        color: kResTextDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                if (hotline.note != null)
                  Text(hotline.note!,
                      style: const TextStyle(
                          color: kResTextLight, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCall,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFC62828), // Deep red for urgent call to action
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Row(children: [
                Icon(Icons.call_rounded, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('Call',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
