import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/models/cycle_log.dart';
import 'package:hercycle_bloom/providers/database_provider.dart';
import 'package:hercycle_bloom/providers/cycle_provider.dart';
import 'package:hercycle_bloom/providers/wellness_provider.dart';
import 'package:hercycle_bloom/providers/metrics_provider.dart';
import 'package:hercycle_bloom/services/cycle_update_handler.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';

class QuickLogSheet extends ConsumerStatefulWidget {
  const QuickLogSheet({super.key});

  @override
  ConsumerState<QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends ConsumerState<QuickLogSheet> {
  String? selectedFlow;
  String? selectedMood;
  String? selectedEnergy;
  List<String> selectedSymptoms = [];
  String notes = '';
  String weightText = '';
  CycleLog? existingLog;
  bool isLoading = true;
  bool isAdvancedExpanded = false;

  final List<String> flowOptions = ['Light', 'Medium', 'Heavy'];
  final List<String> moodOptions = ['Happy', 'Anxious', 'Moody'];
  final List<String> energyOptions = ['Energetic', 'Tired'];
  final List<String> topSymptoms = ['Cramps', 'Headache', 'Bloating'];
  final List<String> otherSymptoms = [
    'Tender Breasts',
    'Backache',
    'Fatigue',
    'Nausea',
    'Acne',
    'Insomnia',
  ];

  @override
  void initState() {
    super.initState();
    _checkExistingLog();
  }

  Future<void> _checkExistingLog() async {
    final db = ref.read(databaseServiceProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final logs = await db.getAllLogs(user.uid);
    final today = DateTime.now();
    
    final logToday = logs.isEmpty ? null : logs.firstWhere(
      (l) => l.date.year == today.year && l.date.month == today.month && l.date.day == today.day,
      orElse: () => CycleLog()..id = -1..userId = user.uid,
    );

    // Load weight from WellnessLog for today
    final wellnessToday = await db.getWellnessLogForDate(user.uid, today);

    if (logToday != null && logToday.id != -1) {
      if (mounted) {
        setState(() {
          existingLog = logToday;
          selectedFlow = logToday.flow;
          selectedMood = logToday.mood;
          selectedEnergy = logToday.energy;
          selectedSymptoms = List.from(logToday.symptoms ?? []);
          notes = logToday.notes ?? '';
          if (wellnessToday?.weight != null) {
            weightText = wellnessToday!.weight!.toStringAsFixed(1);
          }
          isLoading = false;
        });
      }
    } else {
      // Smart Defaults: Pre-fill from the most recent previous log
      final lastLog = logs.isNotEmpty ? logs.first : null;
      if (mounted) {
        setState(() {
          if (lastLog != null) {
            selectedMood = lastLog.mood;
            selectedEnergy = lastLog.energy;
          }
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(height: 200, child: AppLoaderCentered());
    }

    final bool isAlreadyLogged = existingLog != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.oldLace,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Track Your Day',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your mood, symptoms, and flow to receive personalized insights.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (existingLog != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => _showDeleteConfirmation(),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              if (existingLog != null)
                _buildAlreadyLoggedInfo()
              else ...[
                // Phase Indicator (Auto-Highlight)
                _buildAutoHighlightBanner(),
                
                const SizedBox(height: 24),

                // FLOW SECTION
                _buildSectionHeader('Flow', Icons.water_drop_outlined, AppColors.periodRed),
                Wrap(
                  spacing: 12,
                  children: flowOptions.map((flow) {
                    final isSelected = selectedFlow == flow;
                    return ChoiceChip(
                      label: Text(flow),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => selectedFlow = selected ? flow : null);
                      },
                      selectedColor: AppColors.periodRed.withValues(alpha: 0.2),
                      backgroundColor: AppColors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.periodRed : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                
                // Flow is daily health data only — period start is logged on Home.
                const SizedBox(height: 8),
                Text(
                  'Flow does not start or reset your cycle.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 24),

                // MOOD SECTION
                _buildSectionHeader('Mood', Icons.face_outlined, AppColors.nudeRose),
                Wrap(
                  spacing: 12,
                  children: moodOptions.map((mood) {
                    final isSelected = selectedMood == mood;
                    return ChoiceChip(
                      label: Text(mood),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => selectedMood = selected ? mood : null);
                      },
                      selectedColor: AppColors.nudeRose.withValues(alpha: 0.2),
                      backgroundColor: AppColors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.nudeRose : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // ENERGY SECTION
                _buildSectionHeader('Energy Level', Icons.bolt_outlined, AppColors.pregnancyGold),
                Wrap(
                  spacing: 12,
                  children: energyOptions.map((energy) {
                    final isSelected = selectedEnergy == energy;
                    return ChoiceChip(
                      label: Text(energy),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => selectedEnergy = selected ? energy : null);
                      },
                      selectedColor: AppColors.pregnancyGold.withValues(alpha: 0.2),
                      backgroundColor: AppColors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.pregnancyGold : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // COMMON SYMPTOMS
                _buildSectionHeader('Common Symptoms', Icons.healing_outlined, AppColors.mistySage),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: topSymptoms.map((symptom) {
                    final isSelected = selectedSymptoms.contains(symptom);
                    return FilterChip(
                      label: Text(symptom),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedSymptoms.add(symptom);
                          } else {
                            selectedSymptoms.remove(symptom);
                          }
                        });
                      },
                      selectedColor: AppColors.mistySage.withValues(alpha: 0.3),
                      backgroundColor: AppColors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.mistySage : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // ADVANCED SECTION (COLLAPSIBLE)
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: const Text('Advanced Tracker', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Add notes or other symptoms', style: TextStyle(fontSize: 11)),
                    leading: const Icon(Icons.tune_rounded, size: 20),
                    childrenPadding: const EdgeInsets.all(0),
                    children: [
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: otherSymptoms.map((symptom) {
                                final isSelected = selectedSymptoms.contains(symptom);
                                return FilterChip(
                                  label: Text(symptom, style: const TextStyle(fontSize: 12)),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedSymptoms.add(symptom);
                                      } else {
                                        selectedSymptoms.remove(symptom);
                                      }
                                    });
                                  },
                                  selectedColor: AppColors.mistySage.withValues(alpha: 0.15),
                                  backgroundColor: AppColors.white,
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.mistySage : AppColors.textPrimary,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              controller: TextEditingController(text: weightText),
                              onChanged: (val) => setState(() => weightText = val),
                              decoration: InputDecoration(
                                hintText: 'e.g. 65.5',
                                hintStyle: const TextStyle(fontSize: 13),
                                labelText: 'Weight (kg)',
                                labelStyle: const TextStyle(fontSize: 13),
                                prefixIcon: const Icon(Icons.monitor_weight_outlined, size: 18),
                                filled: true,
                                fillColor: AppColors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              onChanged: (val) => setState(() => notes = val),
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Any specific notes for today?',
                                hintStyle: const TextStyle(fontSize: 13),
                                filled: true,
                                fillColor: AppColors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: () async {
                    await _saveLog();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Saved! Your data will help personalize insights.'),
                          backgroundColor: AppColors.fertileGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.nudeRose,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Complete Check-in', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyLoggedInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.fertileGreen.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.fertileGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.fertileGreen, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Wellness Logged!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You have successfully tracked your data for today. Every entry helps personalize your hormonal insights.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _showDeleteConfirmation(),
            child: const Text(
              'Update or Delete Entry',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Today\'s Log?'),
        content: const Text('This action cannot be undone. Are you sure you want to delete today\'s log?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseServiceProvider);
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if (existingLog != null && existingLog!.id != -1) {
                  await db.deleteCycleLogById(existingLog!.id);
                } else {
                  final today = DateTime.now();
                  final todayLog = await db.getLogForDate(user.uid, DateTime(today.year, today.month, today.day));
                  if (todayLog != null) {
                    await db.deleteCycleLogById(todayLog.id);
                  }
                }
                await CycleUpdateHandler.onCycleDataChanged(ref, user.uid);
              }
              if (mounted) {
                Navigator.pop(context); // Pop dialog
                Navigator.pop(context); // Pop sheet
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLog() async {
    final db = ref.read(databaseServiceProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final log = CycleLog()
      ..userId = user.uid
      ..date = DateTime(today.year, today.month, today.day)
      ..flow = selectedFlow
      ..mood = selectedMood
      ..energy = selectedEnergy
      ..symptoms = selectedSymptoms
      ..isPeriodStart = existingLog?.isPeriodStart ?? false
      ..notes = notes;
    if (existingLog != null && existingLog!.id != -1) {
      log.id = existingLog!.id;
    }
    
    await db.saveCycleLog(log);

    // Save weight to WellnessLog if provided
    final weight = double.tryParse(weightText);
    if (weight != null) {
      await ref.read(wellnessProvider.notifier).logWellness(weight: weight);
      // Sync weight to UserMetrics for BMI calculation
      final metrics = await db.getUserMetrics(user.uid);
      if (metrics != null) {
        metrics.weight = weight;
        metrics.lastUpdated = DateTime.now();
        await db.saveUserMetrics(metrics);
        ref.invalidate(userMetricsProvider);
      }
    }

    await CycleUpdateHandler.onCycleDataChanged(ref, user.uid);
  }


  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoHighlightBanner() {
    final cycleAsync = ref.watch(cycleDataProvider);
    
    return cycleAsync.maybeWhen(
      data: (info) {
        if (info.phase == 'Menstrual') {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.periodRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.periodRed.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.periodRed),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Predicted Period Day: Today is a great day to track your flow.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.periodRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
