import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

/// (species, lang) → {story, generated_at, cached}
final storyProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, (String, String)>((ref, args) async {
  final (species, lang) = args;
  return ApiService().getSpeciesStory(species, lang);
});