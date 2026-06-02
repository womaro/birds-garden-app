class SpeciesSummary {
  final String name;
  final int visits;
  final DateTime lastSeen;
  final DateTime firstSeen;
  final String favoriteHour;
  final int daysInGarden;
  final bool isRare;
  final int starRating;

  const SpeciesSummary({
    required this.name,
    required this.visits,
    required this.lastSeen,
    required this.firstSeen,
    required this.favoriteHour,
    required this.daysInGarden,
    required this.isRare,
    required this.starRating,
  });

  factory SpeciesSummary.fromJson(Map<String, dynamic> j) {
    final h      = (j['favorite_hour'] as num?)?.toInt() ?? 8;
    final visits = (j['visits'] as num?)?.toInt() ?? 0;
    final days   = (j['days_in_garden'] as num?)?.toInt() ?? 1;

    final stars = visits >= 100 ? 5
        : visits >= 30 ? 4
        : visits >= 10 ? 3
        : visits >= 5  ? 2
        : 1;

    return SpeciesSummary(
      name:         j['species'] as String,
      visits:       visits,
      lastSeen:     DateTime.parse(j['last_seen']  as String),
      firstSeen:    DateTime.parse(j['first_seen'] as String),
      favoriteHour: '${h.toString().padLeft(2, '0')}:00',
      daysInGarden: days,
      isRare:       visits < 5,
      starRating:   stars,
    );
  }
}