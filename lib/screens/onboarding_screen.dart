import 'package:flutter/material.dart';
import 'package:bird_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/locale_provider.dart';
import '../theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl       = PageController();
  final _gardenNameCtrl = TextEditingController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _gardenNameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 3) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final name  = _gardenNameCtrl.text.trim();
    await prefs.setBool('onboarding_done', true);
    await prefs.setString('garden_name', name.isEmpty ? 'Mój ogród' : name);
    if (mounted) context.go('/ogrod');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFirstPage = _currentPage == 0;

    return Scaffold(
      backgroundColor:
          isFirstPage ? AppTheme.primary : AppTheme.bgSecondary,
      body: SafeArea(
        child: Column(children: [
          // ── Header: dots + skip ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 56),
                Row(
                  children: List.generate(4, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width:  i == _currentPage ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isFirstPage
                          ? (i == _currentPage ? Colors.white : Colors.white38)
                          : (i == _currentPage
                              ? AppTheme.primary
                              : AppTheme.primaryPale),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                SizedBox(
                  width: 56,
                  child: _currentPage < 3
                      ? TextButton(
                          onPressed: _complete,
                          child: Text(
                            l10n.onboardingSkip,
                            style: TextStyle(
                              fontSize: 13,
                              color: isFirstPage
                                  ? Colors.white70
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),

          // ── Pages ────────────────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (p) => setState(() => _currentPage = p),
              children: [
                _Page1(l10n: l10n),
                _Page2(l10n: l10n),
                _Page3(l10n: l10n, ctrl: _gardenNameCtrl),
                _Page4(l10n: l10n),
              ],
            ),
          ),

          // ── Bottom button ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            child: _currentPage < 3
                ? Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFirstPage
                            ? Colors.white
                            : AppTheme.primary,
                        foregroundColor: isFirstPage
                            ? AppTheme.primary
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(l10n.onboardingNext),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 16),
                      ]),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _complete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(l10n.onboardingGetStarted,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}

// ── Page 1 — Welcome ───────────────────────────────────────────────────────

class _Page1 extends StatelessWidget {
  final AppLocalizations l10n;
  const _Page1({required this.l10n});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 96, height: 96,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.park, size: 52, color: Colors.white),
        ),
        const SizedBox(height: 32),
        const Text('birds.garden',
            style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5)),
        const SizedBox(height: 16),
        Text(l10n.onboarding1Title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white)),
        const SizedBox(height: 12),
        Text(l10n.onboarding1Subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15, color: Colors.white70, height: 1.55)),
      ],
    ),
  );
}

// ── Page 2 — What you'll see ───────────────────────────────────────────────

class _Page2 extends StatelessWidget {
  final AppLocalizations l10n;
  const _Page2({required this.l10n});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.onboarding2Title,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(l10n.onboarding2Subtitle,
            style: const TextStyle(
                fontSize: 15, color: AppTheme.textSecondary)),
        const SizedBox(height: 28),
        _FeatureCard(
          icon: Icons.home_rounded,
          title: l10n.tabGarden,
          description: l10n.onboarding2Ogrod,
        ),
        const SizedBox(height: 10),
        _FeatureCard(
          icon: Icons.bar_chart_rounded,
          title: l10n.tabActivity,
          description: l10n.onboarding2Aktywnosc,
        ),
        const SizedBox(height: 10),
        _FeatureCard(
          icon: Icons.star_rounded,
          title: l10n.tabSpecies,
          description: l10n.onboarding2Gatunki,
        ),
      ],
    ),
  );
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(description, style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary)),
        ],
      )),
    ]),
  );
}

// ── Page 3 — Garden name ───────────────────────────────────────────────────

class _Page3 extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController ctrl;
  const _Page3({required this.l10n, required this.ctrl});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Icon(Icons.yard_outlined, size: 72, color: AppTheme.primary),
        ),
        const SizedBox(height: 32),
        Text(l10n.onboarding3Title,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(l10n.onboarding3Subtitle,
            style: const TextStyle(
                fontSize: 15, color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        TextField(
          controller: ctrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: l10n.onboarding3Hint,
            hintStyle: const TextStyle(color: AppTheme.textTertiary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),
        Text(l10n.onboarding3Note,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textTertiary)),
      ],
    ),
  );
}

// ── Page 4 — Setup ────────────────────────────────────────────────────────

class _Page4 extends StatelessWidget {
  final AppLocalizations l10n;
  const _Page4({required this.l10n});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.onboarding4Title,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(l10n.onboarding4Subtitle,
            style: const TextStyle(
                fontSize: 15, color: AppTheme.textSecondary)),
        const SizedBox(height: 28),
        _SetupStep(
          icon: Icons.memory,
          title: 'Raspberry Pi Zero 2W',
          subtitle: l10n.onboarding4Step1Sub,
        ),
        const SizedBox(height: 10),
        _SetupStep(
          icon: Icons.videocam_rounded,
          title: 'Reolink RLC-811WA',
          subtitle: l10n.onboarding4Step2Sub,
        ),
        const SizedBox(height: 10),
        _SetupStep(
          icon: Icons.wifi,
          title: 'WiFi',
          subtitle: l10n.onboarding4Step3Sub,
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline,
                size: 18, color: AppTheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(l10n.onboarding4Demo,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryDark,
                      height: 1.4)),
            ),
          ]),
        ),
      ],
    ),
  );
}

class _SetupStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SetupStep({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500)),
          Text(subtitle, style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary)),
        ],
      )),
      const Icon(Icons.check_circle_outline,
          color: AppTheme.primaryMid, size: 20),
    ]),
  );
}
