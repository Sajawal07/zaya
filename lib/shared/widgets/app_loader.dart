import 'dart:math' as math;
import 'package:flutter/material.dart';

/// App-wide custom loader — 12-dot ring (matches `assets/images/loader.svg` look).
/// Built with Flutter animation because `flutter_svg` does not run SVG SMIL `<animate>`.
class AppLoader extends StatefulWidget {
  final double size;
  final Color color;

  const AppLoader({
    super.key,
    this.size = 64,
    this.color = const Color(0xFFC61A2A),
  });

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Slower cycle so the spinner is clearly visible.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _DotRingPainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _DotRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DotRingPainter({required this.progress, required this.color});

  static const int _dotCount = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = size.shortestSide * 0.38;
    final maxDotRadius = size.shortestSide * 0.085;

    for (var i = 0; i < _dotCount; i++) {
      // Stagger each dot around the loop (same idea as the SVG begin offsets).
      final phase = (progress - i / _dotCount) % 1.0;
      // Pulse: grow then shrink (values 0 → 1 → 0).
      final t = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
      final eased = Curves.easeInOut.transform(t.clamp(0.0, 1.0));
      final r = maxDotRadius * (0.15 + 0.85 * eased);

      final angle = (i / _dotCount) * math.pi * 2 - math.pi / 2;
      final offset = Offset(
        center.dx + ringRadius * math.cos(angle),
        center.dy + ringRadius * math.sin(angle),
      );

      final paint = Paint()
        ..color = color.withValues(alpha: 0.25 + 0.75 * eased)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offset, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Centered full-area loader for page / future loading states.
class AppLoaderCentered extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color color;

  const AppLoaderCentered({
    super.key,
    this.size = 72,
    this.backgroundColor,
    this.color = const Color(0xFFC61A2A),
  });

  @override
  Widget build(BuildContext context) {
    final child = Center(child: AppLoader(size: size, color: color));
    if (backgroundColor == null) return child;
    return ColoredBox(color: backgroundColor!, child: SizedBox.expand(child: child));
  }
}
