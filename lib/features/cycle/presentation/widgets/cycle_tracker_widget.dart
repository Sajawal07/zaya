import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyclePhase {
  final String label;
  final Color color;
  final int startDay;
  final int endDay;

  const CyclePhase({
    required this.label,
    required this.color,
    required this.startDay,
    required this.endDay,
  });
}

class CycleTrackerWidget extends StatefulWidget {
  final int currentDay;
  final List<Map<String, dynamic>> periodHistory;
  final VoidCallback onStartToday;

  const CycleTrackerWidget({
    super.key,
    required this.currentDay,
    this.periodHistory = const [],
    required this.onStartToday,
  });

  @override
  State<CycleTrackerWidget> createState() => _CycleTrackerWidgetState();
}

class _CycleTrackerWidgetState extends State<CycleTrackerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<CyclePhase> phases = [
    const CyclePhase(
      label: 'Menstrual',
      color: Color(0xFFD47A8E), // Dark Pink
      startDay: 1,
      endDay: 5,
    ),
    const CyclePhase(
      label: 'Follicular',
      color: Color(0xFFE7C6F0), // Light Purple
      startDay: 6,
      endDay: 10,
    ),
    const CyclePhase(
      label: 'Ovulation',
      color: Color(0xFFFFB88C), // Orange/Peach
      startDay: 11,
      endDay: 16,
    ),
    const CyclePhase(
      label: 'Luteal',
      color: Color(0xFFF4B6C2), // Soft Rose
      startDay: 17,
      endDay: 28,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CycleTrackerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDay != widget.currentDay) {
      _controller.reset();
      _controller.forward();
    }
  }

  String _getGuidanceMessage() {
    if (widget.currentDay <= 28) return "";
    int delay = widget.currentDay - 28;
    if (delay <= 7) {
      return "Your cycle is pending. Please monitor or log your period.";
    } else {
      return "Period significantly late. If not trying to conceive, consult a doctor. If trying to conceive, take a pregnancy test.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String guidance = _getGuidanceMessage();
    
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Circular Tracker
          Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 380,
                        maxHeight: 380,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                        // Outer background ring glow
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF4B6C2).withValues(alpha: 0.08),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        CustomPaint(
                          size: const Size(380, 380),
                          painter: CyclePainter(
                            currentDay: widget.currentDay,
                            phases: phases,
                            animationValue: _animation.value,
                          ),
                        ),
                        _buildCenterText(),
                      ],
                    ),
                  ),
                );
              },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Start Today Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD47A8E).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: widget.onStartToday,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD47A8E),
                    disabledBackgroundColor: const Color(0xFFD47A8E).withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Log Period Start',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            
            if (guidance.isNotEmpty) ...[
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF4B6C2).withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: widget.currentDay > 35 ? const Color(0xFFD47A8E) : const Color(0xFFD47A8E).withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          guidance,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            height: 1.4,
                            color: const Color(0xFF333333),
                            fontWeight: widget.currentDay > 35 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCenterText() {
    const fertileStart = 11;
    const fertileEnd = 16;
    
    String msg = "";
    String days = "";
    
    if (widget.currentDay >= 1 && widget.currentDay <= 5) {
      msg = "Your period is in";
      days = "Day ${widget.currentDay}";
    } else if (widget.currentDay >= fertileStart && widget.currentDay <= fertileEnd) {
      msg = "You are in your";
      days = "Fertile Window";
    } else if (widget.currentDay > 0 && widget.currentDay < fertileStart) {
      msg = "Fertile window in";
      days = "${fertileStart - widget.currentDay} Day${fertileStart - widget.currentDay > 1 ? 's' : ''}";
    } else if (widget.currentDay > fertileEnd && widget.currentDay <= 28) {
      msg = "Fertile window";
      days = "Has Passed";
    } else if (widget.currentDay > 28) {
      msg = "Your period is";
      days = "${widget.currentDay - 28} Day${widget.currentDay - 28 > 1 ? 's' : ''} Late";
    } else {
      msg = "Set your period";
      days = "To Start";
    }

    return SizedBox(
      width: 240, // Constrain width to fit within circle radius
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            msg,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: const Color(0xFF757575),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            days,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 26, // Reduced from 32 to prevent overlap
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Period Day: ${widget.currentDay}",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

class CyclePainter extends CustomPainter {
  final int currentDay;
  final List<CyclePhase> phases;
  final double animationValue;

  CyclePainter({
    required this.currentDay,
    required this.phases,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    const double strokeWidth = 36;
    
    // Calculate ring radius such that it's centered with space for labels outside
    final double ringRadius = radius - strokeWidth - 10;
    
    const int totalSegments = 28;
    const double anglePerSegment = (2 * pi) / totalSegments;
    const double startAngleOffset = -pi / 2 - (anglePerSegment / 2); // Center Day 1 at top

    // 1. Draw individual segments
    for (int i = 0; i < totalSegments; i++) {
      final int day = i + 1;
      final CyclePhase phase = phases.firstWhere(
        (p) => day >= p.startDay && day <= p.endDay,
        orElse: () => phases.last,
      );

      final double startAngle = startAngleOffset + (i * anglePerSegment);
      const double gap = 0.025; 
      const double sweepAngle = anglePerSegment - (2 * gap);

      final Paint segmentPaint = Paint()
        ..color = phase.color.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ringRadius),
        startAngle + gap,
        sweepAngle,
        false,
        segmentPaint,
      );
    }

    // 2. Draw all non-selected numbers first (Middle Layer)
    for (int i = 0; i < totalSegments; i++) {
      final int day = i + 1;
      if (day == currentDay) continue; 

      final double angle = startAngleOffset + (i * anglePerSegment) + (anglePerSegment / 2);
      _drawDayNumber(
        canvas, 
        center, 
        ringRadius, 
        angle, 
        day, 
        isSelected: false, 
        scale: 1.0,
      );
    }

    // 3. Draw Highlight & Current Day Text (Top Layer)
    if (currentDay > 0 && currentDay <= 28) {
      final int i = currentDay - 1;
      final double highlightAngle = startAngleOffset + (i * anglePerSegment) + (anglePerSegment / 2);
      
      // NOTE: ringRadius used in drawArc is the center-line of the stroke.
      // Therefore, indicatorRadius = ringRadius perfectly centers the indicator on the ring path.
      final double indicatorRadius = ringRadius; 
      final Offset highlightPos = Offset(
        center.dx + indicatorRadius * cos(highlightAngle),
        center.dy + indicatorRadius * sin(highlightAngle),
      );

      final double scale = animationValue;
      
      // Proportional sizing for responsive look
      final double mainIndicatorSize = (strokeWidth * 0.65) * scale;
      final double glowSize = (strokeWidth * 0.85) * scale;

      // Premium Shadow Layer (Subtle depth)
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(highlightPos + const Offset(0, 3), mainIndicatorSize, shadowPaint);

      // Bloom/Glow Layer
      final Paint glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(highlightPos, glowSize, glowPaint);

      // Main Indicator Circle (White)
      final Paint highlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(highlightPos, mainIndicatorSize, highlightPaint);
      
      // Fine Accent Border
      final Paint borderPaint = Paint()
        ..color = const Color(0xFFD47A8E).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(highlightPos, mainIndicatorSize, borderPaint);

      _drawDayNumber(
        canvas, 
        center, 
        indicatorRadius, 
        highlightAngle, 
        currentDay, 
        isSelected: true, 
        scale: scale,
      );
    }

    // Draw Phase Labels (Dynamic Radius - 16px outside the outer edge of the ring)
    final double labelRadius = ringRadius + (strokeWidth / 2) + 16;
    for (var phase in phases) {
      _drawPhaseLabel(canvas, center, labelRadius, startAngleOffset, phase);
    }
  }

  void _drawDayNumber(Canvas canvas, Offset center, double radius, double angle, int day, {bool isSelected = false, double scale = 1.0}) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: "$day",
        style: GoogleFonts.outfit(
          fontSize: isSelected ? 12 : 10,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
          color: isSelected ? const Color(0xFF333333) : const Color(0xFF333333).withValues(alpha: 0.7),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Move number to center exactly (Balanced visually)
    final Offset pos = Offset(
      center.dx + radius * cos(angle) - tp.width / 2,
      center.dy + radius * sin(angle) - tp.height / 2 + (isSelected ? 4 : 1.5),
    );
    
    canvas.save();
    if (isSelected) {
      canvas.translate(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      canvas.scale(scale);
      canvas.translate(-(center.dx + radius * cos(angle)), -(center.dy + radius * sin(angle)));

      // Draw "Day" text only for selected day
       final TextPainter dayTp = TextPainter(
        text: TextSpan(
          text: "Day",
          style: GoogleFonts.outfit(
            fontSize: 7,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF757575),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final Offset dayPos = Offset(
        center.dx + radius * cos(angle) - dayTp.width / 2,
        center.dy + radius * sin(angle) - dayTp.height - 6,
      );
      dayTp.paint(canvas, dayPos);
    }
    
    tp.paint(canvas, pos);
    canvas.restore();
  }

  void _drawPhaseLabel(Canvas canvas, Offset center, double radius, double startAngleOffset, CyclePhase phase) {
    final int totalSegments = 28;
    final double anglePerSegment = (2 * pi) / totalSegments;
    
    // Calculate span of the phase
    final double startAngle = startAngleOffset + ((phase.startDay - 1) * anglePerSegment);
    final double endAngle = startAngleOffset + ((phase.endDay - 1) * anglePerSegment) + anglePerSegment;
    final double middleAngle = (startAngle + endAngle) / 2;

    _drawArchedText(canvas, center, radius, middleAngle, phase.label.toUpperCase(), phase.color);
  }

  void _drawArchedText(Canvas canvas, Offset center, double radius, double middleAngle, String text, Color color) {
    const double letterSpacing = 0.08;
    final List<String> letters = text.split("");
    final double totalAngle = letters.length * letterSpacing;
    double currentAngle = middleAngle - totalAngle / 2;

    for (var letter in letters) {
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: letter,
          style: GoogleFonts.outfit(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color.withValues(alpha: 0.9),
            letterSpacing: 0.8,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final Offset pos = Offset(
        center.dx + radius * cos(currentAngle),
        center.dy + radius * sin(currentAngle),
      );

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(currentAngle + pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();

      currentAngle += letterSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant CyclePainter oldDelegate) {
    return oldDelegate.currentDay != currentDay || oldDelegate.animationValue != animationValue;
  }
}
