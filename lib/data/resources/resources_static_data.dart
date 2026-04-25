// All imports use package: paths — safe for any file location, no relative guessing.
import 'package:kublian/models/resources/hotline.dart';
import 'package:kublian/models/resources/facility.dart';
import 'package:kublian/models/resources/professional.dart';

const List<Hotline> kEmergencyHotlines = [
  Hotline(name: 'DOH iCARE', number: '1553'),
  Hotline(name: 'NCMH Crisis Hotline', number: '0917-899-8727'),
  Hotline(name: 'Hopeline PH', number: '2919', note: 'Toll-Free'),
  Hotline(name: 'In Touch Community', number: '8893-7603'),
];

const List<Facility> kNearbyFacilities = [
  Facility(
    name: 'St. Luke\'s Medical Center',
    address: 'E. Rodriguez Sr. Ave, Quezon City',
    tags: ['Psychiatric Unit'],
    distance: '0.8 KM',
    isOpen24h: true,
  ),
  Facility(
    name: 'Philippine Heart Center',
    address: 'East Avenue, Diliman',
    tags: ['Public', 'Specialized'],
    distance: '1.5 KM',
    isOpen24h: false,
  ),
  Facility(
    name: 'Metropolitan Medical',
    address: 'G. Masangkay St, Manila',
    tags: ['Counseling', 'Private'],
    distance: '2.3 KM',
    isOpen24h: false,
  ),
];

const List<Professional> kNearbyProfessionals = [
  Professional(
    name: 'Dr. Nairobi Dy',
    title: 'MD - Pediatrics',
    experience: '21 yrs of experience',
    clinicName: 'Dy Clinic, Binondo, Manila',
    hasF2f: true,
    hasVirtual: true,
    schedule: 'Mon, 12:00 am - 11:59 pm (Walk-in)',
    hmos: 'Kaiser International, Maxicare',
  ),
  Professional(
    name: 'Dr. Nairobi Dy',
    title: 'MD - Pediatrics',
    experience: '21 yrs of experience',
    clinicName: 'Dy Clinic, Binondo, Manila',
    hasF2f: true,
    hasVirtual: true,
    schedule: 'Mon, 12:00 am - 11:59 pm (Walk-in)',
    hmos: 'Kaiser International, Maxicare',
  ),
];

const String kWhenToCallText =
    'If you or someone you know is in immediate danger or experiencing a '
    'crisis, please use these hotlines. They are available 24/7 and are '
    'completely confidential.';
