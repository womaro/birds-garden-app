import 'package:flutter/material.dart';
import 'package:bird_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../data/bird_biology.dart';
import '../models/species_summary.dart';
import '../theme.dart';

class GatunekDetailScreen extends StatefulWidget {
  final SpeciesSummary species;
  const GatunekDetailScreen({required this.species, super.key});

  @override
  State<GatunekDetailScreen> createState() => _GatunekDetailScreenState();
}

class _GatunekDetailScreenState extends State<GatunekDetailScreen> {
  bool _bioExpanded = false;

  String _storyText(BirdBiology? bio) {
    final name = bio?.polishName ?? widget.species.name;
    final h    = int.tryParse(widget.species.favoriteHour.split(':')[0]) ?? 8;
    final timeCtx = h <= 7  ? 'o świcie'
                  : h <= 10 ? 'rano'
                  : h >= 17 ? 'wieczorem'
                  : 'w ciągu dnia';
    final v = widget.species.visits;

    if (v >= 50) {
      return '$name to jeden z twoich stałych gości — $v wizyt od początku '
          'monitorowania. Zwykle pojawia się $timeCtx, około ${widget.species.favoriteHour}.';
    } else if (v >= 10) {
      return '$name regularnie odwiedza ogród ($v wizyt). '
          'Najchętniej przylatuje $timeCtx.';
    } else {
      return '$name zawitał do twojego ogrodu $v '
          '${v == 1 ? 'raz' : 'razy'}. '
          'Obserwuj o ${widget.species.favoriteHour} — '
          'wtedy bywa najaktywniejszy.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bio  = kBirdBiology[widget.species.name];
    final displayName = bio?.polishName ?? widget.species.name;

    final freqLabel = switch (widget.species.starRating) {
      1 => l10n.freq1,
      2 => l10n.freq2,
      3 => l10n.freq3,
      4 => l10n.freq4,
      _ => l10n.freq5,
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.bgSecondary,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _PhotoHeader(species: widget.species),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Title + stars
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.yourSpecies(displayName),
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      if (bio != null) ...[
                        const SizedBox(height: 2),
                        Text(bio.scientificName,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                fontStyle: FontStyle.italic)),
                      ],
                    ],
                  )),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < widget.species.starRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 17,
                        color: i < widget.species.starRating
                            ? AppTheme.primary
                            : AppTheme.primaryPale,
                      )),
                    ),
                    const SizedBox(height: 2),
                    Text(freqLabel,
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textTertiary)),
                  ]),
                ]),
                const SizedBox(height: 16),

                // Stats
                Row(children: [
                  _StatBox(value: '${widget.species.visits}', label: l10n.visitsLabel),
                  const SizedBox(width: 6),
                  _StatBox(value: widget.species.favoriteHour, label: l10n.favTimeLabel),
                  const SizedBox(width: 6),
                  _StatBox(value: '${widget.species.daysInGarden}d', label: l10n.daysLabel),
                ]),
                const SizedBox(height: 16),

                // Story card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 14, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(l10n.storyCardTitle,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryDark)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPale,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(l10n.aiPlaceholderLabel,
                            style: const TextStyle(
                                fontSize: 8, color: AppTheme.primaryDark)),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Text(_storyText(bio),
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryDark,
                            height: 1.55)),
                  ]),
                ),
                const SizedBox(height: 16),

                // Photos
                Text(l10n.photosTitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                _PhotoGrid(noPhotosLabel: l10n.noPhotosYet),
                const SizedBox(height: 16),

                // Biology
                if (bio != null)
                  _BiologyAccordion(
                    bio: bio,
                    l10n: l10n,
                    expanded: _bioExpanded,
                    onToggle: () =>
                        setState(() => _bioExpanded = !_bioExpanded),
                  ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photo header ───────────────────────────────────────────────────────────

class _PhotoHeader extends StatelessWidget {
  final SpeciesSummary species;
  const _PhotoHeader({required this.species});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1D9E75), Color(0xFF085041)],
      ),
    ),
    child: Stack(children: [
      Center(
        child: Icon(Icons.camera_alt_outlined,
            size: 52, color: Colors.white.withAlpha(60)),
      ),
      Positioned(
        bottom: 10, right: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(100),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text('foto po instalacji kamery',
              style: TextStyle(fontSize: 10, color: Colors.white70)),
        ),
      ),
    ]),
  );
}

// ── Stat box ───────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String value, label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppTheme.textSecondary),
            textAlign: TextAlign.center),
      ]),
    ),
  );
}

// ── Photo grid placeholder ─────────────────────────────────────────────────

class _PhotoGrid extends StatelessWidget {
  final String noPhotosLabel;
  const _PhotoGrid({required this.noPhotosLabel});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.bgSecondary,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.photo_library_outlined,
          size: 20, color: AppTheme.textTertiary),
      const SizedBox(width: 8),
      Text(noPhotosLabel,
          style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
    ]),
  );
}

// ── Biology accordion ──────────────────────────────────────────────────────

class _BiologyAccordion extends StatelessWidget {
  final BirdBiology bio;
  final AppLocalizations l10n;
  final bool expanded;
  final VoidCallback onToggle;
  const _BiologyAccordion({
    required this.bio,
    required this.l10n,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
    GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: expanded
              ? const BorderRadius.vertical(top: Radius.circular(10))
              : BorderRadius.circular(10),
          border: Border.all(color: const Color(0x1F000000)),
        ),
        child: Row(children: [
          Text(l10n.biologyTitle,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          Icon(
            expanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            size: 18,
            color: AppTheme.textSecondary,
          ),
        ]),
      ),
    ),
    if (expanded)
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
          border: Border(
            left:   BorderSide(color: Color(0x1F000000)),
            right:  BorderSide(color: Color(0x1F000000)),
            bottom: BorderSide(color: Color(0x1F000000)),
          ),
        ),
        child: Column(children: [
          _BioRow(label: l10n.sizeLabel,     value: bio.size),
          _BioRow(label: l10n.dietLabel,     value: bio.diet),
          _BioRow(label: l10n.breedingLabel, value: bio.breeding),
          _BioRow(
            label: l10n.voiceLabel,
            value: l10n.playCallButton,
            valueColor: AppTheme.primary,
            isLast: true,
          ),
        ]),
      ),
  ]);
}

class _BioRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool isLast;
  const _BioRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: isLast
        ? null
        : const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0x0F000000)))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
        Text(value,
            style: TextStyle(
              fontSize: 12,
              color: valueColor ?? AppTheme.textPrimary,
              fontWeight:
                  valueColor != null ? FontWeight.w500 : FontWeight.normal,
            )),
      ],
    ),
  );
}