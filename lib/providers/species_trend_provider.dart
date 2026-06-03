import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final speciesTrendProvider =
    FutureProvider.autoDispose.family<List<int>, String>((ref, species) async {
  final data = await ApiService().getSpeciesTrend(species, days: 7);
  return data.map((d) => (d['count'] as num).toInt()).toList();
});
