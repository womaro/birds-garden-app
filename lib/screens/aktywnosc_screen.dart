import 'package:flutter/material.dart';
import 'package:bird_app/l10n/app_localizations.dart';
import '../theme.dart';

class AktywnoscScreen extends StatelessWidget {
  const AktywnoscScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.tabActivity,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 40),
            Center(
              child: Column(children: [
                const Icon(Icons.bar_chart, size: 64, color: AppTheme.primaryPale),
                const SizedBox(height: 12),
                Text(l10n.comingSoon,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(l10n.heatmapsAvailable,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}