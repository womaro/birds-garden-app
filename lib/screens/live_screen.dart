import 'package:flutter/material.dart';
import 'package:bird_app/l10n/app_localizations.dart';
import '../theme.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(l10n.tabLive,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                        color: Colors.grey, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(l10n.offline,
                      style: const TextStyle(fontSize: 10)),
                ]),
              ),
            ]),
            const SizedBox(height: 40),
            Center(
              child: Column(children: [
                const Icon(Icons.videocam_outlined,
                    size: 64, color: AppTheme.primaryPale),
                const SizedBox(height: 12),
                Text(l10n.cameraOffline,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(l10n.cameraInstallNote,
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