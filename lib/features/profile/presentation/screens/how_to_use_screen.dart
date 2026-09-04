import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hercycle_bloom/core/app_colors.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  static const _sections = [
    _GuideSection(
      icon: Icons.water_drop_rounded,
      color: AppColors.periodRed,
      title: 'Cycle Tracking',
      steps: [
        'Tap the ring on the Home screen to log your period start.',
        'Each day you can add symptoms, flow intensity, mood, and notes.',
        'HerCycle Bloom learns from your logs to predict future cycles more accurately.',
        'The colored ring segments show period, fertile window, ovulation, and safe days.',
      ],
    ),
    _GuideSection(
      icon: Icons.spa_rounded,
      color: AppColors.fertileGreen,
      title: 'Fertility Insights',
      steps: [
        'Your fertile window is highlighted in green on the ring.',
        'The 🌸 icon marks your predicted ovulation day.',
        'Fertility scores are calculated using your cycle history and symptoms.',
        'Log basal body temperature for enhanced accuracy (optional).',
      ],
    ),
    _GuideSection(
      icon: Icons.waves_rounded,
      color: AppColors.nudeRose,
      title: 'PCOS Tools',
      steps: [
        'Navigate to Health > PCOS Analysis from the bottom nav.',
        'Answer the hormonal questionnaire to generate your PCOS risk profile.',
        'View symptom patterns, hormonal tendencies, and nutrition advice.',
        'Consult a doctor if your PCOS risk is flagged as High.',
      ],
    ),
    _GuideSection(
      icon: Icons.child_care_rounded,
      color: AppColors.pregnancyGold,
      title: 'Pregnancy Mode',
      steps: [
        'Go to Profile and toggle on Pregnancy Mode.',
        'Enter the first day of your last menstrual period.',
        'The home screen switches to a weekly pregnancy tracker.',
        'Get daily fetal development insights, nutrition tips, and milestones.',
        'Toggle off Pregnancy Mode anytime to return to cycle tracking.',
      ],
    ),
    _GuideSection(
      icon: Icons.notifications_active_rounded,
      color: Color(0xFF9C59D1),
      title: 'Notifications',
      steps: [
        'Enable notifications in Profile > Notification Preferences.',
        'Get period reminders 2 days before your predicted start.',
        'Receive fertile window alerts and ovulation-day notifications.',
        'Choose which reminders matter to you and toggle others off.',
      ],
    ),
    _GuideSection(
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF5C6BC0),
      title: 'AI Health Coach',
      steps: [
        'Tap the AI tab at the bottom of the screen.',
        'Ask questions about your cycle, fertility, PCOS, or pregnancy.',
        'The AI uses your recent logs to give personalized answers.',
        'Premium members get unlimited conversations and deeper insights.',
      ],
    ),
    _GuideSection(
      icon: Icons.restaurant_menu_rounded,
      color: AppColors.mistySage,
      title: 'Nourish (Nutrition)',
      steps: [
        'The Nourish tab offers hormone-friendly recipes.',
        'Recipes are tagged by cycle phase for optimal nutrition.',
        'Filter by PCOS-friendly, pregnancy-safe, or anti-inflammatory.',
        'Save favorites for quick access anytime.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: const Text('How to Use HerCycle Bloom'),
        backgroundColor: AppColors.oldLace,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(),
            const SizedBox(height: 24),
            for (final section in _sections) ...[
              _SectionCard(section: section),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.nudeRose.withValues(alpha: 0.3),
            AppColors.mistySage.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: AppColors.nudeRose, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to HerCycle Bloom',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your complete guide to every feature.',
                  style: GoogleFonts.montserrat(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideSection {
  final IconData icon;
  final Color color;
  final String title;
  final List<String> steps;

  const _GuideSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.steps,
  });
}

class _SectionCard extends StatefulWidget {
  final _GuideSection section;
  const _SectionCard({required this.section});

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.section.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.section.icon,
                        color: widget.section.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.section.title,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  for (int i = 0; i < widget.section.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: widget.section.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: widget.section.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.section.steps[i],
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
