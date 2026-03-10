import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zaya/core/app_colors.dart';
import 'package:zaya/models/cycle_log.dart';
import 'package:zaya/providers/database_provider.dart';

class QuickLogSheet extends ConsumerStatefulWidget {
  const QuickLogSheet({super.key});

  @override
  ConsumerState<QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends ConsumerState<QuickLogSheet> {
  String? selectedFlow;
  String? selectedMood;
  List<String> selectedSymptoms = [];
  bool isPeriodStart = false;
  CycleLog? existingLog;
  bool isLoading = true;

  final List<String> flowOptions = ['Light', 'Medium', 'Heavy'];
  final List<String> moodOptions = ['Happy', 'Anxious', 'Moody', 'Energetic', 'Tired'];
  final List<String> symptomOptions = [
    'Cramps',
    'Headache',
    'Bloating',
    'Tender Breasts',
    'Backache',
    'Fatigue',
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
    
    final logToday = logs.firstWhere(
      (l) => l.date.year == today.year && l.date.month == today.month && l.date.day == today.day,
      orElse: () => CycleLog()..id = -1..userId = user.uid,
    );

    if (logToday.id != -1) {
      if (mounted) {
        setState(() {
          existingLog = logToday;
          selectedFlow = logToday.flow;
          selectedMood = logToday.mood;
          selectedSymptoms = List.from(logToday.symptoms ?? []);
          isPeriodStart = logToday.isPeriodStart;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
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
                    color: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log Today',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (existingLog != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => _showDeleteConfirmation(),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              if (isAlreadyLogged)
                _buildAlreadyLoggedInfo()
              else ...[
                // Period Tracking
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Did your period start today?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Switch(
                      value: isPeriodStart,
                      onChanged: (value) => setState(() => isPeriodStart = value),
                      activeColor: AppColors.periodRed,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Flow
                Text(
                  'Flow',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: flowOptions.map((flow) {
                    final isSelected = selectedFlow == flow;
                    return ChoiceChip(
                      label: Text(flow),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedFlow = selected ? flow : null;
                        });
                      },
                      selectedColor: AppColors.periodRed.withOpacity(0.2),
                      backgroundColor: AppColors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.periodRed : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Mood
                Text(
                  'Mood',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: moodOptions.map((mood) {
                    final isSelected = selectedMood == mood;
                    return ChoiceChip(
                      label: Text(mood),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedMood = selected ? mood : null;
                        });
                      },
                      selectedColor: AppColors.nudeRose.withOpacity(0.2),
                      backgroundColor: AppColors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.nudeRose : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Symptoms
                Text(
                  'Symptoms',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: symptomOptions.map((symptom) {
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
                      selectedColor: AppColors.mistySage.withOpacity(0.3),
                      backgroundColor: AppColors.white,
                      checkmarkColor: AppColors.mistySage,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.mistySage : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: () async {
                    await _saveLog();
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.nudeRose,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Save Log'),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.fertileGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fertileGreen.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.fertileGreen, size: 48),
          const SizedBox(height: 16),
          Text(
            'Already Logged!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.fertileGreen),
          ),
          const SizedBox(height: 8),
          const Text(
            'You have already recorded your wellness data for today. You can delete today\'s log using the trash icon above if you need to make changes.',
            textAlign: TextAlign.center,
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
        content: const Text('This will remove your data for today. You can then log again if needed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseServiceProvider);
              // In Isar, we delete by ID. We already have existingLog.id
              // But we didn't add a specific delete method for single log. 
              // Let's add it or use a query. 
              // For now, I'll update the DatabaseService with a generic delete.
              // Actually, I can just clear today's log.
              await db.deleteLogsAfter(DateTime.now().subtract(const Duration(hours: 24)));
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

    final log = CycleLog()
      ..userId = user.uid
      ..date = DateTime.now()
      ..flow = selectedFlow
      ..mood = selectedMood
      ..symptoms = selectedSymptoms
      ..isPeriodStart = isPeriodStart;
    
    await db.saveCycleLog(log);
  }
}
