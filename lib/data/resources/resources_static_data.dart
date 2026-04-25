// All imports use package: paths — safe for any file location, no relative guessing.
import 'package:kublian/models/resources/hotline.dart';
import 'package:kublian/models/resources/facility.dart';

const List<Hotline> kEmergencyHotlines = [
  Hotline(name: 'DOH iCARE', number: '1553'),
  Hotline(name: 'NCMH Crisis Hotline', number: '0917-899-8727'),
  Hotline(name: 'Hopeline PH', number: '2919', note: 'Toll-Free'),
  Hotline(name: 'In Touch Community', number: '8893-7603'),
];

const List<Facility> kNearbyFacilities = [
  Facility(
    name: 'National Center for Mental Health',
    address: 'Nueve de Febrero St, Mandaluyong',
    tags: ['Public', 'Psychiatric'],
    distance: '1.2 KM',
    isOpen24h: true,
  ),
  Facility(
    name: 'Philippine General Hospital',
    address: 'Taft Ave, Ermita, Manila',
    tags: ['Public', 'Psychiatric Unit'],
    distance: '2.4 KM',
    isOpen24h: true,
  ),
  Facility(
    name: 'Makati Medical Center',
    address: '2 Amorsolo St, Legazpi Village, Makati',
    tags: ['Private', 'Specialized'],
    distance: '3.1 KM',
    isOpen24h: false,
  ),
  Facility(
    name: 'The Medical City',
    address: 'Ortigas Ave, Pasig',
    tags: ['Private', 'Psychiatric'],
    distance: '3.8 KM',
    isOpen24h: false,
  ),
];

const String kWhenToCallText =
    'If you or someone you know is in immediate danger or experiencing a '
    'crisis, please use these hotlines. They are available 24/7 and are '
    'completely confidential.';
