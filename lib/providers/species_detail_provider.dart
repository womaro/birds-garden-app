import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/species_detail.dart';
import '../services/api_service.dart';

final speciesDetailProvider = FutureProvider.autoDispose
    .family<SpeciesDetail, String>((ref, species) async {
  final data = await ApiService().getSpeciesDetail(species);
  return SpeciesDetail.fromJson(data);
});