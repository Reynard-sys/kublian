import 'package:flutter/material.dart';
import 'package:kublian/widgets/resources/resources_header.dart';
import 'package:kublian/models/resources/professional.dart';
import 'package:kublian/data/resources/resources_static_data.dart';

class NearbySupportTab extends StatelessWidget {
  final String city;
  const NearbySupportTab({super.key, this.city = 'Metro Manila'});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [
                Icon(Icons.location_on, color: kResPrimary, size: 18),
                SizedBox(width: 6),
                Text('Nearby Support',
                    style: TextStyle(
                        color: kResTextDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
              ]),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0)),
                child: const Text('View Map',
                    style: TextStyle(
                        color: kResPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MapPlaceholder(city: city),
          const SizedBox(height: 16),
          ...kNearbyProfessionals.map((p) => _ProfessionalCard(professional: p)),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final String city;
  const _MapPlaceholder({required this.city});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            color: const Color(0xFFB2D8D8),
            child: CustomPaint(painter: _MapGridPainter()),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8)
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on,
                        color: kResPrimary, size: 14),
                    const SizedBox(width: 4),
                    Text('Showing 4 results in Quezon City',
                        style: const TextStyle(
                            color: kResTextDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF9ECECE).withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final roadPaint = Paint()..color = Colors.white..strokeWidth = 6;
    canvas.drawLine(Offset(0, size.height * 0.45),
        Offset(size.width, size.height * 0.45), roadPaint);
    canvas.drawLine(Offset(size.width * 0.35, 0),
        Offset(size.width * 0.35, size.height), roadPaint);
  }

  @override
  bool shouldRepaint(_MapGridPainter _) => false;
}

class _ProfessionalCard extends StatelessWidget {
  final Professional professional;
  const _ProfessionalCard({required this.professional});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kResSurface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(professional.name,
                        style: const TextStyle(
                            color: kResTextDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.map_outlined, size: 13, color: kResTextMid),
                        const SizedBox(width: 4),
                        Text(professional.title,
                            style: const TextStyle(
                                color: kResTextMid, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(professional.experience,
                          style: const TextStyle(
                              color: Color(0xFFC0D6D2), // Based on image, it's very light text
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoRow(icon: Icons.location_on_outlined, text: professional.clinicName),
          if (professional.hasF2f)
            _InfoRow(icon: Icons.check_circle_outline, text: 'Face-to-face consultation'),
          if (professional.hasVirtual)
            _InfoRow(
              icon: Icons.check_circle_outline, 
              text: 'Virtual Consultation',
              actionText: 'see all clinics',
            ),
          _InfoRow(icon: Icons.access_time, text: professional.schedule),
          _InfoRow(icon: Icons.shield_outlined, text: professional.hmos),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionText;

  const _InfoRow({required this.icon, required this.text, this.actionText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2DD4BF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text,
                    style: const TextStyle(color: kResTextDark, fontSize: 13, height: 1.4)),
                if (actionText != null) ...[
                  const SizedBox(height: 2),
                  Text(actionText!,
                      style: const TextStyle(
                          color: Color(0xFF2DD4BF),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
