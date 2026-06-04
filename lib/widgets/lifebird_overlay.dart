import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/bird_biology.dart';
import '../data/card_data.dart';
import '../providers/locale_provider.dart';
import '../theme.dart';

class LifebirdOverlay extends ConsumerStatefulWidget {
  final String speciesName;
  final VoidCallback onDismiss;
  const LifebirdOverlay({
    required this.speciesName,
    required this.onDismiss,
    super.key,
  });

  @override
  ConsumerState<LifebirdOverlay> createState() =>
      _LifebirdOverlayState();
}

class _LifebirdOverlayState extends ConsumerState<LifebirdOverlay>
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _bounceCtrl;
  late ConfettiController _confettiCtrl;

  late Animation<double> _bgAnim;
  late Animation<double> _titleSlide;
  late Animation<double> _cardScale;
  late Animation<double> _cardFade;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _confettiCtrl =
        ConfettiController(duration: const Duration(seconds: 3));

    _bgAnim = Tween(begin: 0.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween(begin: -60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _cardScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.4, 0.9, curve: Curves.elasticOut),
      ),
    );

    _cardFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    _bounceAnim = Tween(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    _mainCtrl.forward().then((_) {
      _confettiCtrl.play();
      _bounceCtrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _bounceCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang        = ref.watch(localeProvider).languageCode;
    final bio         = kBirdBiology[widget.speciesName];
    final cardNumber  = kAllPolishGardenBirds.indexOf(widget.speciesName) + 1;
    final displayName = lang == 'pl'
        ? (bio?.polishName ?? widget.speciesName)
        : widget.speciesName;
    final colors = bio != null
        ? familyGradient(bio.family)
        : [AppTheme.primary, AppTheme.primaryDark];

    return AnimatedBuilder(
      animation: _mainCtrl,
      builder: (context, _) => Material(
        color: Colors.transparent,
        child: Stack(children: [
          // ── Ciemne tło ──────────────────────────────────────
          GestureDetector(
            onTap: () {},
            child: Container(
              color: Colors.black.withOpacity(_bgAnim.value),
            ),
          ),

          // ── Konfetti ────────────────────────────────────────
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              gravity: 0.2,
              colors: const [
                AppTheme.primary, AppTheme.primaryMid,
                Color(0xFFFFD54F), Colors.white,
                Color(0xFF81C784),
              ],
            ),
          ),

          // ── Tytuł ───────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            left: 0, right: 0,
            child: Transform.translate(
              offset: Offset(0, _titleSlide.value),
              child: Column(children: [
                Text(
                  lang == 'pl'
                      ? 'Nowy gatunek odkryty!'
                      : 'New species discovered!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (cardNumber > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#$cardNumber',
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
              ]),
            ),
          ),

          // ── Karta ───────────────────────────────────────────
          Center(
            child: ScaleTransition(
              scale: _cardScale,
              child: FadeTransition(
                opacity: _cardFade,
                child: AnimatedBuilder(
                  animation: _bounceCtrl,
                  builder: (_, __) => Transform.scale(
                    scale: _bounceAnim.value,
                    child: _LifebirdCard(
                      displayName: displayName,
                      speciesName: widget.speciesName,
                      bio: bio,
                      cardNumber: cardNumber,
                      colors: colors,
                      lang: lang,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Przycisk dismiss ─────────────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 48,
            left: 32, right: 32,
            child: Opacity(
              opacity: _cardFade.value,
              child: ElevatedButton(
                onPressed: widget.onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  lang == 'pl'
                      ? 'Dodano do kolekcji 🐦'
                      : 'Added to collection 🐦',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Karta w overlay ────────────────────────────────────────────────────────

class _LifebirdCard extends StatelessWidget {
  final String displayName;
  final String speciesName;
  final BirdBiology? bio;
  final int cardNumber;
  final List<Color> colors;
  final String lang;

  const _LifebirdCard({
    required this.displayName,
    required this.speciesName,
    required this.bio,
    required this.cardNumber,
    required this.colors,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final hasSvg = kAvailableSvgs.contains(speciesName);

    return Container(
      width: 220, height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(children: [
        // Sylwetka ptaka (tło)
        if (hasSvg)
          Positioned(
            bottom: -10, right: -10,
            child: Opacity(
              opacity: 0.25,
              child: SvgPicture.asset(
                birdSvgPath(speciesName),
                width: 160,
                colorFilter: const ColorFilter.mode(
                    Colors.white, BlendMode.srcIn),
              ),
            ),
          ),

        // Treść
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Numer karty
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#$cardNumber',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),

              const Spacer(),

              // Nazwa gatunku
              Text(
                displayName,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              if (bio != null)
                Text(
                  bio!.scientificName,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic),
                ),

              const SizedBox(height: 12),

              // Dziś odkryty
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded,
                      size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    lang == 'pl'
                        ? 'Pierwsze wykrycie'
                        : 'First detection',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
