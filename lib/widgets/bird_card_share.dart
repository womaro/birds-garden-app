import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/bird_biology.dart';
import '../models/species_summary.dart';
import '../providers/locale_provider.dart';

class BirdCardShareButton extends ConsumerStatefulWidget {
  final String speciesName;
  final SpeciesSummary? summary;
  final GlobalKey captureKey;

  const BirdCardShareButton({
    required this.speciesName,
    required this.captureKey,
    this.summary,
    super.key,
  });

  @override
  ConsumerState<BirdCardShareButton> createState() =>
      _BirdCardShareButtonState();
}

class _BirdCardShareButtonState extends ConsumerState<BirdCardShareButton> {
  final GlobalKey _btnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    return ElevatedButton.icon(
      key: _btnKey,
      onPressed: () => _share(context, lang),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.15),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white30),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      icon: const Icon(Icons.share_outlined, size: 18),
      label: Text(
        lang == 'pl' ? 'Udostępnij kartę' : 'Share card',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> _share(BuildContext context, String lang) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final boundary = widget.captureKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      debugPrint('📸 captureKey context: ${widget.captureKey.currentContext}');
      debugPrint('📸 boundary: $boundary');

      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final data  = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = data?.buffer.asUint8List();
      if (bytes == null || bytes.isEmpty) return;

      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/birds_garden_card.png');
      await file.writeAsBytes(bytes);

      final bio         = kBirdBiology[widget.speciesName];
      final displayName = lang == 'pl'
          ? (bio?.polishName ?? widget.speciesName)
          : widget.speciesName;
      final text = lang == 'pl'
          ? 'Odkryłem $displayName w swoim ogrodzie! 🐦 birds.garden'
          : 'I discovered a $displayName in my garden! 🐦 birds.garden';

      final box    = _btnKey.currentContext?.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : const Rect.fromLTWH(0, 400, 200, 50);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: text,
        sharePositionOrigin: origin,
      );
    } catch (e) {
      debugPrint('📸 Share error: $e');
    }
  }
}
