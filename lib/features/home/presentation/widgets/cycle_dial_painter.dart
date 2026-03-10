import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:zaya/core/app_colors.dart';

class CycleDialPainter extends CustomPainter {
  final int currentDay;
  final int cycleLength;
  final bool isPregnancyMode;

  CycleDialPainter({
    required this.currentDay,
    required this.cycleLength,
    this.isPregnancyMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final strokeWidth = 16.0;

    // Background circle
    final bgPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (isPregnancyMode) {
      // Pregnancy mode - Gold color
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.pregnancyGold,
            AppColors.pregnancyGold.withOpacity(0.6),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final progressAngle = (currentDay / 40) * 2 * math.pi; // 40 weeks
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        progressAngle,
        false,
        progressPaint,
      );
    } else {
      // Cycle mode - Different colors for different phases
      final progress = currentDay / cycleLength;
      
      // Determine cycle phase and color
      Color phaseColor;
      if (currentDay <= 5) {
        // Period phase - Red
        phaseColor = AppColors.periodRed;
      } else if (currentDay >= 12 && currentDay <= 16) {
        // Fertile window - Green
        phaseColor = AppColors.fertileGreen;
      } else {
        // Other phases - Primary color
        phaseColor = AppColors.nudeRose;
      }

      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            phaseColor,
            phaseColor.withOpacity(0.6),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final progressAngle = progress * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        progressAngle,
        false,
        progressPaint,
      );

      // Draw phase markers
      _drawPhaseMarkers(canvas, center, radius, strokeWidth);
    }

    // Outer glow effect
    final glowPaint = Paint()
      ..color = AppColors.nudeRose.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius + 10, glowPaint);
  }

  void _drawPhaseMarkers(Canvas canvas, Offset center, double radius, double strokeWidth) {
    // Draw subtle markers for key days
    final markerPaint = Paint()
      ..color = AppColors.textSecondary.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Period end marker (day 5)
    _drawMarker(canvas, center, radius, 5 / cycleLength, markerPaint);
    
    // Ovulation start (day 12)
    _drawMarker(canvas, center, radius, 12 / cycleLength, markerPaint);
    
    // Ovulation end (day 16)
    _drawMarker(canvas, center, radius, 16 / cycleLength, markerPaint);
  }

  void _drawMarker(Canvas canvas, Offset center, double radius, double position, Paint paint) {
    final angle = position * 2 * math.pi - math.pi / 2;
    final markerX = center.dx + radius * math.cos(angle);
    final markerY = center.dy + radius * math.sin(angle);
    
    canvas.drawCircle(Offset(markerX, markerY), 4, paint);
  }

  @override
  bool shouldRepaint(CycleDialPainter oldDelegate) {
    return oldDelegate.currentDay != currentDay ||
        oldDelegate.cycleLength != cycleLength ||
        oldDelegate.isPregnancyMode != isPregnancyMode;
  }
}
