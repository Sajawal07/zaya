import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/app_colors.dart';
import '../../domain/models/nutrition_models.dart';

class MealRadarChart extends StatelessWidget {
  final MealScore score;
  final double size;

  const MealRadarChart({
    super.key,
    required this.score,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final strengths = _computeStrengths();
    final improvements = _computeImprovements();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: RadarChartPainter(score: score),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(AppColors.nudeRose.withValues(alpha: 0.6), 'Meal Impact'),
            const SizedBox(width: 16),
            _legend(AppColors.fertileGreen.withValues(alpha: 0.45), 'Ideal Target'),
          ],
        ),
        // ── Interpreted summary ─────────────────────────────────────────
        if (strengths.isNotEmpty || improvements.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.oldLace.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (strengths.isNotEmpty) ...[
                  const Text('Hormonal Benefits',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.fertileGreen)),
                  const SizedBox(height: 4),
                  ...strengths.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text('✓ $s',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.fertileGreen)),
                      )),
                ],
                if (strengths.isNotEmpty && improvements.isNotEmpty)
                  const SizedBox(height: 8),
                if (improvements.isNotEmpty) ...[
                  const Text('Consider Swapping',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.nudeRose)),
                  const SizedBox(height: 4),
                  ...improvements.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text('• $s',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.nudeRose)),
                      )),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<String> _computeStrengths() {
    final s = <String>[];
    final breakdown = score.breakdown;
    if (score.insulinImpact < 4) s.add('Excellent insulin control');
    if (breakdown.fiberDensity >= 2.5) s.add('Supports oestrogen clearance');
    if (breakdown.fatQuality >= 0.7) s.add('Supports progesterone production');
    if (score.inflammationScore < 3) s.add('Anti-inflammatory profile');
    return s;
  }

  List<String> _computeImprovements() {
    final i = <String>[];
    final breakdown = score.breakdown;
    if (score.insulinImpact > 6) i.add('High insulin spike potential');
    if (breakdown.fiberDensity < 1.5) i.add('Low fiber: slows oestrogen detox');
    if (breakdown.fatQuality < 0.45) i.add('Progesterone: needs healthy fats');
    if (score.inflammationScore > 5) i.add('High inflammatory markers');
    return i;
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final MealScore score;

  RadarChartPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 24; 

    final gridPaint = Paint()
      ..color = AppColors.oldLace
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final idealFill = Paint()
      ..color = AppColors.fertileGreen.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final idealOutline = Paint()
      ..color = AppColors.fertileGreen.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dataFill = Paint()
      ..color = AppColors.nudeRose.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final dataOutline = Paint()
      ..color = AppColors.nudeRose
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;

    final axisPaint = Paint()
      ..color = AppColors.oldLace
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // ── Labels & axes ────────────────────────────────────────────────────────
    const labels = ['Insulin', 'Oestrogen', 'Progesterone', 'Inflammation'];
    const n = 4;
    final angleStep = (2 * math.pi) / n;

    // Mapping to "Higher is Better" for the area chart
    final values = [
      (1.0 - (score.insulinImpact / 10.0)).clamp(0.05, 1.0),
      (score.breakdown.fiberDensity / 3.0).clamp(0.05, 1.0),
      (score.breakdown.fatQuality).clamp(0.05, 1.0),
      (1.0 - (score.inflammationScore / 10.0)).clamp(0.05, 1.0), 
    ];

    const idealValue = 0.85;

    for (int ring = 1; ring <= 4; ring++) {
      canvas.drawCircle(center, radius * (ring / 4), gridPaint);
    }

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      final angle = i * angleStep - math.pi / 2;
      final axisEnd = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, axisEnd, axisPaint);

      final labelOffset = Offset(
        center.dx + (radius + 18) * math.cos(angle),
        center.dy + (radius + 18) * math.sin(angle),
      );
      tp.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
      );
      tp.layout();
      tp.paint(canvas, labelOffset - Offset(tp.width / 2, tp.height / 2));
    }

    final idealPath = Path();
    for (int i = 0; i < n; i++) {
      final angle = i * angleStep - math.pi / 2;
      final pt = Offset(
        center.dx + radius * idealValue * math.cos(angle),
        center.dy + radius * idealValue * math.sin(angle),
      );
      if (i == 0) {
        idealPath.moveTo(pt.dx, pt.dy);
      } else {
        idealPath.lineTo(pt.dx, pt.dy);
      }
    }
    idealPath.close();
    canvas.drawPath(idealPath, idealFill);
    canvas.drawPath(idealPath, idealOutline);

    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final angle = i * angleStep - math.pi / 2;
      final pt = Offset(
        center.dx + radius * values[i] * math.cos(angle),
        center.dy + radius * values[i] * math.sin(angle),
      );
      if (i == 0) {
        dataPath.moveTo(pt.dx, pt.dy);
      } else {
        dataPath.lineTo(pt.dx, pt.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, dataFill);
    canvas.drawPath(dataPath, dataOutline);

    final dotPaint = Paint()..color = AppColors.nudeRose..style = PaintingStyle.fill;
    for (int i = 0; i < n; i++) {
      final angle = i * angleStep - math.pi / 2;
      canvas.drawCircle(
        Offset(
          center.dx + radius * values[i] * math.cos(angle),
          center.dy + radius * values[i] * math.sin(angle),
        ),
        4,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter old) =>
      old.score != score;
}
