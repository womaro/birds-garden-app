import 'package:flutter/material.dart';
import 'package:bird_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/bird_biology.dart';
import '../models/detection.dart';
import '../providers/detections_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/species_provider.dart';
import '../theme.dart';

// ── Time blocks ────────────────────────────────────────────────────────────

const _kBlocks = [
  (start: 5,  end: 8,  hours: '5–8'),
  (start: 8,  end: 11, hours: '8–11'),
  (start: 11, end: 14, hours: '11–14'),
  (start: 14, end: 17, hours: '14–17'),
  (start: 17, end: 20, hours: '17–20'),
];

// ── Screen ─────────────────────────────────────────────────────────────────

class AktywnoscScreen extends ConsumerWidget {
  const AktywnoscScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n  = AppLocalizations.of(context)!;
    final state = ref.watch(detectionsProvider);

    return Scaffold(
      body: SafeArea(
        child: state.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          error: (e, _) => Center(child: Text('$e')),
          data: (detections) => _AktywnoscContent(
            detections: detections,
            l10n: l10n,
          ),
        ),
      ),
    );
  }
}

// ── Content ────────────────────────────────────────────────────────────────

class _AktywnoscContent extends ConsumerWidget {
  final List<Detection> detections;
  final AppLocalizations l10n;
  const _AktywnoscContent({required this.detections, required this.l10n});

  List<List<int>> get _grid {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final grid  = List.generate(7, (_) => List.filled(5, 0));

    for (final d in detections) {
      final dayDiff = today
          .difference(DateTime(
              d.timestamp.year, d.timestamp.month, d.timestamp.day))
          .inDays;
      if (dayDiff < 0 || dayDiff >= 7) continue;

      final h = d.timestamp.hour;
      int b = -1;
      for (int i = 0; i < _kBlocks.length; i++) {
        if (h >= _kBlocks[i].start && h < _kBlocks[i].end) { b = i; break; }
      }
      if (b == -1) continue;
      grid[dayDiff][b]++;
    }
    return grid;
  }

  int get _maxCount =>
      _grid.expand((r) => r).fold(0, (m, v) => v > m ? v : m).clamp(1, 9999);

  int get _totalWeek =>
      _grid.expand((r) => r).fold(0, (a, b) => a + b);

  int get _mostActiveBlock {
    final totals = List.filled(5, 0);
    for (final row in _grid) {
      for (int b = 0; b < 5; b++) totals[b] += row[b];
    }
    int best = 0;
    for (int b = 1; b < 5; b++) {
      if (totals[b] > totals[best]) best = b;
    }
    return best;
  }

  Set<String> get _speciesThisWeek {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return detections
        .where((d) => today
            .difference(DateTime(
                d.timestamp.year, d.timestamp.month, d.timestamp.day))
            .inDays < 7)
        .map((d) => d.species)
        .toSet();
  }

  /// Gatunki + liczba detekcji dla konkretnego cell
  Map<String, int> _speciesForCell(int dayIdx, int blockIdx) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <String, int>{};

    for (final d in detections) {
      final dayDiff = today
          .difference(DateTime(
              d.timestamp.year, d.timestamp.month, d.timestamp.day))
          .inDays;
      if (dayDiff != dayIdx) continue;

      final h = d.timestamp.hour;
      if (h < _kBlocks[blockIdx].start || h >= _kBlocks[blockIdx].end) continue;

      result[d.species] = (result[d.species] ?? 0) + 1;
    }
    return result;
  }

  void _showDrillDown(BuildContext context, int dayIdx, int blockIdx) {
    final species = _speciesForCell(dayIdx, blockIdx);
    if (species.isEmpty) return;

    final sorted = species.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.first.value;
    final dayLabel = _dayLabel(dayIdx);
    final block    = _kBlocks[blockIdx];
    final blockLbl = _blockLabel(blockIdx);
    final total    = species.values.fold(0, (a, b) => a + b);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header
                Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$dayLabel · $blockLbl',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(block.hours,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.detectionsCount(total),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Species list
                ...sorted.map((e) {
                  final bio  = kBirdBiology[e.key];
                  final name = bio?.polishName ?? e.key;
                  final ratio = e.value / maxVal;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      // Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _avatarColor(e.key),
                        child: Text(_initials(name),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 10),

                      // Name + bar
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 3),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 5,
                              backgroundColor: AppTheme.primaryLight,
                              valueColor: const AlwaysStoppedAnimation(
                                  AppTheme.primary),
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(width: 10),

                      // Count badge
                      Container(
                        width: 28,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text('${e.value}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryDark)),
                      ),
                    ]),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _blockLabel(int idx) => switch (idx) {
        0 => l10n.blockDawn,
        1 => l10n.blockMorning,
        2 => l10n.blockMidday,
        3 => l10n.blockAfternoon,
        _ => l10n.blockEvening,
      };

  String _dayLabel(int daysAgo) {
    if (daysAgo == 0) return l10n.dayToday;
    if (daysAgo == 1) return l10n.dayYesterday;
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    return DateFormat('d MMM').format(date);
  }

  Color _cellColor(int count) {
    if (count == 0) return AppTheme.primaryLight;
    final ratio = count / _maxCount;
    if (ratio < 0.25) return AppTheme.primaryPale;
    if (ratio < 0.60) return AppTheme.primaryMid.withAlpha(200);
    return AppTheme.primary;
  }

  static const _colors = [
    AppTheme.primary, AppTheme.primaryMid, AppTheme.primaryDark,
    Color(0xFF2E7D32), Color(0xFF1565C0),
    Color(0xFF6A1B9A), Color(0xFFD84315), Color(0xFF00695C),
  ];

  Color _avatarColor(String species) =>
      _colors[species.hashCode.abs() % _colors.length];

  String _initials(String name) {
    final parts = name.split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grid    = _grid;
    final total   = _totalWeek;
    final bestBlk = _mostActiveBlock;
    final species = _speciesThisWeek;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.tabActivity,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),

        Text(l10n.heatmapTitle,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 10),

        if (total == 0)
          _EmptyHeatmap(label: l10n.noHeatmapData)
        else
          _HeatmapGrid(
            grid: grid,
            cellColor: _cellColor,
            blockLabel: _blockLabel,
            dayLabel: _dayLabel,
            onCellTap: (dayIdx, blockIdx) =>
                _showDrillDown(context, dayIdx, blockIdx),
            l10n: l10n,
          ),

        const SizedBox(height: 14),

        Row(children: [
          _SummaryTile(value: '$total', label: l10n.visitsThisWeek),
          const SizedBox(width: 8),
          _SummaryTile(
            value: _blockLabel(bestBlk),
            label: l10n.mostActiveTime,
            sub: _kBlocks[bestBlk].hours,
          ),
        ]),
        const SizedBox(height: 14),

        if (species.isNotEmpty) ...[
          Text(l10n.speciesThisWeek,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: species.map((s) {
              final bio  = kBirdBiology[s];
              final name = bio?.polishName ?? s;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(name,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.primaryDark)),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 14),

        // ── Ranking gatunków ──────────────────────────────────────────
        _SpeciesRanking(
          detections: detections,
          l10n: l10n,
        ),
      ],
    );
  }
}

// ── Heatmap grid ───────────────────────────────────────────────────────────

class _HeatmapGrid extends StatelessWidget {
  final List<List<int>> grid;
  final Color Function(int) cellColor;
  final String Function(int) blockLabel;
  final String Function(int) dayLabel;
  final void Function(int dayIdx, int blockIdx) onCellTap;
  final AppLocalizations l10n;

  const _HeatmapGrid({
    required this.grid,
    required this.cellColor,
    required this.blockLabel,
    required this.dayLabel,
    required this.onCellTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    const labelW = 52.0;
    const cellH  = 34.0;
    const gap    = 3.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Column headers
      Row(children: [
        const SizedBox(width: labelW),
        ...List.generate(5, (b) => Expanded(
          child: Column(children: [
            Text(blockLabel(b),
                style: const TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary),
                textAlign: TextAlign.center),
            Text(_kBlocks[b].hours,
                style: const TextStyle(
                    fontSize: 8, color: AppTheme.textTertiary),
                textAlign: TextAlign.center),
          ]),
        )),
      ]),
      const SizedBox(height: 6),

      // Rows
      ...List.generate(7, (dayIdx) => Padding(
        padding: const EdgeInsets.only(bottom: gap),
        child: Row(children: [
          SizedBox(
            width: labelW,
            child: Text(dayLabel(dayIdx),
                style: TextStyle(
                    fontSize: dayIdx <= 1 ? 11 : 10,
                    fontWeight: dayIdx == 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: dayIdx == 0
                        ? AppTheme.primary
                        : AppTheme.textSecondary),
                overflow: TextOverflow.ellipsis),
          ),
          ...List.generate(5, (b) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: gap / 2),
              child: _Cell(
                count: grid[dayIdx][b],
                color: cellColor(grid[dayIdx][b]),
                height: cellH,
                onTap: grid[dayIdx][b] > 0
                    ? () => onCellTap(dayIdx, b)
                    : null,
              ),
            ),
          )),
        ]),
      )),

      const SizedBox(height: 8),

      // Legend
      Row(children: [
        const SizedBox(width: labelW),
        Text(l10n.legendFew,
            style: const TextStyle(fontSize: 9, color: AppTheme.textTertiary)),
        const SizedBox(width: 4),
        ...[AppTheme.primaryLight, AppTheme.primaryPale,
            AppTheme.primaryMid,   AppTheme.primary]
            .map((c) => Container(
              width: 14, height: 10,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                  color: c, borderRadius: BorderRadius.circular(2)),
            )),
        const SizedBox(width: 4),
        Text(l10n.legendMany,
            style: const TextStyle(fontSize: 9, color: AppTheme.textTertiary)),
      ]),
    ]);
  }
}

// ── Tappable cell ──────────────────────────────────────────────────────────

class _Cell extends StatelessWidget {
  final int count;
  final Color color;
  final double height;
  final VoidCallback? onTap;

  const _Cell({
    required this.count,
    required this.color,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(4),
    child: InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Center(
          child: count > 0
              ? Text('$count',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: count > 2
                          ? Colors.white
                          : AppTheme.primaryDark))
              : null,
        ),
      ),
    ),
  );
}

// ── Empty ──────────────────────────────────────────────────────────────────

class _EmptyHeatmap extends StatelessWidget {
  final String label;
  const _EmptyHeatmap({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppTheme.bgSecondary,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: Text(label,
          style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary)),
    ),
  );
}

// ── Summary tile ───────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final String value, label;
  final String? sub;
  const _SummaryTile({required this.value, required this.label, this.sub});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary)),
        if (sub != null)
          Text(sub!,
              style: const TextStyle(
                  fontSize: 9, color: AppTheme.textTertiary)),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppTheme.textSecondary)),
      ]),
    ),
  );
}

// ── Species ranking ────────────────────────────────────────────────────────

class _SpeciesRanking extends ConsumerWidget {
  final List<Detection> detections;
  final AppLocalizations l10n;
  const _SpeciesRanking({required this.detections, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang         = ref.watch(localeProvider).languageCode;
    final speciesState = ref.watch(speciesProvider);

    return speciesState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (allSpecies) {
        final weekSpecies = allSpecies
            .where((s) => DateTime.now().difference(s.lastSeen).inDays < 7)
            .take(5)
            .toList();

        if (weekSpecies.isEmpty) return const SizedBox.shrink();

        final maxVisits = weekSpecies.first.visits.clamp(1, 9999);

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.rankingTitle,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: weekSpecies.asMap().entries.map((entry) {
                final idx = entry.key;
                final s   = entry.value;
                final bio = kBirdBiology[s.name];
                final displayName = lang == 'pl'
                    ? (bio?.polishName ?? s.name)
                    : s.name;
                final ratio = s.visits / maxVisits;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    SizedBox(
                      width: 20,
                      child: Text('${idx + 1}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: idx == 0
                                  ? AppTheme.primary
                                  : AppTheme.textTertiary)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(displayName,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Text('${s.visits}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary)),
                        ]),
                        const SizedBox(height: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 4,
                            backgroundColor: AppTheme.primaryLight,
                            valueColor: AlwaysStoppedAnimation(
                              idx == 0 ? AppTheme.primary : AppTheme.primaryMid,
                            ),
                          ),
                        ),
                      ],
                    )),
                  ]),
                );
              }).toList(),
            ),
          ),
        ]);
      },
    );
  }
}