import 'package:flutter/material.dart';
import 'package:bird_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/detection.dart';
import '../providers/detections_provider.dart';
import '../providers/locale_provider.dart';
import '../theme.dart';

enum _Status { active, moderate, quiet }

class OgrodScreen extends ConsumerWidget {
  const OgrodScreen({super.key});

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
          error: (e, _) => Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.wifi_off, size: 48, color: AppTheme.textTertiary),
              const SizedBox(height: 8),
              Text(l10n.noConnection,
                  style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(detectionsProvider.notifier).refresh(),
                child: Text(l10n.tryAgain),
              ),
            ]),
          ),
          data: (detections) => RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async {
              ref.read(detectionsProvider.notifier).refresh();
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: _OgrodContent(detections: detections),
          ),
        ),
      ),
    );
  }
}

// ── Content ────────────────────────────────────────────────────────────────

class _OgrodContent extends ConsumerWidget {
  final List<Detection> detections;
  const _OgrodContent({required this.detections});

  _Status get _status {
    if (detections.isEmpty) return _Status.quiet;
    final diff = DateTime.now().difference(detections.first.timestamp);
    if (diff.inMinutes < 15) return _Status.active;
    if (diff.inMinutes < 60) return _Status.moderate;
    return _Status.quiet;
  }

  List<Detection> get _today {
    final now = DateTime.now();
    return detections.where((d) =>
      d.timestamp.year == now.year &&
      d.timestamp.month == now.month &&
      d.timestamp.day == now.day).toList();
  }

  List<int> get _bars {
    final now = DateTime.now();
    return List.generate(8, (i) {
      final h = now.hour - 7 + i;
      return detections.where((d) =>
        d.timestamp.day == now.day && d.timestamp.hour == h).length;
    });
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final l10n     = AppLocalizations.of(context)!;
    final notifier = ref.read(localeProvider.notifier);
    final current  = ref.read(localeProvider).languageCode;

    showModalBottomSheet(
      context: context,
      builder: (sheet) {
        final labels = {'pl': l10n.langPolish, 'en': l10n.langEnglish};
        final flags  = {'pl': '🇵🇱', 'en': '🇬🇧'};
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.settingsLanguage,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ...supportedLocales.map((locale) => ListTile(
              leading: Text(flags[locale.languageCode] ?? '',
                  style: const TextStyle(fontSize: 24)),
              title: Text(labels[locale.languageCode] ?? locale.languageCode),
              trailing: current == locale.languageCode
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                notifier.setLocale(locale);
                Navigator.pop(sheet);
              },
            )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n   = AppLocalizations.of(context)!;
    final today  = _today;
    final bars   = _bars;
    final maxBar = bars.fold(0, (m, v) => v > m ? v : m).clamp(1, 9999);
    final recent = detections.take(3).toList();
    final isLearning = detections.length < 10;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.appTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            IconButton(
              icon: const Icon(Icons.settings_outlined, size: 20,
                  color: AppTheme.textSecondary),
              onPressed: () => _showLanguagePicker(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _StatusCard(status: _status, detections: detections, isLearning: isLearning),
        const SizedBox(height: 12),

        Row(children: [
          Expanded(child: _StatTile(
            label: l10n.speciesCount,
            value: today.map((d) => d.species).toSet().length.toString(),
          )),
          const SizedBox(width: 8),
          Expanded(child: _StatTile(label: l10n.visitsCount, value: today.length.toString())),
        ]),
        const SizedBox(height: 14),

        Text(l10n.activityChart,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        SizedBox(height: 44, child: _ActivityChart(bars: bars, maxBar: maxBar)),
        const SizedBox(height: 14),

        if (recent.isNotEmpty) ...[
          Text(l10n.recentDetections,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          ...recent.map((d) => _DetectionRow(detection: d)),
        ] else
          _EmptyHint(),
      ],
    );
  }
}

// ── Status card ────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final _Status status;
  final List<Detection> detections;
  final bool isLearning;
  const _StatusCard({
    required this.status,
    required this.detections,
    required this.isLearning,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLearning) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryPale),
        ),
        child: Row(children: [
          const Icon(Icons.auto_awesome, color: AppTheme.primaryMid, size: 28),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.learningTitle,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDark)),
            Text(l10n.learningSubtitle(detections.length),
                style: const TextStyle(fontSize: 11, color: AppTheme.primary)),
          ])),
        ]),
      );
    }

    final (bg, iconBg, titleColor, title, sub) = switch (status) {
      _Status.active => (
          AppTheme.primaryLight, AppTheme.primaryPale, AppTheme.primaryDark,
          l10n.statusActive,
          detections.isNotEmpty
              ? l10n.statusActiveSub(detections.first.species)
              : '',
        ),
      _Status.moderate => (
          const Color(0xFFFFF8E7), const Color(0xFFFFE9A0), const Color(0xFF7A5C00),
          l10n.statusModerate,
          l10n.statusModerateSub,
        ),
      _Status.quiet => (
          const Color(0xFFF0F0EE), const Color(0xFFDDDDD9), const Color(0xFF4A4A48),
          l10n.statusQuiet,
          l10n.statusQuietSub,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(Icons.park_outlined, color: titleColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: titleColor)),
            if (sub.isNotEmpty)
              Text(sub,
                  style: TextStyle(fontSize: 11, color: titleColor.withAlpha(180))),
          ])),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.primaryLight,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(l10n.goToGarden,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ),
      ]),
    );
  }
}

// ── Stat tile ──────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label, value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      const SizedBox(height: 2),
      Text(value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
    ]),
  );
}

// ── Activity chart ─────────────────────────────────────────────────────────

class _ActivityChart extends StatelessWidget {
  final List<int> bars;
  final int maxBar;
  const _ActivityChart({required this.bars, required this.maxBar});

  Color _color(double ratio) {
    if (ratio == 0)   return AppTheme.primaryLight;
    if (ratio < 0.35) return AppTheme.primaryPale;
    if (ratio < 0.70) return AppTheme.primaryMid;
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: bars.map((v) {
      final ratio = v / maxBar;
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: (ratio * 44).clamp(4, 44),
          decoration: BoxDecoration(
            color: _color(ratio),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
    }).toList(),
  );
}

// ── Detection row ──────────────────────────────────────────────────────────

class _DetectionRow extends StatelessWidget {
  final Detection detection;
  const _DetectionRow({required this.detection});

  static const _colors = [
    AppTheme.primary, AppTheme.primaryMid, AppTheme.primaryDark,
    Color(0xFF2E7D32), Color(0xFF388E3C),
  ];

  Color get _avatarColor =>
      _colors[detection.species.hashCode.abs() % _colors.length];

  String get _initials {
    final parts = detection.species.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return detection.species
        .substring(0, detection.species.length.clamp(0, 2))
        .toUpperCase();
  }

  String _relTime(AppLocalizations l10n) {
    final diff = DateTime.now().difference(detection.timestamp);
    if (diff.inMinutes < 1)  return l10n.timeNow;
    if (diff.inMinutes < 60) return l10n.timeMinAgo(diff.inMinutes);
    if (diff.inHours < 24)   return l10n.timeHoursAgo(diff.inHours);
    return DateFormat('HH:mm').format(detection.timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: _avatarColor,
          child: Text(_initials,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(detection.species,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(_relTime(l10n),
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('${(detection.confidence * 100).round()}%',
              style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ── Empty hint ─────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(children: [
          const Icon(Icons.forest_outlined, size: 48, color: AppTheme.textTertiary),
          const SizedBox(height: 8),
          Text(l10n.gardenSilent,
              style: const TextStyle(color: AppTheme.textSecondary)),
          Text(l10n.birdsComing,
              style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
        ]),
      ),
    );
  }
}