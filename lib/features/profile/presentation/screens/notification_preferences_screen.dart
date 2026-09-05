import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hercycle_bloom/core/app_colors.dart';

// Provider for notification preferences
final notifPrefsProvider =
    StateNotifierProvider<NotifPrefsNotifier, Map<String, bool>>((ref) {
  return NotifPrefsNotifier();
});

class NotifPrefsNotifier extends StateNotifier<Map<String, bool>> {
  static const _keys = [
    'notif_period_reminder',
    'notif_fertile_window',
    'notif_ovulation_day',
    'notif_pregnancy_weekly',
  ];

  NotifPrefsNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, bool>{};
    for (final k in _keys) {
      map[k] = prefs.getBool(k) ?? true;
    }
    state = map;
  }

  Future<void> toggle(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !(state[key] ?? true);
    await prefs.setBool(key, newVal);
    state = {...state, key: newVal};
  }
}

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  static const _items = [
    _NotifItem(
      key: 'notif_period_reminder',
      icon: Icons.water_drop_rounded,
      color: AppColors.periodRed,
      title: 'Period Reminders',
      subtitle: 'Notified 2 days before your predicted period',
    ),
    _NotifItem(
      key: 'notif_fertile_window',
      icon: Icons.spa_rounded,
      color: AppColors.fertileGreen,
      title: 'Fertile Window',
      subtitle: 'Know your best conception window',
    ),
    _NotifItem(
      key: 'notif_ovulation_day',
      icon: Icons.egg_outlined,
      color: AppColors.mistySage,
      title: 'Ovulation Day Alert',
      subtitle: 'Get notified on your peak fertility day',
    ),
    _NotifItem(
      key: 'notif_pregnancy_weekly',
      icon: Icons.child_care_rounded,
      color: AppColors.pregnancyGold,
      title: 'Weekly Pregnancy Update',
      subtitle: 'Baby development highlights each week',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notifPrefsProvider);

    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        backgroundColor: AppColors.oldLace,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose what matters to you',
              style: GoogleFonts.montserrat(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 68),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final isOn = prefs[item.key] ?? true;
                  return _NotifTile(
                    item: item,
                    isOn: isOn,
                    onToggle: () =>
                        ref.read(notifPrefsProvider.notifier).toggle(item.key),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.mistySage.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can also manage notification permissions from your device Settings > HerCycle Bloom.',
                      style: GoogleFonts.montserrat(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _NotifItem {
  final String key;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _NotifItem({
    required this.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

class _NotifTile extends StatelessWidget {
  final _NotifItem item;
  final bool isOn;
  final VoidCallback onToggle;

  const _NotifTile(
      {required this.item, required this.isOn, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, color: item.color, size: 20),
      ),
      title: Text(
        item.title,
        style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        item.subtitle,
        style: GoogleFonts.montserrat(
            color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: Switch.adaptive(
        value: isOn,
        onChanged: (_) => onToggle(),
        activeColor: AppColors.nudeRose,
      ),
    );
  }
}
