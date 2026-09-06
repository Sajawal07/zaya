import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/providers/wellness_provider.dart';
import 'package:hercycle_bloom/providers/metrics_provider.dart';
import 'package:hercycle_bloom/providers/database_provider.dart';
import 'package:hercycle_bloom/models/user_metrics.dart';
import 'package:hercycle_bloom/models/cycle_log.dart';
import 'package:hercycle_bloom/services/health_connect_service.dart';
import 'package:hercycle_bloom/services/device_step_service.dart';
import 'package:hercycle_bloom/services/cycle_update_handler.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';

class DailyLogScreen extends ConsumerStatefulWidget {
  const DailyLogScreen({super.key});

  @override
  ConsumerState<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends ConsumerState<DailyLogScreen> {
  // Daily health (flow is symptom data only — never logs period start)
  String? selectedFlow;
  int? _existingCycleLogId;
  bool _existingIsPeriodStart = false;

  // Mood & Energy
  String? selectedMood;
  String? selectedEnergy;

  // Common Symptoms
  List<String> selectedSymptoms = [];

  // Advanced Symptoms
  final List<String> otherSymptoms = [
    'Tender Breasts', 'Backache', 'Fatigue', 'Nausea', 'Insomnia',
  ];

  // Weight & Notes
  String weightText = '';
  String notes = '';

  // Step source tracking
  StepSource _stepSource = StepSource.none;
  bool _isConnecting = false;
  String? _healthError;
  StreamSubscription<int>? _stepSubscription;

  bool _isLoading = true;
  bool _hasExistingLog = false;

  final List<String> flowOptions = ['Light', 'Medium', 'Heavy'];
  final List<String> moodOptions = ['Happy', 'Anxious', 'Moody'];
  final List<String> energyOptions = ['Energetic', 'Tired'];
  final List<String> topSymptoms = ['Cramps', 'Headache', 'Bloating'];

  @override
  void initState() {
    super.initState();
    _loadExistingLogs();
    _autoConnectBestSource();
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    DeviceStepService.stopListening();
    super.dispose();
  }

  Future<void> _loadExistingLogs() async {
    final db = ref.read(databaseServiceProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final today = DateTime.now();

    final cycleLogs = await db.getAllLogs(user.uid);
    final cycleToday = cycleLogs.isEmpty ? null : cycleLogs.firstWhere(
      (l) => l.date.year == today.year && l.date.month == today.month && l.date.day == today.day,
      orElse: () => CycleLog()..id = -1..userId = user.uid,
    );

    final wellnessToday = await db.getWellnessLogForDate(user.uid, today);

    if (mounted) {
      setState(() {
        if (cycleToday != null && cycleToday.id != -1) {
          _hasExistingLog = true;
          _existingCycleLogId = cycleToday.id;
          _existingIsPeriodStart = cycleToday.isPeriodStart;
          selectedFlow = cycleToday.flow;
          selectedMood = cycleToday.mood;
          selectedEnergy = cycleToday.energy;
          selectedSymptoms = List.from(cycleToday.symptoms ?? []);
          notes = cycleToday.notes ?? '';
        }
        if (wellnessToday != null) {
          _hasExistingLog = true;
          if (wellnessToday.weight != null) {
            weightText = wellnessToday.weight!.toStringAsFixed(1);
          }
        }
        _isLoading = false;
      });
    }
  }

  /// Auto-connect: try Health Connect first, then device sensor.
  Future<void> _autoConnectBestSource() async {
    // 1) Try Health Connect
    try {
      final hcAvailable = await HealthConnectService.isAvailable();
      if (hcAvailable) {
        final hasPermission = await HealthConnectService.hasPermission();
        if (hasPermission) {
          _startHealthConnect();
          return;
        }
      }
    } catch (_) {}

    // 2) Try device step sensor — request permission FIRST
    try {
      final hasPermission = await DeviceStepService.requestPermission();
      if (hasPermission) {
        final sensorAvailable = await DeviceStepService.isSensorAvailable();
        if (sensorAvailable) {
          _startDeviceSensor();
          return;
        }
      }
    } catch (_) {}

    // 3) No automatic source — manual entry
    if (mounted) {
      setState(() {
        _stepSource = StepSource.none;
      });
    }
  }

  void _startHealthConnect() {
    _stepSubscription?.cancel();
    DeviceStepService.stopListening();
    setState(() {
      _stepSource = StepSource.healthConnect;
    });
    // Health Connect data was already fetched during permission grant;
    // no continuous stream needed.
  }

  void _startDeviceSensor() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _stepSubscription?.cancel();
    DeviceStepService.startListening(uid);
    _stepSubscription = DeviceStepService.stepStream.listen((steps) {
      if (mounted && steps > 0) {
        ref.read(wellnessProvider.notifier).logWellness(steps: steps);
      }
    });
    setState(() {
      _stepSource = StepSource.deviceSensor;
    });
  }

  // ── Connection flow ──────────────────────────────────────────────────────

  Future<void> _toggleConnect() async {
    // If already connected, disconnect
    if (_stepSource != StepSource.none) {
      _disconnect();
      return;
    }

    setState(() {
      _isConnecting = true;
      _healthError = null;
    });

    // Try Health Connect first
    try {
      final hcAvailable = await HealthConnectService.isAvailable();
      if (hcAvailable) {
        final authorized = await HealthConnectService.requestPermissions();
        if (authorized) {
          final healthData = await HealthConnectService.fetchTodayData();
          if (healthData != null) {
            final wellnessNotifier = ref.read(wellnessProvider.notifier);
            if (healthData.steps != null && healthData.steps! > 0) {
              wellnessNotifier.logWellness(steps: healthData.steps);
            }
            if (healthData.workoutMinutes != null && healthData.workoutMinutes! > 0) {
              wellnessNotifier.logWellness(workout: healthData.workoutMinutes);
            }
            if (healthData.sleepHours != null && healthData.sleepHours! > 0) {
              wellnessNotifier.logWellness(sleepHours: healthData.sleepHours);
            }
          }
          _startHealthConnect();
          setState(() => _isConnecting = false);
          return;
        }
      }
    } catch (_) {}

    // Fall back to device sensor — request permission FIRST
    try {
      final hasPermission = await DeviceStepService.requestPermission();
      if (hasPermission) {
        final sensorAvailable = await DeviceStepService.isSensorAvailable();
        if (sensorAvailable) {
          _startDeviceSensor();
          setState(() => _isConnecting = false);
          return;
        }
      }
    } catch (_) {}

    // No source available
    setState(() {
      _isConnecting = false;
      _healthError = 'Steps aren\'t available automatically on this device. You can still log them manually below.';
    });
  }

  void _disconnect() {
    _stepSubscription?.cancel();
    DeviceStepService.stopListening();
    setState(() {
      _stepSource = StepSource.none;
      _healthError = null;
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final wellness = ref.watch(wellnessProvider);
    final metrics = ref.watch(userMetricsProvider).value;
    final log = wellness.todayLog;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Daily Wellness Log', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (_hasExistingLog)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: _isLoading
          ? const AppLoaderCentered()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Flow (health symptom only — period start is logged on Home) ──
                  _buildSectionTitle('Flow'),
                  _buildCard([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Optional — does not start or reset your cycle. Use Log Period Start on Home for that.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
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
                                  setState(() => selectedFlow = selected ? flow : null);
                                },
                                selectedColor: AppColors.periodRed.withValues(alpha: 0.2),
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.periodRed : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Mood & Energy ────────────────────────────────────────
                  _buildSectionTitle('Mood & Energy'),
                  _buildCard([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mood', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                          const SizedBox(height: 8),
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
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.nudeRose : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Text('Energy Level', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                          const SizedBox(height: 8),
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
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.pregnancyGold : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Symptom Control ──────────────────────────────────────
                  _buildSectionTitle('Symptom Control'),
                  _buildCard([
                    _buildSliderTile(
                      label: 'Cramps Intensity',
                      value: log?.crampsLevel.toDouble() ?? 0,
                      onChanged: (v) => ref.read(wellnessProvider.notifier).logWellness(cramps: v.toInt()),
                    ),
                    _buildSwitchTile(
                      label: 'Bloating',
                      value: log?.bloating ?? false,
                      onChanged: (v) => ref.read(wellnessProvider.notifier).logWellness(bloating: v),
                    ),
                    _buildSliderTile(
                      label: 'Mood Swings',
                      value: log?.moodSwingLevel.toDouble() ?? 0,
                      onChanged: (v) => ref.read(wellnessProvider.notifier).logWellness(moodSwings: v.toInt()),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Common Symptoms ──────────────────────────────────────
                  _buildSectionTitle('Common Symptoms'),
                  _buildCard([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [...topSymptoms, ...otherSymptoms].map((symptom) {
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
                            selectedColor: AppColors.mistySage.withValues(alpha: 0.3),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.mistySage : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Lifestyle & Energy ───────────────────────────────────
                  _buildSectionTitle('Lifestyle & Energy'),
                  _buildCard([
                    _buildSliderTile(
                      label: 'Diet Score (Junk vs Protein)',
                      value: log?.dietScore.toDouble() ?? 5,
                      onChanged: (v) => ref.read(wellnessProvider.notifier).logWellness(dietScore: v.toInt()),
                    ),
                    _buildCounterTile(
                      label: 'Water Intake (Glasses)',
                      value: log?.waterIntake ?? 0,
                      onChanged: (v) => ref.read(wellnessProvider.notifier).logWellness(water: v),
                    ),
                    _buildSliderTile(
                      label: 'Stress Level',
                      value: log?.stressLevel.toDouble() ?? 0,
                      onChanged: (v) => ref.read(wellnessProvider.notifier).logWellness(stress: v.toInt()),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Activity & Sleep ─────────────────────────────────────
                  _buildSectionTitle('Activity & Sleep'),
                  _buildCard([
                    _buildStepsTile(log),
                    _buildInputTile(
                      label: 'Workout Minutes',
                      value: (log?.workoutMinutes ?? 0).toString(),
                      icon: Icons.fitness_center_rounded,
                      onChanged: (v) => ref.read(wellnessProvider.notifier).logWellness(workout: int.tryParse(v)),
                    ),
                    _buildInputTile(
                      label: 'Sleep Hours',
                      value: (log?.sleepHours ?? 0).toStringAsFixed(1),
                      icon: Icons.bedtime_outlined,
                      onChanged: (v) => ref.read(wellnessProvider.notifier).logWellness(sleepHours: double.tryParse(v)),
                    ),
                  ]),

                  const SizedBox(height: 16),
                  _buildSyncBanner(),

                  // ── PCOS Markers ────────────────────────────────────────
                  if (metrics?.healthMode == HealthMode.pcos) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('PCOS Markers'),
                    _buildCard([
                      _buildSwitchTile(
                        label: 'Acne / Breakouts',
                        value: log?.acne ?? false,
                        onChanged: (v) => ref.read(wellnessProvider.notifier).logWellness(acne: v),
                      ),
                      _buildSwitchTile(
                        label: 'Hair Thinning',
                        value: log?.hairThinning ?? false,
                        onChanged: (v) => ref.read(wellnessProvider.notifier).logWellness(hairThinning: v),
                      ),
                      _buildSwitchTile(
                        label: 'Hirsutism (Facial Hair)',
                        value: log?.facialHair ?? false,
                        onChanged: (v) => ref.read(wellnessProvider.notifier).logWellness(facialHair: v),
                      ),
                    ]),
                  ],

                  const SizedBox(height: 24),

                  // ── Weight & Notes ───────────────────────────────────────
                  _buildSectionTitle('Weight & Notes'),
                  _buildCard([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
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
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: TextEditingController(text: notes),
                            onChanged: (val) => setState(() => notes = val),
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Any specific notes for today?',
                              hintStyle: const TextStyle(fontSize: 13),
                              labelText: 'Notes',
                              labelStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.notes_rounded, size: 18),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // ── Save Button ──────────────────────────────────────────
                  ElevatedButton(
                    onPressed: _saveLog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.nudeRose,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Save Daily Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  // ── Steps tile with source label ─────────────────────────────────────────

  Widget _buildStepsTile(dynamic log) {
    return ListTile(
      leading: const Icon(Icons.directions_walk_rounded, color: AppColors.nudeRose),
      title: Row(
        children: [
          const Text('Steps', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          _buildStepSourceBadge(),
        ],
      ),
      trailing: SizedBox(
        width: 60,
        child: TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          controller: TextEditingController(text: (log?.steps ?? 0).toString()),
          decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
          onSubmitted: (v) => ref.read(wellnessProvider.notifier).logWellness(steps: int.tryParse(v)),
        ),
      ),
    );
  }

  Widget _buildStepSourceBadge() {
    String label;
    Color color;
    IconData icon;

    switch (_stepSource) {
      case StepSource.healthConnect:
        label = 'Health Connect';
        color = const Color(0xFF4A9373);
        icon = Icons.check_circle_rounded;
        break;
      case StepSource.deviceSensor:
        label = 'Device sensor';
        color = AppColors.pregnancyGold;
        icon = Icons.sensors_rounded;
        break;
      case StepSource.none:
        label = 'Manual entry';
        color = AppColors.textSecondary;
        icon = Icons.edit_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  // ── Sync banner ──────────────────────────────────────────────────────────

  Widget _buildSyncBanner() {
    String bannerText;
    IconData bannerIcon;

    switch (_stepSource) {
      case StepSource.healthConnect:
        bannerText = 'Connected to Health Connect. Activity data syncs automatically.';
        bannerIcon = Icons.check_circle_rounded;
        break;
      case StepSource.deviceSensor:
        bannerText = 'Tracking steps via device sensor. Workout and sleep require manual entry.';
        bannerIcon = Icons.sensors_rounded;
        break;
      case StepSource.none:
        bannerText = 'Connect for automatic step tracking, or log manually below.';
        bannerIcon = Icons.sync_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A9373).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A9373).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(bannerIcon, color: const Color(0xFF4A9373)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(bannerText, style: const TextStyle(fontSize: 12, height: 1.4)),
              ),
              if (_isConnecting)
                const AppLoader(size: 20)
              else
                TextButton(
                  onPressed: _toggleConnect,
                  child: Text(_stepSource != StepSource.none ? 'Disconnect' : 'Connect'),
                ),
            ],
          ),
          if (_healthError != null) ...[
            const SizedBox(height: 8),
            Text(
              _healthError!,
              style: TextStyle(fontSize: 11, color: AppColors.error, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  // ── Save / Delete ────────────────────────────────────────────────────────

  Future<void> _saveLog() async {
    final db = ref.read(databaseServiceProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final cycleLog = CycleLog()
      ..userId = user.uid
      ..date = DateTime(today.year, today.month, today.day)
      ..flow = selectedFlow
      ..mood = selectedMood
      ..energy = selectedEnergy
      ..symptoms = selectedSymptoms
      // Preserve an existing period-start flag; daily log never creates one.
      ..isPeriodStart = _existingIsPeriodStart
      ..notes = notes;
    if (_existingCycleLogId != null) {
      cycleLog.id = _existingCycleLogId!;
    }
    await db.saveCycleLog(cycleLog);
    await CycleUpdateHandler.onCycleDataChanged(ref, user.uid);

    final weight = double.tryParse(weightText);
    if (weight != null) {
      await ref.read(wellnessProvider.notifier).logWellness(weight: weight);
      final metrics = await db.getUserMetrics(user.uid);
      if (metrics != null) {
        metrics.weight = weight;
        metrics.lastUpdated = DateTime.now();
        await db.saveUserMetrics(metrics);
        ref.invalidate(userMetricsProvider);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily log saved successfully!'),
          backgroundColor: AppColors.fertileGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
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
                final today = DateTime.now();
                final start = DateTime(today.year, today.month, today.day);
                final todayLog = await db.getLogForDate(user.uid, start);
                if (todayLog != null) {
                  await db.deleteCycleLogById(todayLog.id);
                  await CycleUpdateHandler.onCycleDataChanged(ref, user.uid);
                }
              }
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }


  // ── Shared UI Builders ─────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSliderTile({required String label, required double value, required ValueChanged<double> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(value.toInt().toString(), style: const TextStyle(color: AppColors.nudeRose, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: AppColors.nudeRose,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({required String label, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile.adaptive(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      value: value,
      activeColor: AppColors.nudeRose,
      onChanged: onChanged,
    );
  }

  Widget _buildCounterTile({required String label, required int value, required ValueChanged<int> onChanged}) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => onChanged(value > 0 ? value - 1 : 0)),
          Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => onChanged(value + 1)),
        ],
      ),
    );
  }

  Widget _buildInputTile({required String label, required String value, required IconData icon, required ValueChanged<String> onChanged}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.nudeRose),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: SizedBox(
        width: 60,
        child: TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          controller: TextEditingController(text: value),
          decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
          onSubmitted: onChanged,
        ),
      ),
    );
  }
}
