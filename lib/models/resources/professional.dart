class Professional {
  final String name;
  final String title;
  final String experience;
  final String clinicName;
  final bool hasF2f;
  final bool hasVirtual;
  final String schedule;
  final String hmos;

  const Professional({
    required this.name,
    required this.title,
    required this.experience,
    required this.clinicName,
    this.hasF2f = true,
    this.hasVirtual = true,
    required this.schedule,
    required this.hmos,
  });
}
