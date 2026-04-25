// lib/core/services/volunteer_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../dummy_data/volunteers.dart';

class VolunteerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          .map((doc) => doc.data())
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
        return doc.data();
      }
    } catch (e) {
      debugPrint('VolunteerService.getVolunteerById error: $e');
    }

    return dummyVolunteers.cast<Map<String, dynamic>?>().firstWhere(
          (v) => v?['id'] == id,
          orElse: () => dummyVolunteers.isNotEmpty ? dummyVolunteers.first : null,
        );
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
      (a, b) => (b['rating'] as num).compareTo(a['rating'] as num),
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
        .toList();
  }
}
