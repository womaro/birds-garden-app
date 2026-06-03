import 'package:flutter/material.dart';
import 'package:bird_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/locale_provider.dart';
import '../theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n        = AppLocalizations.of(context)!;
    final currentLang = ref.watch(localeProvider).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel(l10n.settingsLanguage),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: supportedLocales.asMap().entries.map((entry) {
                final idx    = entry.key;
                final locale = entry.value;
                final labels = {'pl': l10n.langPolish, 'en': l10n.langEnglish};
                final flags  = {'pl': '🇵🇱', 'en': '🇬🇧'};
                final isCurrent = currentLang == locale.languageCode;
                return Column(children: [
                  ListTile(
                    leading: Text(flags[locale.languageCode] ?? '',
                        style: const TextStyle(fontSize: 22)),
                    title: Text(
                        labels[locale.languageCode] ?? locale.languageCode,
                        style: const TextStyle(fontSize: 14)),
                    trailing: isCurrent
                        ? const Icon(Icons.check,
                            color: AppTheme.primary, size: 18)
                        : null,
                    onTap: () =>
                        ref.read(localeProvider.notifier).setLocale(locale),
                    dense: true,
                  ),
                  if (idx < supportedLocales.length - 1)
                    const Divider(height: 1, indent: 56),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel(l10n.settingsAbout),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.park, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.appTitle, style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
                Text('${l10n.settingsVersion} 1.0.0',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary));
}