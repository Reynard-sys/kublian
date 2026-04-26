// lib/core/services/volunteer_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../dummy_data/volunteers.dart';

class VolunteerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> _averageRatingFields = [
    'averageRating',
    'avgRating',
    'ratingAverage',
    'averageStars',
  ];

  static const List<String> _ratingTotalFields = [
    'totalStars',
    'starsTotal',
    'starTotal',
    'ratingTotal',
  ];

  static const List<String> _ratingCountFields = [
    'ratingCount',
    'totalRatings',
    'ratingsCount',
    'reviewCount',
    'reviewsCount',
    'totalReviews',
  ];

  static Map<String, dynamic> normalizeVolunteer(Map<String, dynamic> volunteer) {
    final normalized = Map<String, dynamic>.from(volunteer);
    final averageRating =
        _extractAverageRating(normalized) ?? _fallbackSeedRating(normalized['id']);

    if (averageRating != null) {
      normalized['rating'] = averageRating;
    }

    return normalized;
  }

  static String formatRating(
    Map<String, dynamic> volunteer, {
    double fallback = 4.8,
  }) {
    final rating =
        _extractAverageRating(volunteer) ??
        _fallbackSeedRating(volunteer['id']) ??
        fallback;
    return rating.toStringAsFixed(1);
  }

  // ==========================================
  // FETCH POOL
  // ==========================================

  /// Fetches all available volunteers from Firestore, excluding [blockedIds].
  ///
  /// Falls back to [dummyVolunteers] only when [allowFallback] is true.
  Future<List<Map<String, dynamic>>> getAvailableVolunteers(
    List<String> blockedIds, {
    bool allowFallback = true,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('volunteers')
          .where('availability', isEqualTo: 'available')
          .get();

      final volunteers = snapshot.docs
          .map((doc) => normalizeVolunteer(doc.data()))
          .where((v) => !blockedIds.contains(v['id']))
          .toList();

      if (volunteers.isEmpty) {
        if (!allowFallback) {
          debugPrint(
            'VolunteerService: Firestore returned empty and fallback is disabled.',
          );
          return <Map<String, dynamic>>[];
        }

        debugPrint(
          'VolunteerService: Firestore returned empty; using dummy data.',
        );
        return _applyBlockList(dummyVolunteers, blockedIds);
      }

      return volunteers;
    } catch (e) {
      if (!allowFallback) {
        debugPrint(
          'VolunteerService.getAvailableVolunteers error: $e; fallback disabled.',
        );
        return <Map<String, dynamic>>[];
      }

      debugPrint(
        'VolunteerService.getAvailableVolunteers error: $e; falling back to dummy data.',
      );
      return _applyBlockList(dummyVolunteers, blockedIds);
    }
  }

  // ==========================================
  // FETCH SINGLE
  // ==========================================

  /// Fetches a single volunteer by [id] from Firestore.
  /// Falls back to dummy data if not found or on error.
  Future<Map<String, dynamic>?> getVolunteerById(String id) async {
    try {
      final doc = await _firestore.collection('volunteers').doc(id).get();
      if (doc.exists) {
        return normalizeVolunteer(doc.data()!);
      }
    } catch (e) {
      debugPrint('VolunteerService.getVolunteerById error: $e');
    }

    final fallback = dummyVolunteers.cast<Map<String, dynamic>?>().firstWhere(
          (v) => v?['id'] == id,
          orElse: () => dummyVolunteers.isNotEmpty ? dummyVolunteers.first : null,
        );
    return fallback == null ? null : normalizeVolunteer(fallback);
  }

  // ==========================================
  // FALLBACK HELPER
  // ==========================================

  /// Returns the highest-rated eligible volunteer from the provided pool.
  Map<String, dynamic>? highestRatedFallback(
    List<Map<String, dynamic>> pool,
    List<String> blockedIds,
  ) {
    final eligible = _applyBlockList(pool, blockedIds);
    if (eligible.isEmpty) {
      return null;
    }

    eligible.sort(
      (a, b) => (_sortRating(b)).compareTo(_sortRating(a)),
    );
    return eligible.first;
  }

  List<Map<String, dynamic>> _applyBlockList(
    List<Map<String, dynamic>> volunteers,
    List<String> blockedIds,
  ) {
    return volunteers
        .where(
          (v) =>
              v['availability'] == 'available' &&
              !blockedIds.contains(v['id']),
        )
        .map(normalizeVolunteer)
        .toList();
  }

  static double _sortRating(Map<String, dynamic> volunteer) {
    return _extractAverageRating(volunteer) ??
        _fallbackSeedRating(volunteer['id']) ??
        0.0;
  }

  static double? _extractAverageRating(Map<String, dynamic> volunteer) {
    for (final field in _averageRatingFields) {
      final value = _sanitizeAverage(_coerceNum(volunteer[field]));
      if (value != null) {
        return value;
      }
    }

    final rawRating = _coerceNum(volunteer['rating']);
    final directRating = _sanitizeAverage(rawRating);
    if (directRating != null) {
      return directRating;
    }

    final totalStars =
        _firstNum(volunteer, _ratingTotalFields) ??
        ((rawRating != null && rawRating > 5) ? rawRating : null);
    final ratingCount = _firstNum(volunteer, _ratingCountFields);
    if (totalStars != null && ratingCount != null && ratingCount > 0) {
      return _sanitizeAverage(totalStars / ratingCount);
    }

    return null;
  }

  static double? _fallbackSeedRating(dynamic volunteerId) {
    final id = '$volunteerId';
    for (final volunteer in dummyVolunteers) {
      if ('${volunteer['id']}' == id) {
        return _sanitizeAverage(_coerceNum(volunteer['rating']));
      }
    }
    return null;
  }

  static num? _firstNum(
    Map<String, dynamic> volunteer,
    List<String> fieldNames,
  ) {
    for (final field in fieldNames) {
      final value = _coerceNum(volunteer[field]);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  static num? _coerceNum(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

  static double? _sanitizeAverage(num? value) {
    if (value == null) {
      return null;
    }

    final rating = value.toDouble();
    if (!rating.isFinite || rating < 0 || rating > 5) {
      return null;
    }

    return (rating * 10).round() / 10;
  }
}
