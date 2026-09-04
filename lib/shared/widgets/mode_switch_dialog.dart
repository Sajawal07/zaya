import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/app_mode.dart';
import '../../providers/metrics_provider.dart';
import 'app_loader.dart';

/// Confirmation dialog shown before switching between Cycle and Pregnancy modes.
/// Calls [UserMetricsNotifier.updatePregnancyMode] on confirm.
class ModeSwitchDialog extends ConsumerStatefulWidget {
  final AppMode targetMode;

  const ModeSwitchDialog({super.key, required this.targetMode});

  /// Convenience – shows the dialog and awaits the result.
  static Future<void> show(BuildContext context, AppMode targetMode) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ModeSwitchDialog(targetMode: targetMode),
    );
  }

  @override
  ConsumerState<ModeSwitchDialog> createState() => _ModeSwitchDialogState();
}

class _ModeSwitchDialogState extends ConsumerState<ModeSwitchDialog> {
  DateTime? _startDate;
  bool _loading = false;
  String? _error;

  bool get _toPregnancy => widget.targetMode == AppMode.pregnancy;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: (_toPregnancy ? const Color(0xFFB5D5C5) : AppColors.nudeRose).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _toPregnancy ? Icons.child_care_rounded : Icons.favorite_rounded,
                size: 34,
                color: _toPregnancy ? const Color(0xFF4A9373) : AppColors.nudeRose,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              _toPregnancy ? 'Switch to Pregnancy Mode?' : 'Switch to Cycle Mode?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Body
            Text(
              _toPregnancy
                  ? 'Cycle tracking will pause and your pregnancy journey tools will activate. You can switch back anytime.'
                  : 'Your pregnancy journey will be paused and cycle tracking will resume. You can switch back anytime.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),

            // Pregnancy start date picker
            if (_toPregnancy) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickStartDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.nudeRose.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.nudeRose),
                      const SizedBox(width: 12),
                      Text(
                        _startDate == null
                            ? 'Select first day of last period'
                            : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        style: TextStyle(
                          color: _startDate == null ? AppColors.textSecondary : AppColors.textPrimary,
                          fontWeight: _startDate != null ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: AppColors.nudeRose.withValues(alpha: 0.4)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: _toPregnancy ? const Color(0xFF4A9373) : AppColors.nudeRose,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const AppLoader(size: 22, color: Colors.white)
                        : const Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 14)),
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
      lastDate: DateTime.now(),
      helpText: 'First day of last period',
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _confirm() async {
    if (_toPregnancy && _startDate == null) {
      setState(() => _error = 'Please select the first day of your last period.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(userMetricsProvider.notifier).updatePregnancyMode(
        _toPregnancy,
        startDate: _startDate,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }
}
