import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bird_call_provider.dart';
import '../theme.dart';

class BirdCallButton extends ConsumerWidget {
  final String speciesName;
  final String scientificName;
  final bool compact;

  const BirdCallButton({
    required this.speciesName,
    required this.scientificName,
    this.compact = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state     = ref.watch(birdCallProvider);
    final isPlaying = state.isPlayingFor(speciesName);
    final isLoading = state.isLoadingFor(speciesName);
    final isError   = state.species == speciesName &&
        state.status == CallStatus.error;

    void onTap() {
      debugPrint('🎵 TAPPED: $speciesName / $scientificName');
      if (isPlaying) {
        ref.read(birdCallProvider.notifier).stop();
      } else {
        ref.read(birdCallProvider.notifier).play(speciesName, scientificName);
      }
    }

    if (compact) return _CompactButton(
      isPlaying: isPlaying,
      isLoading: isLoading,
      isError: isError,
      onTap: onTap,
    );

    return _FullButton(
      isPlaying: isPlaying,
      isLoading: isLoading,
      isError: isError,
      onTap: onTap,
    );
  }
}

// ── Pełny przycisk (detail screen) ────────────────────────────────────────

class _FullButton extends StatelessWidget {
  final bool isPlaying, isLoading, isError;
  final VoidCallback onTap;
  const _FullButton({
    required this.isPlaying, required this.isLoading,
    required this.isError, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPlaying
            ? AppTheme.primary
            : AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPlaying
              ? AppTheme.primary
              : AppTheme.primaryPale,
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (isLoading)
          const SizedBox(
            width: 12, height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppTheme.primary,
            ),
          )
        else if (isError)
          const Icon(Icons.error_outline,
              size: 14, color: AppTheme.primaryDark)
        else
          Icon(
            isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
            size: 14,
            color: isPlaying ? Colors.white : AppTheme.primary,
          ),
        const SizedBox(width: 6),
        Text(
          isLoading ? 'Szukam...'
              : isError ? 'Brak nagrania'
              : isPlaying ? 'Zatrzymaj'
              : 'Odtwórz śpiew',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isPlaying ? Colors.white : AppTheme.primaryDark,
          ),
        ),
      ]),
    ),
  );
}

// ── Kompaktowy przycisk (karta) ────────────────────────────────────────────

class _CompactButton extends StatelessWidget {
  final bool isPlaying, isLoading, isError;
  final VoidCallback onTap;
  const _CompactButton({
    required this.isPlaying, required this.isLoading,
    required this.isError, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isPlaying
            ? Colors.white.withOpacity(0.3)
            : Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30),
      ),
      child: isLoading
          ? const SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5, color: Colors.white,
              ),
            )
          : Icon(
              isError
                  ? Icons.error_outline
                  : isPlaying
                      ? Icons.stop_rounded
                      : Icons.volume_up_rounded,
              size: 14,
              color: Colors.white,
            ),
    ),
  );
}
