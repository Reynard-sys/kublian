import 'package:flutter/material.dart';
import 'package:kublian/widgets/resources/resources_header.dart';
import 'package:kublian/models/resources/facility.dart';
import 'package:kublian/data/resources/resources_static_data.dart';

class NearbyTab extends StatelessWidget {
  final String city;
  const NearbyTab({super.key, this.city = 'Metro Manila'});

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
                Text('Nearby Facilities',
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
          ...kNearbyFacilities.map((f) => _FacilityCard(facility: f)),
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
                    Text('Showing results in $city',
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

class _FacilityCard extends StatelessWidget {
  final Facility facility;
  const _FacilityCard({required this.facility});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD7E5BB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
                facility.tags.any((t) => t.toLowerCase().contains('specialized') || t.toLowerCase().contains('counseling') || t.toLowerCase().contains('psychiatric'))
                    ? Icons.psychology_outlined
                    : Icons.local_hospital_outlined,
                color: kResPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(facility.name,
                          style: const TextStyle(
                              color: kResTextDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ),
                    if (facility.distance != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7E5BB).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(facility.distance!,
                            style: const TextStyle(
                                color: kResPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(facility.address,
                    style: const TextStyle(
                        color: kResTextMid, fontSize: 12, height: 1.3)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (facility.isOpen24h) _Tag('Open 24/7', kResPrimary),
                    ...facility.tags.map((t) => _Tag(t, kResTextMid)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600)),
    );
  }
}
