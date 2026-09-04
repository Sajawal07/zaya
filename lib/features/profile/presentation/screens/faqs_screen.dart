import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hercycle_bloom/core/app_colors.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  String _query = '';
  final _controller = TextEditingController();

  static const _faqs = [
    _FaqItem(
      category: 'Cycle Tracking',
      question: 'How accurate are HerCycle Bloom\'s cycle predictions?',
      answer:
          'Accuracy improves with each logged cycle. After 3+ cycles, predictions typically fall within 1–2 days of your actual period. Lifestyle factors, stress, and health changes can shift your cycle — HerCycle Bloom accounts for these variations over time.',
    ),
    _FaqItem(
      category: 'Cycle Tracking',
      question: 'What counts as a period "start"?',
      answer:
          'Your period start is the first day of full red bleeding (not spotting). Spotting 1–2 days before flow is common but should be logged as spotting, not a period start.',
    ),
    _FaqItem(
      category: 'Cycle Tracking',
      question: 'Can I edit or delete a period I logged by mistake?',
      answer:
          'Yes. Go to Profile > Data Management > Reset Recent Data to undo logs from the last 7 days. For older corrections, contact support.',
    ),
    _FaqItem(
      category: 'Fertility',
      question: 'How is my fertile window calculated?',
      answer:
          'HerCycle Bloom uses a modified Knaus-Ogino method combined with your cycle length history. Fertile window spans 5 days leading to ovulation and 1 day after. Ovulation is estimated at cycle day (length − 14).',
    ),
    _FaqItem(
      category: 'Fertility',
      question: 'Can HerCycle Bloom replace a pregnancy test?',
      answer:
          'No. HerCycle Bloom provides informational fertility insights only. Always use a certified pregnancy test from a pharmacy and follow up with a healthcare provider.',
    ),
    _FaqItem(
      category: 'PCOS',
      question: 'I have irregular cycles — will HerCycle Bloom work for me?',
      answer:
          'Yes. HerCycle Bloom is designed with PCOS users in mind. Predictions adapt to irregular cycles, and the PCOS Analysis tool provides tailored insights based on your symptom patterns rather than calendar regularity.',
    ),
    _FaqItem(
      category: 'PCOS',
      question: 'What does the PCOS risk score mean?',
      answer:
          'The PCOS risk score (Low / Moderate / High) is based on your symptom profile: cycle irregularity, acne, hair changes, weight patterns, and more. It is a wellness indicator, not a medical diagnosis. Always seek professional testing for a confirmed diagnosis.',
    ),
    _FaqItem(
      category: 'Pregnancy Mode',
      question: 'What happens when I enable Pregnancy Mode?',
      answer:
          'The home screen switches to a pregnancy tracker showing your week number, trimester, and fetal development milestones. Cycle tracking is paused. You can switch back anytime from Profile.',
    ),
    _FaqItem(
      category: 'Pregnancy Mode',
      question: 'Will my cycle data be lost when I switch modes?',
      answer:
          'No. Your cycle history is preserved. When you turn off Pregnancy Mode, all prior cycle data remains intact and predictions resume from your last logged data.',
    ),
    _FaqItem(
      category: 'Data & Privacy',
      question: 'Is my health data shared with third parties?',
      answer:
          'No. HerCycle Bloom never sells or shares personal health data. Your data is stored securely and used only to power features within the app. See our Privacy Policy for full details.',
    ),
    _FaqItem(
      category: 'Data & Privacy',
      question: 'Does HerCycle Bloom sync across devices?',
      answer:
          'Yes. HerCycle Bloom syncs via your account across devices. Ensure you are signed in with the same account on all devices. Sync may take a few seconds on first login.',
    ),
    _FaqItem(
      category: 'Premium',
      question: 'What is included in HerCycle Bloom Premium?',
      answer:
          'Premium includes: unlimited AI coach conversations, full cycle regularity trend analytics, advanced PCOS nutrition matrix, detailed pregnancy insights, and an ad-free experience.',
    ),
    _FaqItem(
      category: 'Premium',
      question: 'Can I cancel my subscription?',
      answer:
          'Yes. Cancel anytime via Google Play or App Store > Subscriptions. You retain Premium access until the current billing period ends.',
    ),
    _FaqItem(
      category: 'Premium',
      question: 'How do I restore a previous purchase on a new device?',
      answer:
          'Go to Profile > Restore Purchases. Ensure you are signed in with the same Google or Apple account used for the original purchase.',
    ),
  ];

  List<_FaqItem> get _filtered {
    if (_query.isEmpty) return _faqs;
    final q = _query.toLowerCase();
    return _faqs
        .where((f) =>
            f.question.toLowerCase().contains(q) ||
            f.answer.toLowerCase().contains(q) ||
            f.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final categories = filtered.map((f) => f.category).toSet().toList();

    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: const Text('FAQs'),
        backgroundColor: AppColors.oldLace,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: TextField(
              controller: _controller,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search FAQs…',
                hintStyle: GoogleFonts.montserrat(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                        onPressed: () => setState(() {
                          _query = '';
                          _controller.clear();
                        }),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text('No results for "$_query"',
                            style: GoogleFonts.montserrat(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    children: [
                      for (final cat in categories) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            cat.toUpperCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: AppColors.nudeRose,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: filtered
                                .where((f) => f.category == cat)
                                .map((f) => _FaqTile(item: f))
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String category;
  final String question;
  final String answer;
  const _FaqItem({required this.category, required this.question, required this.answer});
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.question,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.oldLace,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.item.answer,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
          ),
        const Divider(height: 1, indent: 20, endIndent: 20),
      ],
    );
  }
}
