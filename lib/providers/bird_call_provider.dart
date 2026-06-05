import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/xeno_canto_service.dart';

enum CallStatus { idle, loading, playing, error }

class BirdCallState {
  final CallStatus status;
  final String? species;

  const BirdCallState({
    this.status = CallStatus.idle,
    this.species,
  });

  BirdCallState copyWith({CallStatus? status, String? species}) =>
      BirdCallState(
        status: status ?? this.status,
        species: species ?? this.species,
      );

  bool isPlayingFor(String name) =>
      species == name && status == CallStatus.playing;

  bool isLoadingFor(String name) =>
      species == name && status == CallStatus.loading;
}

class BirdCallNotifier extends StateNotifier<BirdCallState> {
  final _player  = AudioPlayer();
  final _service = XenoCantoService();

  BirdCallNotifier() : super(const BirdCallState()) {
    _player.setVolume(1.0);
    _player.onPlayerStateChanged.listen((ps) {
      if (ps == PlayerState.completed || ps == PlayerState.stopped) {
        if (mounted) state = const BirdCallState();
      }
    });
  }

  Future<void> play(String speciesName, String scientificName) async {
    debugPrint('🎵 PLAY called: $scientificName');
    await _player.stop();

    state = BirdCallState(status: CallStatus.loading, species: speciesName);

    final url = await _service.getBestCallUrl(scientificName);

    if (url == null) {
      state = BirdCallState(status: CallStatus.error, species: speciesName);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) state = const BirdCallState();
      return;
    }

    try {
      await _player.play(UrlSource(url));
      if (mounted) {
        state = BirdCallState(status: CallStatus.playing, species: speciesName);
      }
    } catch (_) {
      if (mounted) state = const BirdCallState();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    if (mounted) state = const BirdCallState();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final birdCallProvider =
    StateNotifierProvider<BirdCallNotifier, BirdCallState>(
  (_) => BirdCallNotifier(),
);
