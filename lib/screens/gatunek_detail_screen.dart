import 'package:flutter/material.dart';
import 'package:bird_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/bird_biology.dart';
import '../models/species_summary.dart';
import '../providers/locale_provider.dart';
import '../providers/species_detail_provider.dart';
import '../providers/species_trend_provider.dart';
import '../providers/story_provider.dart';
import '../theme.dart';
import '../widgets/bird_call_button.dart';
import '../widgets/trend_line_chart.dart';

class GatunekDetailScreen extends ConsumerStatefulWidget {
  final SpeciesSummary species;
  const GatunekDetailScreen({required this.species, super.key});

  @override
  ConsumerState<GatunekDetailScreen> createState() =>
      _GatunekDetailScreenState();
}

class _GatunekDetailScreenState
    extends ConsumerState<GatunekDetailScreen> {
  bool _bioExpanded = false;

  String _shortDate(String isoDate, String lang) {
    final dt = DateTime.parse(isoDate).toLocal();
    const mPl = ['','sty','lut','mar','kwi','maj','cze',
                  'lip','sie','wrz','paź','lis','gru'];
    const mEn = ['','Jan','Feb','Mar','Apr','May','Jun',
                  'Jul','Aug','Sep','Oct','Nov','Dec'];
    final m = lang == 'pl' ? mPl : mEn;
    return '${dt.day} ${m[dt.month]}';
  }

  String _fallbackStory(BirdBiology? bio) {
    final name = bio?.polishName ?? widget.species.name;
    final v    = widget.species.visits;
    if (v >= 50) return '$name to jeden z twoich stałych gości — $v wizyt.';
    if (v >= 10) return '$name regularnie odwiedza ogród ($v wizyt).';
    return '$name zawitał do twojego ogrodu $v ${v == 1 ? 'raz' : 'razy'}.';
  }

  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context)!;
    final bio         = kBirdBiology[widget.species.name];
    final lang        = ref.watch(localeProvider).languageCode;
    final story       = ref.watch(storyProvider((widget.species.name, lang)));
    final detailState = ref.watch(speciesDetailProvider(widget.species.name));

    // Nazwa w odpowiednim języku
    final displayName = lang == 'pl'
        ? (bio?.polishName ?? widget.species.name)
        : widget.species.name;

    // Tytuł z właściwym rodzajem gramatycznym
    final title = (lang == 'pl' && bio?.gender == 'f')
        ? l10n.yourSpeciesFem(displayName)
        : l10n.yourSpecies(displayName);

    final freqLabel = switch (widget.species.starRating) {
      1 => l10n.freq1, 2 => l10n.freq2, 3 => l10n.freq3,
      4 => l10n.freq4, _ => l10n.freq5,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Title + stars ──────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(children: List.generate(5, (i) => Icon(
                            i < widget.species.starRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 17,
                            color: i < widget.species.starRating
                                ? AppTheme.primary
                                : AppTheme.primaryPale,
                          ))),
                          const SizedBox(height: 2),
                          Text(freqLabel, style: const TextStyle(
                              fontSize: 10, color: AppTheme.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Stats ──────────────────────────────────────────
                  Row(children: [
                    _StatBox(value: '${widget.species.visits}',
                        label: l10n.visitsLabel),
                    const SizedBox(width: 6),
                    _StatBox(value: widget.species.favoriteHour,
                        label: l10n.favTimeLabel),
                    const SizedBox(width: 6),
                    _StatBox(value: '${widget.species.daysInGarden}d',
                        label: l10n.daysLabel),
                  ]),
                  const SizedBox(height: 16),

                  // ── Wykres 24h ─────────────────────────────────────
                  Text(l10n.chartHourlyTitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  detailState.when(
                    loading: () => Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (detail) =>
                        _HourlyChart(histogram: detail.hourlyHistogram),
                  ),

                  // ── Trend 7 dni ────────────────────────────────────
                  const SizedBox(height: 14),
                  Text(l10n.trendTitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  ref.watch(speciesTrendProvider(widget.species.name)).when(
                    loading: () => Container(
                      height: 80,
                      decoration: BoxDecoration(
                          color: AppTheme.bgSecondary,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (counts) {
                      final now    = DateTime.now();
                      final labels = List.generate(7, (i) {
                        final d = now.subtract(Duration(days: 6 - i));
                        if (i == 6) return lang == 'pl' ? 'Dziś' : 'Today';
                        return '${d.day}/${d.month}';
                      });
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: TrendLineChart(data: counts, labels: labels, height: 60),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Story card ─────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.auto_awesome,
                              size: 14, color: AppTheme.primary),
                          const SizedBox(width: 6),
                          Text(l10n.storyCardTitle,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryDark)),
                          const Spacer(),
                          story.when(
                            loading: () =>
                                _SmallBadge(text: l10n.storyGenerating),
                            error: (_, __) =>
                                _SmallBadge(text: l10n.aiPlaceholderLabel),
                            data: (data) => _SmallBadge(
                                text: l10n.aiGeneratedOn(
                                    _shortDate(
                                        data['generated_at'] as String,
                                        lang))),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        story.when(
                          loading: () => const _StoryShimmer(),
                          error: (_, __) => Text(_fallbackStory(bio),
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primaryDark,
                                  height: 1.55)),
                          data: (data) => Text(
                              data['story'] as String? ?? '',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.primaryDark,
                                  height: 1.55)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Photos ─────────────────────────────────────────
                  Text(l10n.photosTitle, style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  _PhotoGrid(noPhotosLabel: l10n.noPhotosYet),
                  const SizedBox(height: 16),

                  // ── Biology ────────────────────────────────────────
                  if (bio != null)
                    _BiologyAccordion(
                      bio: bio,
                      l10n: l10n,
                      lang: lang,
                      expanded: _bioExpanded,
                      onToggle: () =>
                          setState(() => _bioExpanded = !_bioExpanded),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 24h chart ──────────────────────────────────────────────────────────────

class _HourlyChart extends StatelessWidget {
  final List<int> histogram;
  const _HourlyChart({required this.histogram});

  Color _barColor(double ratio) {
    if (ratio == 0)   return AppTheme.primaryLight;
    if (ratio < 0.35) return AppTheme.primaryPale;
    if (ratio < 0.70) return AppTheme.primaryMid;
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final max = histogram.fold(0, (m, v) => v > m ? v : m).clamp(1, 9999);
    return Column(children: [
      SizedBox(
        height: 44,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(24, (h) {
            final ratio = histogram[h] / max;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0.5),
                height: (ratio * 44).clamp(2, 44),
                decoration: BoxDecoration(
                  color: _barColor(ratio),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ),
      const SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ['0', '6', '12', '18', '24'].map((h) =>
          Text(h, style: const TextStyle(
              fontSize: 9, color: AppTheme.textTertiary)),
        ).toList(),
      ),
    ]);
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
      Center(child: Icon(Icons.camera_alt_outlined, size: 52,
          color: Colors.white.withAlpha(60))),
      Positioned(
        bottom: 10, right: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              borderRadius: BorderRadius.circular(6)),
          child: const Text('foto po instalacji kamery',
              style: TextStyle(fontSize: 10, color: Colors.white70)),
        ),
      ),
    ]),
  );
}

// ── Story shimmer ──────────────────────────────────────────────────────────

class _StoryShimmer extends StatefulWidget {
  const _StoryShimmer();
  @override
  State<_StoryShimmer> createState() => _StoryShimmerState();
}

class _StoryShimmerState extends State<_StoryShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.25, end: 0.75)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [100, 140, 120, 90].map((w) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Container(
          height: 11, width: w.toDouble(),
          decoration: BoxDecoration(
            color: AppTheme.primaryPale.withOpacity(_anim.value),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      )).toList(),
    ),
  );
}

// ── Small badge ────────────────────────────────────────────────────────────

class _SmallBadge extends StatelessWidget {
  final String text;
  const _SmallBadge({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
        color: AppTheme.primaryPale, borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: const TextStyle(
        fontSize: 8, color: AppTheme.primaryDark)),
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
          borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(value, style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(
            fontSize: 10, color: AppTheme.textSecondary),
            textAlign: TextAlign.center),
      ]),
    ),
  );
}

// ── Photo grid ─────────────────────────────────────────────────────────────

class _PhotoGrid extends StatelessWidget {
  final String noPhotosLabel;
  const _PhotoGrid({required this.noPhotosLabel});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: AppTheme.bgSecondary, borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.photo_library_outlined,
          size: 20, color: AppTheme.textTertiary),
      const SizedBox(width: 8),
      Text(noPhotosLabel, style: const TextStyle(
          fontSize: 12, color: AppTheme.textTertiary)),
    ]),
  );
}

// ── Biology accordion ──────────────────────────────────────────────────────

class _BiologyAccordion extends StatelessWidget {
  final BirdBiology bio;
  final AppLocalizations l10n;
  final String lang;
  final bool expanded;
  final VoidCallback onToggle;

  const _BiologyAccordion({
    required this.bio,
    required this.l10n,
    required this.lang,
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
          Text(l10n.biologyTitle, style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 18, color: AppTheme.textSecondary,
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
          _BioRow(label: l10n.sizeLabel, value: bio.size),
          _BioRow(
            label: l10n.dietLabel,
            value: lang == 'pl' ? bio.diet : bio.dietEn,
          ),
          _BioRow(
            label: l10n.breedingLabel,
            value: lang == 'pl' ? bio.breeding : bio.breedingEn,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.voiceLabel,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                BirdCallButton(
                  speciesName: bio.scientificName,
                  scientificName: bio.scientificName,
                ),
              ],
            ),
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
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(
          fontSize: 12, color: AppTheme.textSecondary)),
      Text(value, style: TextStyle(
          fontSize: 12,
          color: valueColor ?? AppTheme.textPrimary,
          fontWeight: valueColor != null
              ? FontWeight.w500
              : FontWeight.normal)),
    ]),
  );
}