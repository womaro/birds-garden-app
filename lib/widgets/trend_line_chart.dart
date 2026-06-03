import 'package:flutter/material.dart';
import '../theme.dart';

class TrendLineChart extends StatelessWidget {
  final List<int> data;
  final List<String> labels;
  final double height;
  final Color? color;

  const TrendLineChart({
    required this.data,
    required this.labels,
    this.height = 64,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Column(children: [
      SizedBox(
        height: height,
        child: CustomPaint(
          painter: _LinePainter(data: data, color: c),
          size: Size.infinite,
        ),
      ),
      const SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels.map((l) => Text(l,
            style: const TextStyle(
                fontSize: 9, color: AppTheme.textTertiary))).toList(),
      ),
    ]);
  }
}

class _LinePainter extends CustomPainter {
  final List<int> data;
  final Color color;
  const _LinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final max = data.fold(0, (m, v) => v > m ? v : m).clamp(1, 9999).toDouble();
    final n   = data.length;

    final pts = List.generate(n, (i) => Offset(
      i * size.width / (n - 1),
      size.height - (data[i] / max) * size.height * 0.9 - size.height * 0.05,
    ));

    final fillPath = Path()
      ..moveTo(pts.first.dx, size.height)
      ..lineTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < n; i++) {
      fillPath.cubicTo(
        pts[i - 1].dx + (pts[i].dx - pts[i - 1].dx) / 2, pts[i - 1].dy,
        pts[i - 1].dx + (pts[i].dx - pts[i - 1].dx) / 2, pts[i].dy,
        pts[i].dx, pts[i].dy,
      );
    }
    fillPath.lineTo(pts.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath,
        Paint()..color = color.withAlpha(35)..style = PaintingStyle.fill);

    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < n; i++) {
      linePath.cubicTo(
        pts[i - 1].dx + (pts[i].dx - pts[i - 1].dx) / 2, pts[i - 1].dy,
        pts[i - 1].dx + (pts[i].dx - pts[i - 1].dx) / 2, pts[i].dy,
        pts[i].dx, pts[i].dy,
      );
    }
    canvas.drawPath(linePath,
        Paint()
          ..color = color
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    canvas.drawCircle(pts.last, 4,
        Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(pts.last, 4,
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.data != data || old.color != color;
}
