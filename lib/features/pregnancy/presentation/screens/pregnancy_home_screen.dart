import 'package:flutter/material.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/features/pregnancy/domain/pregnancy_service.dart';
import 'package:hercycle_bloom/features/home/presentation/widgets/cycle_dial_painter.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';
import 'appointments_screen.dart';
import 'kick_counter_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hercycle_bloom/providers/pregnancy_provider.dart';
import 'package:hercycle_bloom/providers/database_provider.dart';
import 'package:hercycle_bloom/providers/metrics_provider.dart';
import 'package:hercycle_bloom/models/pregnancy_data.dart';

class PregnancyHomeScreen extends ConsumerWidget {
  const PregnancyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeJourneyAsync = ref.watch(activePregnancyProvider);
    
    return activeJourneyAsync.when(
      loading: () => const Scaffold(body: AppLoaderCentered()),
      error: (e, _) => Scaffold(body: Center(child: Text('Error loading pregnancy data: $e'))),
      data: (journey) {
        if (journey == null) {
          return _PregnancyOnboarding();
        }

        final startDate = journey.startDate.toLocal();
        final progress = PregnancyService.calculateProgress(lastPeriodDate: startDate);
        final int currentWeek = progress['week']!;
        final int currentDay = progress['day']!;
        final weekInfo = PregnancyService.getWeekInfo(currentWeek);
        // Completion percentage of the 40-week pregnancy journey.
        final int weekPct = ((currentWeek / 40.0) * 100).clamp(0.0, 100.0).round();

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 14),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pregnancy Journey',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Week $currentWeek, Day $currentDay',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _editStartDate(context, ref, journey),
                        icon: const Icon(Icons.edit_calendar_rounded, color: AppColors.mistySage, size: 28),
                        tooltip: 'Edit Start Date',
                      ),
                    ],
                  ),
                ),
          
          const SizedBox(height: 24),


          // Main Dial
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(280, 280),
                  painter: CycleDialPainter(
                    currentDay: currentWeek, // Reuse field for weeks
                    cycleLength: 40, // 40 weeks total
                    isPregnancyMode: true,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.pregnancyGold.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.child_care_rounded,
                        size: 48,
                        color: AppColors.pregnancyGold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$weekPct% complete',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${40 - currentWeek} weeks',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'to go',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Baby Size Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pregnancyGold.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Fruit Icon Representation
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.pregnancyGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      weekInfo.babyEmoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Baby is the size of a',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        weekInfo.babySizeComparison,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weekInfo.babyDevelopmentHighlight,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tools Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildToolCard(
                    context,
                    title: 'Kick Counter',
                    icon: Icons.touch_app_rounded,
                    color: AppColors.nudeRose,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const KickCounterScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildToolCard(
                    context,
                    title: 'Appointments',
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.mistySage,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tip Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.oldLace,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.mistySage.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tips_and_updates_outlined, color: AppColors.mistySage),
                    const SizedBox(height: 8),
                    Text(
                      ' Weekly Tip',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.mistySage,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  weekInfo.symptomTip,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editStartDate(BuildContext context, WidgetRef ref, PregnancyJourney journey) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: journey.startDate.toLocal(),
      firstDate: DateTime.now().subtract(const Duration(days: 300)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final db = ref.read(databaseServiceProvider);
      journey.startDate = picked.toUtc();
      journey.dueDate = picked.add(const Duration(days: 280)).toUtc();
      await db.savePregnancyJourney(journey);
      
      // Update metrics too for quick lookup
      await ref.read(userMetricsProvider.notifier).updatePregnancyMode(true, startDate: picked);
      
      // Refresh providers
      ref.invalidate(activePregnancyProvider);
    }
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PregnancyOnboarding extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PregnancyOnboarding> createState() => _PregnancyOnboardingState();
}

class _PregnancyOnboardingState extends ConsumerState<_PregnancyOnboarding> {
  DateTime? _selectedLmp;
  bool _isLoading = false;

  void _submit() async {
    if (_selectedLmp == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(userMetricsProvider.notifier).updatePregnancyMode(true, startDate: _selectedLmp);
      ref.invalidate(activePregnancyProvider);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.pregnant_woman_rounded,
                size: 80,
                color: AppColors.pregnancyGold,
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to your\nPregnancy Journey',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'To give you the best week-by-week guidance, when was the first day of your last period?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 30)),
                    firstDate: DateTime.now().subtract(const Duration(days: 300)),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.pregnancyGold,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() => _selectedLmp = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedLmp == null 
                          ? AppColors.mistySage.withValues(alpha: 0.3) 
                          : AppColors.pregnancyGold,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedLmp == null 
                            ? 'Select Last Period Date' 
                            : '${_selectedLmp!.day}/${_selectedLmp!.month}/${_selectedLmp!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _selectedLmp == null ? FontWeight.normal : FontWeight.bold,
                          color: _selectedLmp == null ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_rounded, 
                        color: _selectedLmp == null ? AppColors.textSecondary : AppColors.pregnancyGold,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: (_selectedLmp == null || _isLoading) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pregnancyGold,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: AppColors.mistySage.withValues(alpha: 0.3),
                ),
                child: _isLoading 
                    ? const AppLoader(size: 22, color: Colors.white)
                    : const Text(
                        'Start Tracking',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
