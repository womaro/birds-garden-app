class Detection {
  final int id;
  final DateTime timestamp;
  final String species;
  final double confidence;
  final String type;

  Detection({
    required this.id,
    required this.timestamp,
    required this.species,
    required this.confidence,
    required this.type,
  });

  factory Detection.fromJson(Map<String, dynamic> j) => Detection(
    id: j['id'],
    timestamp: DateTime.parse(j['timestamp']),
    species: j['species'] ?? 'Unknown',
    confidence: (j['confidence'] ?? 0).toDouble(),
    type: j['type'] ?? 'audio',
  );
}