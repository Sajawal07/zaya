import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../../../models/cycle_log.dart';
import '../../../../providers/database_provider.dart';
import '../../../../providers/cycle_provider.dart';
import '../../../../services/database_service.dart';
import '../../../../services/firestore_sync_service.dart';
import '../../../../services/cycle_update_handler.dart';
import '../../../../services/account_lifecycle_service.dart';
import '../../../../core/cycle_math.dart';
import '../../../../shared/widgets/app_loader.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _currentMonth;
  late DateTime _today;

  // Phase colors per spec
  static const Color _menstrualColor = Color(0xFFD47B8F);
  static const Color _follicularColor = Color(0xFFE7C7F0);
  static const Color _ovulationColor = Color(0xFFFFB98D);
  static const Color _lutealColor = Color(0xFFF4B6C1);
  static const Color _backgroundBase = Color(0xFFFDF1E5);

  // Phase names for legend
  static const List<Map<String, dynamic>> _phases = [
    {'name': 'Menstrual', 'color': _menstrualColor},
    {'name': 'Follicular', 'color': _follicularColor},
    {'name': 'Ovulation', 'color': _ovulationColor},
    {'name': 'Luteal', 'color': _lutealColor},
  ];

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _currentMonth = DateTime(_today.year, _today.month);
  }

  /// Load cycle logs from Isar; if empty (after reinstall), pull from Firestore.
  Future<List<CycleLog>> _loadLogs(DatabaseService db) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    var logs = await db.getAllLogs(user.uid);

    // If local Isar is empty, try loading from Firestore (after reinstall).
    // Do not restore after an intentional Start Fresh / data wipe.
    if (logs.isEmpty) {
      await AccountLifecycleService.ensureEpochLoaded(user.uid);
      final epochAtStart = AccountLifecycleService.currentDataEpoch(user.uid);
      final hydrateBlocked =
          await AccountLifecycleService.isFirestoreHydrateBlocked(user.uid);
      if (hydrateBlocked) return logs;

      try {
        final firestoreService = FirestoreSyncService();
        
        // Try loading cycle logs from Firestore
        final remoteLogs = await firestoreService.loadCycleLogsFromFirestore(user.uid);
        if (AccountLifecycleService.isStaleHydrate(user.uid, epochAtStart) ||
            await AccountLifecycleService.isFirestoreHydrateBlocked(user.uid)) {
          debugPrint('Calendar: skipped hydrate (wipe in progress)');
          return await db.getAllLogs(user.uid);
        }
        if (remoteLogs.isNotEmpty) {
          for (final log in remoteLogs) {
            if (AccountLifecycleService.isStaleHydrate(user.uid, epochAtStart) ||
                await AccountLifecycleService.isFirestoreHydrateBlocked(user.uid)) {
              debugPrint('Calendar: aborted mid-hydrate write (wipe)');
              return await db.getAllLogs(user.uid);
            }
            await db.saveCycleLog(log);
          }
          logs = await db.getAllLogs(user.uid);
        }
        
        // If still no logs, check if user has lastPeriodDate from metrics
        if (logs.isEmpty) {
          if (AccountLifecycleService.isStaleHydrate(user.uid, epochAtStart) ||
              await AccountLifecycleService.isFirestoreHydrateBlocked(user.uid)) {
            return logs;
          }
          final remoteMetrics = await firestoreService.loadUserMetricsFromFirestore(user.uid);
          if (remoteMetrics != null &&
              remoteMetrics.lastPeriodDate != null &&
              !AccountLifecycleService.isStaleHydrate(user.uid, epochAtStart) &&
              !await AccountLifecycleService.isFirestoreHydrateBlocked(user.uid)) {
            // Restore metrics to Isar
            await db.saveUserMetrics(remoteMetrics);
            
            // Normalize the date to local midnight to avoid timezone issues
            final localDate = remoteMetrics.lastPeriodDate!.isUtc
                ? remoteMetrics.lastPeriodDate!.toLocal()
                : remoteMetrics.lastPeriodDate!;
            final normalizedPeriodStart = DateTime(localDate.year, localDate.month, localDate.day);
            
            // Check if a synthetic log already exists for this date
            final existing = await db.getPeriodStartForDate(user.uid, normalizedPeriodStart);
            if (existing == null) {
              // Create a synthetic cycle log for the period start
              final log = CycleLog()
                ..userId = user.uid
                ..date = normalizedPeriodStart
                ..isPeriodStart = true;
              await db.saveCycleLog(log);
            }
            logs = await db.getAllLogs(user.uid);
          }
        }
      } catch (e) {
        debugPrint('Calendar: error loading from Firestore: $e');
      }
    }

    return logs;
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseServiceProvider);
    final refreshKey = ref.watch(calendarRefreshKeyProvider);
    // Watch cycleDataProvider to trigger rebuild when cycle data changes
    ref.watch(cycleDataProvider);

    return Scaffold(
      backgroundColor: _backgroundBase,
      appBar: AppBar(
        title: Text(
          'Calendar',
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
          ref.read(calendarRefreshKeyProvider.notifier).state++;
          await Future.delayed(const Duration(milliseconds: 100));
        },
        child: FutureBuilder<List<CycleLog>>(
          key: ValueKey(refreshKey),
          future: _loadLogs(db),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoaderCentered();
            }

            final logs = snapshot.data ?? [];
            final periodStartDates = logs
                .where((l) => l.isPeriodStart)
                .map((l) => l.date)
                .toList()
              ..sort((a, b) => b.compareTo(a)); // Descending
            final cycleLength = CycleMath.averageCycleLength(periodStartDates);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Month Navigation ──
                  _buildMonthHeader(),
                  // ── Calendar Grid ──
                  _buildCalendarGrid(periodStartDates, cycleLength),
                  const SizedBox(height: 8),
                  // ── Legend ──
                  _buildLegend(),
                  const SizedBox(height: 24),
                  // ── Cycle History List ──
                  _buildHistorySection(logs, periodStartDates),
                  const SizedBox(height: 80), // Clear space for bottom nav
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Month Navigation Header ──────────────────────────────────────────────
  Widget _buildMonthHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
            onPressed: () {
              final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              if (nextMonth.isBefore(DateTime(_today.year, _today.month + 1))) {
                setState(() {
                  _currentMonth = nextMonth;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // ── Calendar Grid ────────────────────────────────────────────────────────
  Widget _buildCalendarGrid(List<DateTime> periodStartDates, int cycleLength) {
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // weekday() returns 1=Monday, 7=Sunday. We want Sunday first.
    int startWeekday = firstDayOfMonth.weekday % 7; // 0=Sunday

    final fertileStart = CycleMath.fertileStartDay(cycleLength);
    final fertileEnd = CycleMath.fertileEndDay(cycleLength);

    // Normalize period start dates to date-only (local time) to avoid
    // timezone mismatches with Firestore Timestamps (which are UTC).
    final normalizedPeriodStarts = periodStartDates
        .map((d) {
          final localDate = d.isUtc ? d.toLocal() : d;
          return DateTime(localDate.year, localDate.month, localDate.day);
        })
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Descending

    DateTime? findLastPeriodStartOnOrBefore(DateTime date) {
      final localDate = date.isUtc ? date.toLocal() : date;
      final normalizedDate = DateTime(localDate.year, localDate.month, localDate.day);
      for (final psd in normalizedPeriodStarts) {
        if (!psd.isAfter(normalizedDate)) return psd;
      }
      return null;
    }

    int calculateCycleDay(DateTime date, DateTime lastPeriodStart) {
      final localDate = date.isUtc ? date.toLocal() : date;
      final localStart = lastPeriodStart.isUtc ? lastPeriodStart.toLocal() : lastPeriodStart;
      final normalizedDate = DateTime(localDate.year, localDate.month, localDate.day);
      final normalizedStart = DateTime(localStart.year, localStart.month, localStart.day);
      return normalizedDate.difference(normalizedStart).inDays + 1;
    }

    Color? getPhaseColor(int cycleDay) {
      if (cycleDay >= 1 && cycleDay <= 5) return _menstrualColor;
      if (cycleDay >= 6 && cycleDay < fertileStart) return _follicularColor;
      if (cycleDay >= fertileStart && cycleDay <= fertileEnd) return _ovulationColor;
      if (cycleDay > fertileEnd && cycleDay <= cycleLength) return _lutealColor;
      return null;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Day-of-week headers ──
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // ── Day cells ──
          ...List.generate(
            ((startWeekday + daysInMonth + 6) ~/ 7), // rows
            (row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: List.generate(7, (col) {
                    final dayIndex = row * 7 + col - startWeekday + 1;
                    if (dayIndex < 1 || dayIndex > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 44));
                    }

                    final cellDate = DateTime(year, month, dayIndex);
                    final isToday = cellDate.year == _today.year &&
                        cellDate.month == _today.month &&
                        cellDate.day == _today.day;
                    final isFuture = cellDate.isAfter(_today);

                    // Only color dates up to and including today
                    Color? cellColor;
                    if (!isFuture) {
                      final lastPsd = findLastPeriodStartOnOrBefore(cellDate);
                      if (lastPsd != null) {
                        final cycleDay = calculateCycleDay(cellDate, lastPsd);
                        cellColor = getPhaseColor(cycleDay);
                      }
                    }

                    return Expanded(
                      child: Container(
                        height: 44,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: cellColor ?? Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isToday
                              ? Border.all(color: AppColors.nudeRose, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$dayIndex',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: cellColor != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Legend Row ────────────────────────────────────────────────────────────
  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _phases
            .map((p) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: p['color'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      p['name'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }

  // ── Cycle History Section (reuses existing data & styling) ────────────────
  Widget _buildHistorySection(List<CycleLog> logs, List<DateTime> periodStartDates) {
    final periodStartLogs = logs.where((l) => l.isPeriodStart).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Cycle History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addPastPeriodDate,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.nudeRose,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ),
          if (periodStartLogs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 64,
                      color: AppColors.nudeRose.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No period history yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add past months or log from the Today tab',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...periodStartLogs.map((log) => _LogCard(log: log)),
        ],
      ),
    );
  }

  /// Backfill period starts from previous months only (not current month).
  Future<void> _addPastPeriodDate() async {
    final db = ref.read(databaseServiceProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    // Last day of previous month — current month is excluded.
    final lastOfPrevMonth = DateTime(now.year, now.month, 0);
    final firstAllowed = DateTime(now.year, now.month - 12, 1);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: lastOfPrevMonth,
      firstDate: firstAllowed,
      lastDate: lastOfPrevMonth,
      helpText: 'ADD PAST PERIOD START',
      confirmText: 'ADD',
    );
    if (selectedDate == null || !mounted) return;

    final normalized = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    final existing = await db.getPeriodStartForDate(user.uid, normalized);
    if (existing != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Period already logged for that date.'),
          backgroundColor: Color(0xFFD47A8E),
        ),
      );
      return;
    }

    final nearby = await db.getPeriodStartNearDate(user.uid, normalized, windowDays: 23);
    if (nearby != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Too close to ${nearby.date.month}/${nearby.date.day}/${nearby.date.year}. '
            'Keep at least 24 days between period starts.',
          ),
          backgroundColor: const Color(0xFFD47A8E),
        ),
      );
      return;
    }

    final log = CycleLog()
      ..userId = user.uid
      ..date = normalized
      ..isPeriodStart = true;
    await db.saveCycleLog(log);
    await CycleUpdateHandler.onCycleDataChanged(ref, user.uid);


    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Past period added for ${normalized.month}/${normalized.day}/${normalized.year}.',
          ),
          backgroundColor: AppColors.periodRed,
        ),
      );
    }
  }
}

// ── Log Card (matching existing Cycle History styling) ─────────────────────
class _LogCard extends StatelessWidget {
  final CycleLog log;

  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Text(
                    DateFormat('EEEE, MMM d').format(log.date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
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
