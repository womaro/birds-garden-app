import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/species_summary.dart';
import '../services/api_service.dart';

final speciesProvider =
    StateNotifierProvider<SpeciesNotifier, AsyncValue<List<SpeciesSummary>>>(
  (ref) => SpeciesNotifier(),
);

class SpeciesNotifier extends StateNotifier<AsyncValue<List<SpeciesSummary>>> {
  SpeciesNotifier() : super(const AsyncLoading()) {
    load();
  }

  final _api = ApiService();

  Future<void> load() async {
    try {
      final data = await _api.getSpecies();
      if (mounted) {
        state = AsyncData(data.map(SpeciesSummary.fromJson).toList());
      }
    } catch (e, st) {
      if (mounted) state = AsyncError(e, st);
    }
  }
}