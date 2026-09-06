import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../../../models/cycle_log.dart';

import '../../../../providers/database_provider.dart';

import '../../../../services/cycle_update_handler.dart';
import '../../../../shared/widgets/app_loader.dart';


class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: Text(
          'Cycle History',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                color: AppColors.textPrimary,
              ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(databaseServiceProvider);
          // Wait a bit for the future to be ready
          await Future.delayed(const Duration(milliseconds: 100));
        },
        child: FutureBuilder<List<CycleLog>>(
          future: db.getAllLogs(FirebaseAuth.instance.currentUser?.uid ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoaderCentered();
            }

            final logs = snapshot.data ?? [];

            if (logs.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 80,
                          color: AppColors.nudeRose.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No logs yet',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start tracking your cycle from the Home screen!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return _LogCard(log: log);
              },
            );
          },
        ),
      ),
    );
  }
}

class _LogCard extends ConsumerWidget {
  final CycleLog log;

  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(log.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (log.isPeriodStart)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.nudeRose.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Period Start',
                          style: TextStyle(
                            color: AppColors.nudeRose,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (log.isPeriodStart) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_calendar, size: 20),
                        color: AppColors.nudeRose,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final newDate = await showDatePicker(
                            context: context,
                            initialDate: log.date,
                            firstDate: DateTime.now().subtract(const Duration(days: 60)),
                            lastDate: DateTime.now(),
                          );
                          if (newDate != null && newDate != log.date && context.mounted) {
                            final db = ref.read(databaseServiceProvider);
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;

                            final duplicate = await db.getPeriodStartForDate(user.uid, newDate);
                            if (duplicate != null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Period already logged for that date.'),
                                    backgroundColor: Color(0xFFD47A8E),
                                  ),
                                );
                              }
                              return;
                            }

                            await db.updateCycleLogDate(log.id, newDate);
                            await CycleUpdateHandler.onCycleDataChanged(ref, user.uid);


                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Period date updated to ${newDate.month}/${newDate.day}/${newDate.year}.'),
                                  backgroundColor: AppColors.periodRed,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (log.flow != null || log.mood != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (log.flow != null)
                    _MetricChip(
                      icon: Icons.water_drop_rounded,
                      label: log.flow!,
                      color: AppColors.nudeRose,
                    ),
                  if (log.mood != null)
                    _MetricChip(
                      icon: Icons.emoji_emotions_rounded,
                      label: log.mood!,
                      color: AppColors.mistySage,
                    ),
                ],
              ),
            ],
            if (log.symptoms != null && log.symptoms!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: log.symptoms!.map((s) => _SymptomChip(label: s)).toList(),
              ),
            ],
            if (log.notes != null && log.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                log.notes!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomChip extends StatelessWidget {
  final String label;

  const _SymptomChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mistySage.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
