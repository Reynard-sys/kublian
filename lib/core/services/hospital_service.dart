// lib/core/services/hospital_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Fetches city-based hospital data from the `hospitals` Firestore collection.
///
/// ⚠️ Privacy rule: location is NEVER written to Firestore.
/// This service uses the user's stored [cityLocation] field (set during onboarding)
/// to look up hospitals. The device's GPS is requested only at escalation Level 2
/// (crisis) and is used solely to refine this lookup — it is discarded immediately.
class HospitalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Maps the user-facing city name to the Firestore document slug.
  static const _citySlugMap = {
    'Taguig': 'taguig',
    'Makati': 'makati',
    'Quezon City': 'quezon_city',
    'Mandaluyong': 'mandaluyong',
    'Pasig': 'pasig',
    'Manila': 'manila',
  };

  // ==========================================
  // FETCH BY CITY
  // ==========================================

  /// Returns a list of hospitals for [city].
  ///
  /// Falls back to the `hospitals/default` document if the city slug is not
  /// in [_citySlugMap] or if the document doesn't exist.
  ///
  /// Falls back to [_staticFallback] if Firestore is unreachable — critical
  /// for the crisis screen which must work even with poor connectivity.
  Future<List<Map<String, dynamic>>> getHospitalsForCity(String city) async {
    final slug = _citySlugMap[city] ?? 'default';

    try {
      final doc =
          await _firestore.collection('hospitals').doc(slug).get();

      if (doc.exists && doc.data() != null) {
        final list = doc.data()!['hospitals'] as List<dynamic>?;
        if (list != null && list.isNotEmpty) {
          return list.cast<Map<String, dynamic>>();
        }
      }

      // City doc exists but is empty — fall through to default
      return _fetchDefault();
    } catch (e) {
      debugPrint('HospitalService.getHospitalsForCity("$city") error: $e');
      return _fetchDefault();
    }
  }

  // ==========================================
  // PRIVATE HELPERS
  // ==========================================

  Future<List<Map<String, dynamic>>> _fetchDefault() async {
    try {
      final doc =
          await _firestore.collection('hospitals').doc('default').get();
      final list = doc.data()?['hospitals'] as List<dynamic>?;
      return list?.cast<Map<String, dynamic>>() ?? _staticFallback();
    } catch (e) {
      debugPrint('HospitalService._fetchDefault error: $e — using static fallback.');
      return _staticFallback();
    }
  }

  /// Hard-coded last-resort fallback used when Firestore is completely
  /// unreachable (e.g., no network during crisis escalation).
  List<Map<String, dynamic>> _staticFallback() {
    return [
      {
        'name': 'National Center for Mental Health (NCMH)',
        'address': 'Nueve de Febrero St, Mandaluyong',
        'hotline': '0917-899-8727',
      },
      {
        'name': 'Philippine General Hospital — Psychiatry Dept',
        'address': 'Taft Ave, Ermita, Manila',
        'hotline': '(02) 8554-8400',
      },
      {
        'name': 'Makati Medical Center',
        'address': '2 Amorsolo St, Legazpi Village, Makati',
        'hotline': '(02) 8888-8999',
      },
    ];
  }
}
