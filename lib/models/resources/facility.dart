class Facility {
  final String name;
  final String address;
  final List<String> tags;
  final String? distance;
  final bool isOpen24h;

  const Facility({
    required this.name,
    required this.address,
    this.tags = const [],
    this.distance,
    this.isOpen24h = false,
  });
}
