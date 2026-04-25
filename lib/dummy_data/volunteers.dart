// Dart mirror of the `volunteers` Firestore collection seeded per MD.
// Used as fallback when Firestore is unreachable.
// IDs v_001–v_005 match Firestore exactly. v_006 is a local expansion.

const List<Map<String, dynamic>> dummyVolunteers = [
  {
    'id': 'v_001',
    'alias': 'CalmRiver',
    'role': 'Certified Peer Supporter',
    'specialtyTags': ['anxiety', 'academic-stress', 'burnout'],
    'experienceTags': ['survived-burnout', 'academic-pressure'],
    'rating': 4.9,
    'totalSessions': 87,
    'availability': 'available',
    'feedbackSnippets': [
      'Very patient and non-judgmental.',
      'Helped me feel less alone.',
      'Asked the right questions.',
    ],
  },
  {
    'id': 'v_002',
    'alias': 'StillWater',
    'role': 'Certified Peer Supporter',
    'specialtyTags': ['grief', 'loss', 'loneliness'],
    'experienceTags': ['lost-a-loved-one', 'long-distance-relationship'],
    'rating': 4.7,
    'totalSessions': 53,
    'availability': 'available',
    'feedbackSnippets': [
      'Made me feel understood.',
      'Gentle and grounding presence.',
    ],
  },
  {
    'id': 'v_003',
    'alias': 'QuietPine',
    'role': 'Certified Peer Supporter',
    'specialtyTags': ['relationships', 'family-conflict', 'self-worth'],
    'experienceTags': ['family-estrangement', 'breakup'],
    'rating': 4.8,
    'totalSessions': 61,
    'availability': 'available',
    'feedbackSnippets': [
      "Didn't rush me.",
      'Gave practical grounding tips.',
    ],
  },
  {
    'id': 'v_004',
    'alias': 'MorningFog',
    'role': 'Certified Peer Supporter',
    'specialtyTags': ['depression', 'isolation', 'hopelessness'],
    'experienceTags': ['depression-recovery', 'social-withdrawal'],
    'rating': 4.6,
    'totalSessions': 39,
    'availability': 'available',
    'feedbackSnippets': [
      'Spoke from real experience.',
      'Helped me name what I was feeling.',
    ],
  },
  {
    'id': 'v_005',
    'alias': 'EmberLight',
    'role': 'Licensed Psychiatrist',
    'specialtyTags': ['trauma', 'panic-attacks', 'crisis-support'],
    'experienceTags': ['clinical-intervention', 'trauma-recovery'],
    'rating': 4.9,
    'totalSessions': 112,
    'availability': 'available',
    'feedbackSnippets': [
      'Calm under pressure.',
      'Explained what was happening to my brain clearly.',
    ],
  },
  {
    'id': 'v_006',
    'alias': 'SteadyCompass',
    'role': 'Psychometrician',
    'specialtyTags': ['behavioral-patterns', 'adhd-coping', 'routine-building'],
    'experienceTags': ['neurodivergent-support', 'cognitive-framing'],
    'rating': 4.8,
    'totalSessions': 45,
    'availability': 'available',
    'feedbackSnippets': [
      'Gave me great practical steps.',
      'Very analytical but still so warm.',
    ],
  },
];