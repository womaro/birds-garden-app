class SpeciesDetail {
  final String species;
  final int visits;
  final int favoriteHour;
  final int daysInGarden;
  final List<int> hourlyHistogram;

  const SpeciesDetail({
    required this.species,
    required this.visits,
    required this.favoriteHour,
    required this.daysInGarden,
    required this.hourlyHistogram,
  });

  factory SpeciesDetail.fromJson(Map<String, dynamic> j) => SpeciesDetail(
    species:          j['species'] as String,
    visits:           (j['visits'] as num?)?.toInt() ?? 0,
    favoriteHour:     (j['favorite_hour'] as num?)?.toInt() ?? 8,
    daysInGarden:     (j['days_in_garden'] as num?)?.toInt() ?? 1,
    hourlyHistogram:  List<int>.from(
      (j['hourly_histogram'] as List?)?.map((e) => (e as num).toInt()) ??
      List.filled(24, 0),
    ),
  );
}