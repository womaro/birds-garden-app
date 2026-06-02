import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/detection.dart';
import '../services/api_service.dart';

final detectionsProvider =
    StateNotifierProvider<DetectionsNotifier, AsyncValue<List<Detection>>>(
  (ref) => DetectionsNotifier(),
);

class DetectionsNotifier extends StateNotifier<AsyncValue<List<Detection>>> {
  DetectionsNotifier() : super(const AsyncLoading()) {
    _load();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _load());
  }

  final _api = ApiService();
  Timer? _timer;

  Future<void> _load() async {
    try {
      final data = await _api.getDetections(limit: 200);
      if (mounted) state = AsyncData(data.map(Detection.fromJson).toList());
    } catch (e, st) {
      if (mounted) state = AsyncError(e, st);
    }
  }

  void refresh() => _load();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}