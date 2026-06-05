import 'package:flutter/material.dart';
import 'package:bird_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/bird_biology.dart';
import '../data/card_data.dart';
import '../models/species_summary.dart';
import '../providers/locale_provider.dart';
import '../providers/species_provider.dart';
import '../theme.dart';
import '../widgets/bird_card.dart';
import '../widgets/expanded_cards_view.dart';

class GatunkiScreen extends ConsumerStatefulWidget {
  const GatunkiScreen({super.key});

  @override
  ConsumerState<GatunkiScreen> createState() => _GatunkiScreenState();
}

class _GatunkiScreenState extends ConsumerState<GatunkiScreen> {
  String _query    = '';
  bool _isCardView = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(speciesProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context)!;
    final lang  = ref.watch(localeProvider).languageCode;
    final state = ref.watch(speciesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.tabSpecies, style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _ToggleBtn(icon: Icons.view_list,
                          active: !_isCardView,
                          onTap: () => setState(() => _isCardView = false)),
                      _ToggleBtn(icon: Icons.grid_view,
                          active: _isCardView,
                          onTap: () => setState(() => _isCardView = true)),
                    ]),
                  ),
                ],
              ),
              if (_isCardView)
                state.maybeWhen(
                  data: (species) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      lang == 'pl'
                          ? '${species.length} / ${kAllPolishGardenBirds.length} odkrytych gatunków'
                          : '${species.length} / ${kAllPolishGardenBirds.length} species discovered',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                )
              else ...[
                const SizedBox(height: 2),
                Text(l10n.speciesDescription, style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
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
              ],
            ]),
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (e, _) => Center(child: Text('$e')),
              data: (species) => _isCardView
                  ? _CardGrid(
                      detectedSpecies: species,
                      onDetailTap: (s) =>
                          context.push('/gatunki/detail', extra: s),
                    )
                  : _SpeciesList(
                      species: species, lang: lang, query: _query,
                      l10n: l10n,
                      onTap: (s) =>
                          context.push('/gatunki/detail', extra: s),
                      onRefresh: () async =>
                          ref.read(speciesProvider.notifier).load(),
                    ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ToggleBtn(
      {required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 18,
          color: active ? Colors.white : AppTheme.textSecondary),
    ),
  );
}

class _CardGrid extends StatelessWidget {
  final List<SpeciesSummary> detectedSpecies;
  final void Function(SpeciesSummary) onDetailTap;
  const _CardGrid({
    required this.detectedSpecies,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final summaryMap = {for (final s in detectedSpecies) s.name: s};
    final all =
        kAllPolishGardenBirds.where((n) => summaryMap.containsKey(n)).toList();

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: all.length,
      itemBuilder: (_, i) {
        final name = all[i];
        return GestureDetector(
          onDoubleTap: () => Navigator.push(
            context,
            ExpandedCardsRoute(
              initialIndex: i,
              cards: all,
              summaryMap: summaryMap,
            ),
          ),
          child: BirdCard(
            speciesName: name,
            summary: summaryMap[name],
            onDetailTap: summaryMap[name] != null
                ? () => onDetailTap(summaryMap[name]!)
                : null,
          ),
        );
      },
    );
  }
}

class _SpeciesList extends StatelessWidget {
  final List<SpeciesSummary> species;
  final String lang;
  final String query;
  final AppLocalizations l10n;
  final void Function(SpeciesSummary) onTap;
  final Future<void> Function() onRefresh;
  const _SpeciesList({
    required this.species, required this.lang, required this.query,
    required this.l10n, required this.onTap, required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = query.isEmpty
        ? species
        : species.where((s) {
            final bio = kBirdBiology[s.name];
            return (bio?.polishName ?? '').toLowerCase()
                    .contains(query.toLowerCase()) ||
                s.name.toLowerCase().contains(query.toLowerCase());
          }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.search_off, size: 48, color: AppTheme.textTertiary),
          const SizedBox(height: 12),
          Text(query.isNotEmpty ? 'Brak wyników' : l10n.noSpeciesYet,
              style: const TextStyle(color: AppTheme.textSecondary)),
        ]),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: onRefresh,
      child: ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final s           = filtered[i];
        final bio         = kBirdBiology[s.name];
        final displayName = lang == 'pl'
            ? (bio?.polishName ?? s.name) : s.name;
        final diff     = DateTime.now().difference(s.lastSeen);
        final lastSeen = diff.inMinutes < 60
            ? l10n.timeMinAgo(diff.inMinutes)
            : diff.inHours < 24
                ? l10n.timeHoursAgo(diff.inHours)
                : DateFormat('d MMM').format(s.lastSeen);

        return GestureDetector(
          onTap: () => onTap(s),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Container(
                width: 4, height: 36,
                decoration: BoxDecoration(
                  color: bio != null
                      ? familyGradient(bio.family).first
                      : AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(displayName, style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
                Text('${s.visits} ${l10n.visitsLabel} · $lastSeen',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ])),
              if (bio != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: kRarityColor[bio.cardRarity]!.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    lang == 'pl'
                        ? kRarityLabel[bio.cardRarity]!
                        : kRarityLabelEn[bio.cardRarity]!,
                    style: TextStyle(
                        fontSize: 9,
                        color: kRarityColor[bio.cardRarity],
                        fontWeight: FontWeight.w600),
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppTheme.textTertiary),
            ]),
          ),
        );
      },
      ),
    );
  }
}
