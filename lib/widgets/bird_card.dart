import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/bird_biology.dart';
import '../data/card_data.dart';
import '../models/species_summary.dart';

class BirdCard extends StatefulWidget {
  final String speciesName;
  final SpeciesSummary? summary;
  final String lang;
  final VoidCallback? onDetailTap;

  const BirdCard({
    required this.speciesName,
    required this.lang,
    this.summary,
    this.onDetailTap,
    super.key,
  });

  bool get isUnlocked => summary != null;

  @override
  State<BirdCard> createState() => _BirdCardState();
}

class _BirdCardState extends State<BirdCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  bool _showingBack = false;
  AnimationController? _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
    final bio = kBirdBiology[widget.speciesName];
    if (widget.isUnlocked &&
        bio != null &&
        bio.cardRarity.index >= CardRarity.rare.index) {
      _shimmerCtrl = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _shimmerCtrl?.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.isUnlocked) return;
    _showingBack ? _flipCtrl.reverse() : _flipCtrl.forward();
    setState(() => _showingBack = !_showingBack);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _flipAnim,
        builder: (_, __) {
          final angle    = _flipAnim.value * math.pi;
          final showBack = _flipAnim.value > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardBack(
                      speciesName: widget.speciesName,
                      summary: widget.summary!,
                      lang: widget.lang,
                      onDetailTap: widget.onDetailTap,
                    ),
                  )
                : _CardFront(
                    speciesName: widget.speciesName,
                    summary: widget.summary,
                    lang: widget.lang,
                    shimmerCtrl: _shimmerCtrl,
                  ),
          );
        },
      ),
    );
  }
}

// ── PRZÓD ──────────────────────────────────────────────────────────────────

class _CardFront extends StatelessWidget {
  final String speciesName;
  final SpeciesSummary? summary;
  final String lang;
  final AnimationController? shimmerCtrl;
  const _CardFront({
    required this.speciesName, required this.summary,
    required this.lang, required this.shimmerCtrl,
  });

  bool get isUnlocked => summary != null;

  @override
  Widget build(BuildContext context) {
    final bio    = kBirdBiology[speciesName];
    final colors = isUnlocked && bio != null
        ? familyGradient(bio.family)
        : [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)];
    final displayName = isUnlocked && bio != null
        ? (lang == 'pl' ? bio.polishName : speciesName)
        : '???';

    return _CardShell(
      colors: colors,
      shimmerCtrl: isUnlocked ? shimmerCtrl : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Badge rzadkości
        Align(
          alignment: Alignment.topRight,
          child: isUnlocked && bio != null
              ? _RarityBadge(bio: bio, lang: lang)
              : const SizedBox(height: 16),
        ),

        // Sylwetka SVG
        Expanded(
          child: Center(
            child: isUnlocked && kAvailableSvgs.contains(speciesName)
                ? SvgPicture.asset(
                    birdSvgPath(speciesName),
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.9),
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  )
                : CustomPaint(
                    painter: _FallbackBirdPainter(
                        opacity: isUnlocked ? 0.9 : 0.12),
                    size: Size.infinite,
                  ),
          ),
        ),

        // Numer karty
        Text(
          '#${kAllPolishGardenBirds.indexOf(speciesName) + 1}',
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withAlpha(150),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        // Nazwa
        Text(displayName,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: isUnlocked ? Colors.white : Colors.white24),
            maxLines: 1, overflow: TextOverflow.ellipsis),

        if (isUnlocked && bio != null) ...[
          Text(bio.scientificName,
              style: TextStyle(
                  fontSize: 9, color: Colors.white.withAlpha(160),
                  fontStyle: FontStyle.italic),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          _StatDots(label: '⚡', count: bio.sizeStars),
          const SizedBox(height: 2),
          _StatDots(label: '🎵', count: bio.songStars),
          const SizedBox(height: 2),
          _StatDots(label: '👁', count: bio.rarityStars),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(50),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${summary!.visits} wizyt · ${summary!.daysInGarden}d',
              style: const TextStyle(fontSize: 8, color: Colors.white70),
            ),
          ),
        ] else ...[
          const SizedBox(height: 4),
          _StatDots(label: '⚡', count: 0, locked: true),
          const SizedBox(height: 2),
          _StatDots(label: '🎵', count: 0, locked: true),
          const SizedBox(height: 2),
          _StatDots(label: '👁', count: 0, locked: true),
          const SizedBox(height: 6),
          Text('Nie wykryto',
              style: TextStyle(
                  fontSize: 8, color: Colors.white.withAlpha(40))),
        ],
      ]),
    );
  }
}

// ── TYŁ ────────────────────────────────────────────────────────────────────

class _CardBack extends StatelessWidget {
  final String speciesName;
  final SpeciesSummary summary;
  final String lang;
  final VoidCallback? onDetailTap;
  const _CardBack({
    required this.speciesName, required this.summary,
    required this.lang, required this.onDetailTap,
  });

  String _formatDate(DateTime dt) {
    const mPl = ['','sty','lut','mar','kwi','maj','cze',
                  'lip','sie','wrz','paź','lis','gru'];
    const mEn = ['','Jan','Feb','Mar','Apr','May','Jun',
                  'Jul','Aug','Sep','Oct','Nov','Dec'];
    final m = lang == 'pl' ? mPl : mEn;
    return '${dt.day} ${m[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bio    = kBirdBiology[speciesName];
    final isRare = bio != null &&
        bio.cardRarity.index >= CardRarity.rare.index;
    final baseColors = bio != null
        ? familyGradient(bio.family)
        : [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)];
    final colors = baseColors
        .map((c) => Color.lerp(c, Colors.black, 0.35)!)
        .toList();
    final hasPhoto = kAvailablePhotos.contains(speciesName);

    return _CardShell(
      colors: colors,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Zdjęcie / placeholder
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: hasPhoto
                ? Image.asset(
                    birdPhotoPath(speciesName),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _PhotoPlaceholder(lang: lang),
                  )
                : _PhotoPlaceholder(lang: lang),
          ),
        ),

        const SizedBox(height: 8),

        // Garden + wizyty
        Text(
          lang == 'pl' ? 'Twój ogród' : 'Your garden',
          style: TextStyle(fontSize: 9, color: Colors.white.withAlpha(120)),
        ),
        Text(
          lang == 'pl'
              ? '${summary.visits} wizyt · ${summary.daysInGarden} dni'
              : '${summary.visits} visits · ${summary.daysInGarden} days',
          style: const TextStyle(
              fontSize: 11, color: Colors.white,
              fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 6),

        // Data odkrycia
        if (isRare && bio != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: kRarityColor[bio.cardRarity]!.withAlpha(40),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                  color: kRarityColor[bio.cardRarity]!.withAlpha(120),
                  width: 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.auto_awesome,
                  size: 8, color: kRarityColor[bio.cardRarity]),
              const SizedBox(width: 4),
              Text(
                '${lang == 'pl' ? 'ODKRYTO' : 'FOUND'}  '
                '${_formatDate(summary.firstSeen)}',
                style: TextStyle(
                    fontSize: 8,
                    color: kRarityColor[bio.cardRarity],
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3),
              ),
            ]),
          )
        else
          Text(
            '${lang == 'pl' ? 'od' : 'since'} '
            '${_formatDate(summary.firstSeen)}',
            style: TextStyle(fontSize: 9, color: Colors.white.withAlpha(100)),
          ),

        const SizedBox(height: 8),

        // Przycisk szczegóły
        GestureDetector(
          onTap: onDetailTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                  color: Colors.white.withAlpha(40), width: 0.5),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(lang == 'pl' ? 'Szczegóły' : 'Details',
                  style: const TextStyle(
                      fontSize: 10, color: Colors.white,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios,
                  size: 8, color: Colors.white),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Photo placeholder ──────────────────────────────────────────────────────

class _PhotoPlaceholder extends StatelessWidget {
  final String lang;
  const _PhotoPlaceholder({required this.lang});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black.withAlpha(50),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.camera_alt_outlined,
          color: Colors.white.withAlpha(60), size: 26),
      const SizedBox(height: 4),
      Text(
        lang == 'pl'
            ? 'foto po\ninstalacji kamery'
            : 'photo after\ncamera setup',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 7, color: Colors.white.withAlpha(50)),
      ),
    ]),
  );
}

// ── Card shell (wspólny kontener) ──────────────────────────────────────────

class _CardShell extends StatelessWidget {
  final List<Color> colors;
  final AnimationController? shimmerCtrl;
  final Widget child;
  const _CardShell({
    required this.colors,
    required this.child,
    this.shimmerCtrl,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      boxShadow: [
        BoxShadow(
            color: colors.first.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 4)),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _TexturePainter())),
        if (shimmerCtrl != null)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: shimmerCtrl!,
              builder: (_, __) => ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment(shimmerCtrl!.value * 3 - 1.5, -1),
                  end: Alignment(shimmerCtrl!.value * 3 - 0.5, 1),
                  colors: [
                    Colors.transparent,
                    Colors.white.withAlpha(50),
                    Colors.transparent,
                  ],
                ).createShader(bounds),
                child: Container(color: Colors.white),
              ),
            ),
          ),
        Padding(padding: const EdgeInsets.all(10), child: child),
      ]),
    ),
  );
}

// ── Rarity badge ───────────────────────────────────────────────────────────

class _RarityBadge extends StatelessWidget {
  final BirdBiology bio;
  final String lang;
  const _RarityBadge({required this.bio, required this.lang});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: kRarityColor[bio.cardRarity]!.withAlpha(200),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      lang == 'pl'
          ? kRarityLabel[bio.cardRarity]!
          : kRarityLabelEn[bio.cardRarity]!,
      style: const TextStyle(
          fontSize: 7, color: Colors.white, fontWeight: FontWeight.w700),
    ),
  );
}

// ── Stat dots ──────────────────────────────────────────────────────────────

class _StatDots extends StatelessWidget {
  final String label;
  final int count;
  final bool locked;
  const _StatDots({required this.label, required this.count, this.locked = false});

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label, style: const TextStyle(fontSize: 8)),
    const SizedBox(width: 3),
    ...List.generate(5, (i) => Padding(
      padding: const EdgeInsets.only(right: 1.5),
      child: Icon(
        i < count ? Icons.circle : Icons.circle_outlined,
        size: 6,
        color: locked
            ? Colors.white12
            : i < count ? Colors.white : Colors.white38,
      ),
    )),
  ]);
}

// ── Fallback bird (gdy SVG niedostępny) ───────────────────────────────────

class _FallbackBirdPainter extends CustomPainter {
  final double opacity;
  const _FallbackBirdPainter({this.opacity = 0.9});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    final cx = size.width * 0.52;
    final cy = size.height * 0.52;
    canvas.drawOval(Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.width * 0.52, height: size.height * 0.36), p);
    canvas.drawCircle(
        Offset(cx + size.width * 0.20, cy - size.height * 0.22),
        size.width * 0.16, p);
    canvas.drawPath(Path()
      ..moveTo(cx + size.width * 0.36, cy - size.height * 0.24)
      ..lineTo(cx + size.width * 0.54, cy - size.height * 0.19)
      ..lineTo(cx + size.width * 0.36, cy - size.height * 0.14)
      ..close(), p);
    canvas.drawPath(Path()
      ..moveTo(cx - size.width * 0.24, cy - size.height * 0.04)
      ..lineTo(cx - size.width * 0.50, cy - size.height * 0.16)
      ..lineTo(cx - size.width * 0.52, cy + size.height * 0.12)
      ..lineTo(cx - size.width * 0.24, cy + size.height * 0.06)
      ..close(), p);
  }

  @override
  bool shouldRepaint(covariant _FallbackBirdPainter old) =>
      old.opacity != opacity;
}

// ── Card texture ───────────────────────────────────────────────────────────

class _TexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withAlpha(7)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    const spacing = 18.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
