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
      endDay: 6,
    ),
    const CyclePhase(
      label: 'Follicular',
      color: Color(0xFFE7C6F0), // Light Purple
      startDay: 7,
      endDay: 11,
    ),
    const CyclePhase(
      label: 'Ovulation',
      color: Color(0xFFFFB88C), // Orange/Peach
      startDay: 12,
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
    
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Circular Tracker
            Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return SizedBox(
                    width: 380,
                    height: 380,
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
                                color: const Color(0xFFF4B6C2).withOpacity(0.08),
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
                      color: const Color(0xFFD47A8E).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: (widget.currentDay > 25 || widget.currentDay == 0) 
                    ? widget.onStartToday 
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD47A8E),
                    disabledBackgroundColor: const Color(0xFFD47A8E).withOpacity(0.4),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    (widget.currentDay > 0 && widget.currentDay <= 25) 
                        ? 'Period Tracked' 
                        : 'Start Today',
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
                    border: Border.all(color: const Color(0xFFF4B6C2).withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: widget.currentDay > 35 ? const Color(0xFFD47A8E) : const Color(0xFFD47A8E).withOpacity(0.7),
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
      ),
    );
  }

  Widget _buildCenterText() {
    String msg = "Best chance to conceive is in";
    String days = "7 Days";
    
    if (widget.currentDay >= 12 && widget.currentDay <= 16) {
      msg = "You are in your";
      days = "Fertile Window";
    } else if (widget.currentDay >= 1 && widget.currentDay <= 5) {
      msg = "Your period is in";
      days = "Day ${widget.currentDay}";
    } else if (widget.currentDay > 28) {
      msg = "Your cycle is";
      days = "${widget.currentDay - 28} Days Late";
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          msg,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: const Color(0xFF757575),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          days,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Period Day: ${widget.currentDay}",
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9E9E9E),
          ),
        ),
      ],
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
    final double strokeWidth = 36;
    final double ringRadius = radius - strokeWidth - 10;
    
    final int totalSegments = 28;
    final double anglePerSegment = (2 * pi) / totalSegments;
    final double startAngleOffset = -pi / 2 - (anglePerSegment / 2); // Start exactly at top

    // 1. Draw individual segments
    for (int i = 0; i < totalSegments; i++) {
      final int day = i + 1;
      final CyclePhase phase = phases.firstWhere(
        (p) => day >= p.startDay && day <= p.endDay,
        orElse: () => phases.last,
      );

      final double startAngle = startAngleOffset + (i * anglePerSegment);
      const double sweepAngle = 0.21; 

      final Paint segmentPaint = Paint()
        ..color = phase.color.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ringRadius),
        startAngle + 0.02,
        sweepAngle - 0.04,
        false,
        segmentPaint,
      );
    }

    // 2. Draw all non-selected numbers first (Middle Layer)
    for (int i = 0; i < totalSegments; i++) {
      final int day = i + 1;
      if (day == currentDay) continue; // Skip selected day for now

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

    // 3. Draw Highlight & Current Day Text (Top Layer - Prominent)
    if (currentDay > 0 && currentDay <= 28) {
      final int i = currentDay - 1;
      final double highlightAngle = startAngleOffset + (i * anglePerSegment) + (anglePerSegment / 2);
      
      // Move highlight slightly outward to avoid hiding neighbor numbers
      final double highlightRadius = ringRadius + 5; 
      final Offset highlightPos = Offset(
        center.dx + highlightRadius * cos(highlightAngle),
        center.dy + highlightRadius * sin(highlightAngle),
      );

      final double scale = animationValue;

      // Adjusted Glow effect
      final Paint glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(highlightPos, (strokeWidth / 2 + 12) * scale, glowPaint);

      // Adjusted White Highlight Circle
      final Paint highlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(highlightPos, (strokeWidth / 2 + 6) * scale, highlightPaint);
      
      // Prominent Border
      final Paint borderPaint = Paint()
        ..color = const Color(0xFFF4B6C2).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(highlightPos, (strokeWidth / 2 + 6) * scale, borderPaint);

      // Current Day Text on Top (Using slightly shifted radius)
      _drawDayNumber(
        canvas, 
        center, 
        highlightRadius, 
        highlightAngle, 
        currentDay, 
        isSelected: true, 
        scale: scale,
      );
    }

    // Draw Phase Labels
    for (var phase in phases) {
      _drawPhaseLabel(canvas, center, ringRadius + 34, startAngleOffset, phase);
    }
  }

  void _drawDayNumber(Canvas canvas, Offset center, double radius, double angle, int day, {bool isSelected = false, double scale = 1.0}) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: "$day",
        style: GoogleFonts.outfit(
          fontSize: isSelected ? 12 : 10,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
          color: isSelected ? const Color(0xFF333333) : const Color(0xFF333333).withOpacity(0.7),
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
            color: color.withOpacity(0.9),
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
