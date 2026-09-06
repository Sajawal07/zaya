import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/app_colors.dart';
import '../../../../models/pregnancy_data.dart';
import '../../../../providers/database_provider.dart';
import 'package:hercycle_bloom/shared/widgets/empty_state.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';

class KickCounterScreen extends ConsumerStatefulWidget {
  const KickCounterScreen({super.key});

  @override
  ConsumerState<KickCounterScreen> createState() => _KickCounterScreenState();
}

class _KickCounterScreenState extends ConsumerState<KickCounterScreen> {
  int _kickCount = 0;
  bool _isActive = false;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = "00:00";

  List<KickLog> _history = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = ref.read(databaseServiceProvider);
    final logs = await db.getKickLogs(user.uid);
    if (mounted) {
      setState(() {
        _history = logs;
        _isLoadingHistory = false;
      });
    }
  }

  void _startSession() {
    setState(() {
      _isActive = true;
      _kickCount = 0;
      _stopwatch.reset();
      _stopwatch.start();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final duration = _stopwatch.elapsed;
      setState(() {
        _elapsedTime = '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    });
  }

  void _logKick() {
    if (!_isActive) return;
    setState(() {
      _kickCount++;
    });
  }

  Future<void> _finishSession() async {
    _stopwatch.stop();
    _timer?.cancel();
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final log = KickLog()
      ..userId = user.uid
      ..date = DateTime.now()
      ..count = _kickCount
      ..duration = _elapsedTime;

    final db = ref.read(databaseServiceProvider);
    await db.saveKickLog(log);

    // Refresh history
    await _loadHistory();

    setState(() {
      _isActive = false;
      _kickCount = 0;
      _elapsedTime = "00:00";
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kick session saved!'), backgroundColor: AppColors.fertileGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: const Text('Kick Counter'),
        backgroundColor: AppColors.oldLace,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Timer Display
            Text(
              _elapsedTime,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppColors.pregnancyGold,
                fontWeight: FontWeight.bold,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isActive ? 'Recording...' : 'Ready to start',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 48),

            // Big Kick Button
            GestureDetector(
              onTap: _isActive ? _logKick : _startSession,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isActive ? AppColors.white : AppColors.nudeRose.withValues(alpha: 0.1),
                  boxShadow: [
                    if (_isActive)
                      BoxShadow(
                        color: AppColors.pregnancyGold.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                  ],
                  border: Border.all(
                    color: _isActive ? AppColors.pregnancyGold : AppColors.nudeRose.withValues(alpha: 0.5),
                    width: _isActive ? 8 : 2, 
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isActive) ...[
                      const Icon(Icons.child_care, size: 60, color: AppColors.pregnancyGold),
                      const SizedBox(height: 16),
                      Text(
                        '$_kickCount',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Kicks',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.play_arrow_rounded, size: 80, color: AppColors.nudeRose),
                      const SizedBox(height: 8),
                      Text(
                        'Start Session',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.nudeRose,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_isActive) ...[
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _finishSession,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Finish Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 48),

            // Recent History
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoadingHistory 
                ? const AppLoaderCentered()
                : _history.isEmpty 
                  ? const EmptyState(
                      icon: Icons.schedule_rounded,
                      title: 'No kicks logged yet',
                      subtitle: "Tap Start Session when baby starts moving to begin tracking!",
                    )
                  : ListView.separated(
                itemCount: _history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final log = _history[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${log.date.day}/${log.date.month} ${log.date.hour}:${log.date.minute.toString().padLeft(2, '0')}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Duration: ${log.duration}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.pregnancyGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${log.count} Kicks',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

