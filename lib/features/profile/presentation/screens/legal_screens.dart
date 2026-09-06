import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hercycle_bloom/core/app_colors.dart';

/// A generic scrollable legal document screen used for Privacy Policy,
/// Terms & Conditions, and the Medical Disclaimer.
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final List<LegalSection> sections;
  final Color accentColor;
  final IconData icon;
  final String lastUpdated;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.sections,
    required this.accentColor,
    required this.icon,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.oldLace,
            elevation: 0,
            floating: true,
            pinned: true,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              title: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.15),
                      AppColors.oldLace,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                  child: Row(
                    children: [
                      Icon(icon, color: accentColor, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'Last updated: $lastUpdated',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 60),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final section = sections[index];
                  return _LegalSectionWidget(section: section, accent: accentColor);
                },
                childCount: sections.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LegalSection {
  final String heading;
  final String body;

  const LegalSection({required this.heading, required this.body});
}

class _LegalSectionWidget extends StatelessWidget {
  final LegalSection section;
  final Color accent;

  const _LegalSectionWidget({required this.section, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    section.heading,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              section.body,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Privacy Policy ─────────────────────────────────────────────────────────

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Privacy Policy',
      icon: Icons.shield_outlined,
      accentColor: AppColors.fertileGreen,
      lastUpdated: 'March 2026',
      sections: [
        LegalSection(
          heading: '1. Introduction',
          body:
              'Welcome to HerCycle Bloom ("we", "our", or "us"). This Privacy Policy explains how we collect, use, and protect your personal and health data when you use the HerCycle Bloom application. By using HerCycle Bloom, you agree to the practices described in this policy.',
        ),
        LegalSection(
          heading: '2. Data We Collect',
          body:
              'We collect information you provide directly, including:\n\n'
              '• Account information (name, email address)\n'
              '• Health and body metrics (age, height, weight, BMI)\n'
              '• Cycle and symptom logs (period dates, flow, mood, symptoms)\n'
              '• Pregnancy journey data (start date, week milestones)\n'
              '• App usage data for improving features and performance\n\n'
              'We do NOT collect payment card details — all transactions are processed by Google Play or the Apple App Store.',
        ),
        LegalSection(
          heading: '3. How We Use Your Data',
          body:
              'Your data is used to:\n\n'
              '• Provide cycle predictions, fertility insights, and pregnancy tracking\n'
              '• Power the AI Health Coach with context-aware responses\n'
              '• Identify health patterns relevant to PCOS and hormonal wellbeing\n'
              '• Send push notifications you have opted into\n'
              '• Improve HerCycle Bloom\'s accuracy and features over time\n\n'
              'We do not sell, rent, or trade your health data to third parties for marketing purposes.',
        ),
        LegalSection(
          heading: '4. Data Storage & Security',
          body:
              'Your data is stored securely on Google Firebase servers with industry-standard encryption at rest and in transit. Local data on your device is stored using encrypted local databases. Access is restricted to authorized personnel only.',
        ),
        LegalSection(
          heading: '5. Data Retention',
          body:
              'We retain your data for as long as your account is active. You may request permanent deletion of your account and all associated data at any time from Profile > Delete Account, or by contacting sajawal0005@gmail.com.',
        ),
        LegalSection(
          heading: '6. Third-Party Services',
          body:
              'HerCycle Bloom uses the following third-party services which have their own privacy policies:\n\n'
              '• Google Firebase (Authentication, Firestore, Cloud Messaging)\n'
              '• Google Generative AI (AI coaching features – Premium only)\n'
              '• Google Play / Apple App Store (In-app purchases)\n\n'
              'These services operate under their respective privacy standards.',
        ),
        LegalSection(
          heading: '7. Children\'s Privacy',
          body:
              'HerCycle Bloom is not intended for users under the age of 13. We do not knowingly collect personal data from children under 13. If you believe a child has provided us with their data, please contact us immediately.',
        ),
        LegalSection(
          heading: '8. Your Rights',
          body:
              'Depending on your location, you may have rights under GDPR, CCPA, or similar laws to access, correct, or delete your personal data. Contact us at sajawal0005@gmail.com to exercise these rights.',
        ),
        LegalSection(
          heading: '9. Changes to This Policy',
          body:
              'We may update this Privacy Policy periodically. Significant changes will be notified via in-app alert. Continued use of HerCycle Bloom after updates constitutes acceptance of the revised policy.',
        ),
        LegalSection(
          heading: '10. Contact Us',
          body:
              'For any privacy-related inquiries, email us at: sajawal0005@gmail.com\n\nWe aim to respond within 5 business days.',
        ),
      ],
    );
  }
}

// ─── Terms & Conditions ──────────────────────────────────────────────────────

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Terms & Conditions',
      icon: Icons.gavel_rounded,
      accentColor: AppColors.nudeRose,
      lastUpdated: 'March 2026',
      sections: [
        LegalSection(
          heading: '1. Acceptance of Terms',
          body:
              'By downloading, installing, or using the HerCycle Bloom application, you agree to be bound by these Terms and Conditions. If you do not agree, please discontinue use immediately.',
        ),
        LegalSection(
          heading: '2. Eligibility',
          body:
              'HerCycle Bloom is intended for users 13 years of age and older. By using the app, you confirm that you meet this age requirement. Users under 18 should have parental or guardian consent.',
        ),
        LegalSection(
          heading: '3. Account Responsibilities',
          body:
              'You are responsible for:\n\n'
              '• Maintaining the confidentiality of your account credentials\n'
              '• All activity conducted through your account\n'
              '• Providing accurate personal information\n\n'
              'Notify us immediately at sajawal0005@gmail.com of any unauthorized account access.',
        ),
        LegalSection(
          heading: '4. Permitted Use',
          body:
              'HerCycle Bloom is licensed for personal, non-commercial use only. You may not:\n\n'
              '• Copy, modify, or distribute the app or its content\n'
              '• Reverse engineer or decompile any part of the application\n'
              '• Use the app to collect data about other users\n'
              '• Circumvent premium features without a valid subscription',
        ),
        LegalSection(
          heading: '5. Subscription & Payments',
          body:
              'HerCycle Bloom Premium subscriptions are billed through Google Play or the Apple App Store. Subscriptions auto-renew unless cancelled at least 24 hours before the renewal date. Prices are subject to change with notice. We do not offer refunds for unused subscription periods, except as required by applicable law.',
        ),
        LegalSection(
          heading: '6. Limitation of Liability',
          body:
              'HerCycle Bloom is provided "as is" without warranties of any kind. We are not liable for:\n\n'
              '• Health decisions made based on app data\n'
              '• Inaccurate predictions or insights\n'
              '• Data loss due to device failure or account deletion\n'
              '• Indirect, incidental, or consequential damages of any kind\n\n'
              'Our total liability shall not exceed the amount paid for the subscription in the 12 months prior to the claim.',
        ),
        LegalSection(
          heading: '7. Termination',
          body:
              'We reserve the right to suspend or terminate your account if you violate these Terms. You may also delete your account at any time from Profile > Delete Account.',
        ),
        LegalSection(
          heading: '8. Governing Law',
          body:
              'These Terms are governed by and construed in accordance with applicable laws. Any disputes shall be resolved through binding arbitration unless prohibited by law.',
        ),
        LegalSection(
          heading: '9. Changes to Terms',
          body:
              'We reserve the right to update these Terms at any time. Continued use of the app after changes are posted constitutes your acceptance of the new Terms.',
        ),
      ],
    );
  }
}

// ─── Medical Disclaimer ──────────────────────────────────────────────────────

class MedicalDisclaimerScreen extends StatelessWidget {
  const MedicalDisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Medical Disclaimer',
      icon: Icons.local_hospital_outlined,
      accentColor: AppColors.periodRed,
      lastUpdated: 'March 2026',
      sections: [
        LegalSection(
          heading: 'Not Medical Advice',
          body:
              'HerCycle Bloom is a personal wellness and cycle tracking application. The information, insights, predictions, and AI coach responses provided within the app are for informational and educational purposes only.\n\n'
              'Nothing in HerCycle Bloom constitutes, or should be interpreted as, professional medical advice, diagnosis, or treatment. Always consult a qualified healthcare professional for any medical concerns.',
        ),
        LegalSection(
          heading: 'Predictions Are Estimates',
          body:
              'Cycle predictions, fertile window estimates, ovulation dates, and pregnancy due dates are statistical approximations based on the data you provide. They are NOT guaranteed to be accurate for any individual cycle. Many factors — stress, illness, medication, hormonal changes — can alter your cycle in ways no app can fully predict.',
        ),
        LegalSection(
          heading: 'Not a Contraceptive Method',
          body:
              'HerCycle Bloom is NOT a contraceptive tool. The app\'s fertile window and safe day estimations should NOT be used as a method of birth control. Using HerCycle Bloom to avoid pregnancy without additional contraceptive methods carries a HIGH risk of unintended pregnancy.\n\n'
              'Consult your doctor or a sexual health professional for appropriate contraceptive options.',
        ),
        LegalSection(
          heading: 'PCOS & Hormonal Health',
          body:
              'The PCOS risk indicators and hormonal health insights within HerCycle Bloom are based on self-reported symptom patterns. They are intended as a starting point for awareness only.\n\n'
              'A PCOS diagnosis requires clinical evaluation including blood tests, ultrasound, and assessment by a qualified physician. Do not self-diagnose based on HerCycle Bloom\'s insights.',
        ),
        LegalSection(
          heading: 'Pregnancy Guidance',
          body:
              'Pregnancy-related information within HerCycle Bloom is general educational content based on typical fetal development timelines. It does not account for complications, multiple pregnancies, or individual health conditions.\n\n'
              'Regular antenatal care with a licensed healthcare provider is essential during pregnancy. Do not use HerCycle Bloom as a substitute for clinical prenatal visits.',
        ),
        LegalSection(
          heading: 'AI Coach',
          body:
              'The HerCycle Bloom AI Coach provides generalized health information based on broad knowledge and your self-reported data. It is not a licensed medical professional. Responses may not reflect the most current clinical guidelines.\n\n'
              'Do not make health decisions — including changes to medications or treatment plans — solely based on AI coach responses.',
        ),
        LegalSection(
          heading: 'Seek Emergency Help Immediately',
          body:
              'If you are experiencing a medical emergency, severe symptoms, or believe you or someone else is in danger, please call your local emergency services (e.g., 911, 999, 112) or go to your nearest emergency room immediately.',
        ),
        LegalSection(
          heading: 'Limitation of Liability',
          body:
              'HerCycle Bloom and its developers, partners, and employees shall not be held liable for any health outcomes, medical decisions, or consequences resulting from reliance on the app\'s content. Use of HerCycle Bloom is at your own risk.',
        ),
      ],
    );
  }
}
