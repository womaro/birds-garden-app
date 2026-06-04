import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';

final lifebirdProvider =
    StateNotifierProvider<LifebirdNotifier, String?>((ref) {
  return LifebirdNotifier(ref.watch(sharedPreferencesProvider));
});

class LifebirdNotifier extends StateNotifier<String?> {
  final dynamic _prefs;
  late Set<String> _celebrated;
  Timer? _timer;

  LifebirdNotifier(this._prefs) : super(null) {
    _celebrated =
        (_prefs.getStringList('lifebirds_celebrated') ?? []).toSet();
    // Pierwsze sprawdzenie po 5s (appka zdąży się załadować)
    Future.delayed(const Duration(seconds: 5), _poll);
    // Polling co 30s
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final data = await ApiService().getSpecies();
      final current =
          data.map((d) => (d['species'] as String)).toSet();
      final newOnes = current.difference(_celebrated);
      if (newOnes.isNotEmpty && mounted) {
        state = newOnes.first; // świętuj jeden na raz
      }
    } catch (_) {}
  }

  void markCelebrated(String species) {
    _celebrated.add(species);
    _prefs.setStringList(
        'lifebirds_celebrated', _celebrated.toList());
    if (mounted) state = null;
    // Sprawdź czy nie ma kolejnych nowych
    Future.delayed(const Duration(milliseconds: 800), _poll);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
