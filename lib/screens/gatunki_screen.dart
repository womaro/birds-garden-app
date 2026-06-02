import 'package:flutter/material.dart';
import 'package:bird_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/bird_biology.dart';
import '../models/species_summary.dart';
import '../providers/species_provider.dart';
import '../theme.dart';

class GatunkiScreen extends ConsumerStatefulWidget {
  const GatunkiScreen({super.key});

  @override
  ConsumerState<GatunkiScreen> createState() => _GatunkiScreenState();
}

class _GatunkiScreenState extends ConsumerState<GatunkiScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(speciesProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context)!;
    final state = ref.watch(speciesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.tabSpecies,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(l10n.speciesDescription,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: const TextStyle(
                      fontSize: 13, color: AppTheme.textTertiary),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: AppTheme.textTertiary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ]),
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
              error: (e, _) => Center(child: Text('$e')),
              data: (species) {
                final filtered = _query.isEmpty
                    ? species
                    : species.where((s) {
                        final bio = kBirdBiology[s.name];
                        return (bio?.polishName ?? s.name)
                                .toLowerCase()
                                .contains(_query.toLowerCase()) ||
                            s.name
                                .toLowerCase()
                                .contains(_query.toLowerCase());
                      }).toList();

                if (filtered.isEmpty) {
                  return _EmptyState(
                      l10n: l10n, hasQuery: _query.isNotEmpty);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _SpeciesRow(
                    summary: filtered[i],
                    onTap: () => context.push(
                      '/gatunki/detail',
                      extra: filtered[i],
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Species row ────────────────────────────────────────────────────────────

class _SpeciesRow extends StatelessWidget {
  final SpeciesSummary summary;
  final VoidCallback onTap;
  const _SpeciesRow({required this.summary, required this.onTap});

  static const _colors = [
    AppTheme.primary, AppTheme.primaryMid, AppTheme.primaryDark,
    Color(0xFF2E7D32), Color(0xFF1565C0),
    Color(0xFF6A1B9A), Color(0xFFD84315), Color(0xFF00695C),
  ];

  Color get _avatarColor =>
      _colors[summary.name.hashCode.abs() % _colors.length];

  String get _initials {
    final bio  = kBirdBiology[summary.name];
    final name = bio?.polishName ?? summary.name;
    final parts = name.split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  String _lastSeen(AppLocalizations l10n) {
    final diff = DateTime.now().difference(summary.lastSeen);
    if (diff.inMinutes < 1)  return l10n.timeNow;
    if (diff.inMinutes < 60) return l10n.timeMinAgo(diff.inMinutes);
    if (diff.inHours < 24)   return l10n.timeHoursAgo(diff.inHours);
    return DateFormat('d MMM').format(summary.lastSeen);
  }

  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context)!;
    final bio         = kBirdBiology[summary.name];
    final displayName = bio?.polishName ?? summary.name;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _avatarColor,
            child: Text(_initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(displayName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ),
              if (summary.isRare)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(l10n.rareBadge,
                      style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.w600)),
                ),
            ]),
            const SizedBox(height: 2),
            Text(
              '${summary.visits} ${l10n.visitsLabel} · ${_lastSeen(l10n)}',
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary),
            ),
          ])),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
        ]),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final bool hasQuery;
  const _EmptyState({required this.l10n, required this.hasQuery});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.search_off, size: 48, color: AppTheme.textTertiary),
      const SizedBox(height: 12),
      Text(
        hasQuery ? 'Brak wyników' : l10n.noSpeciesYet,
        style: const TextStyle(
            fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
      ),
      const SizedBox(height: 4),
      if (!hasQuery)
        Text(l10n.noSpeciesSubtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
    ]),
  );
}