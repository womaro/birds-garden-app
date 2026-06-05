import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/species_summary.dart';
import 'bird_card.dart';
import 'bird_card_share.dart';

class ExpandedCardsRoute extends PageRouteBuilder {
  final int initialIndex;
  final List<String> cards;
  final Map<String, SpeciesSummary?> summaryMap;

  ExpandedCardsRoute({
    required this.initialIndex,
    required this.cards,
    required this.summaryMap,
  }) : super(
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (c, a, _) => ExpandedCardsView(
      initialIndex: initialIndex,
      cards: cards,
      summaryMap: summaryMap,
    ),
    transitionsBuilder: (c, a, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class ExpandedCardsView extends StatefulWidget {
  final int initialIndex;
  final List<String> cards;
  final Map<String, SpeciesSummary?> summaryMap;

  const ExpandedCardsView({
    required this.initialIndex,
    required this.cards,
    required this.summaryMap,
    super.key,
  });

  @override
  State<ExpandedCardsView> createState() => _ExpandedCardsViewState();
}

class _ExpandedCardsViewState extends State<ExpandedCardsView>
    with SingleTickerProviderStateMixin {

  late PageController _pageCtrl;
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;
  late ValueNotifier<int> _currentPage;
  final GlobalKey _cardRepaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 0.85,
    );
    _currentPage = ValueNotifier(widget.initialIndex);
    _pageCtrl.addListener(() {
      final p = _pageCtrl.page?.round() ?? widget.initialIndex;
      if (_currentPage.value != p) _currentPage.value = p;
    });
    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _scaleAnim = CurvedAnimation(
        parent: _scaleCtrl, curve: Curves.elasticOut);
    _scaleCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _scaleCtrl.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _scaleCtrl.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _dismiss,
      child: Stack(children: [

        // ── Rozmyte tło ──────────────────────────────────────
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.black.withOpacity(0.65)),
        ),

        // ── Zamknij ──────────────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 16,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),

        // ── Karty ────────────────────────────────────────────
        Center(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.62,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: widget.cards.length,
                itemBuilder: (ctx, i) => ValueListenableBuilder<int>(
                  valueListenable: _currentPage,
                  builder: (_, page, __) {
                    final isCurrent = i == page;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onDoubleTap: _dismiss,
                        child: RepaintBoundary(
                          key: isCurrent ? _cardRepaintKey : null,
                          child: BirdCard(
                            speciesName: widget.cards[i],
                            summary: widget.summaryMap[widget.cards[i]],
                            expanded: true,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // ── Share + hint ──────────────────────────────────────
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 20,
          left: 0, right: 0,
          child: Column(children: [
            ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (_, page, __) => BirdCardShareButton(
                speciesName: widget.cards[page],
                summary: widget.summaryMap[widget.cards[page]],
                captureKey: _cardRepaintKey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'tap → flip  ·  podwójne tap → zamknij',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10, color: Colors.white.withOpacity(0.4)),
            ),
          ]),
        ),
      ]),
    );
  }
}
