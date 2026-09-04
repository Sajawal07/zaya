import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hercycle_bloom/providers/sync_provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_mode.dart';
// Cycle Mode screens
import 'home_screen.dart';
import '../../../cycle/presentation/screens/calendar_screen.dart';
import '../../../nourish/presentation/screens/nourish_screen.dart';
import '../../../insights/presentation/screens/insights_screen.dart';
// Pregnancy Mode screens
import '../../../pregnancy/presentation/screens/pregnancy_home_screen.dart';
import '../../../pregnancy/presentation/screens/baby_screen.dart';
import '../../../pregnancy/presentation/screens/pregnancy_health_screen.dart';
// Shared
import '../../../ai/presentation/screens/ai_chat_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../health/presentation/widgets/health_gate_wrapper.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;
  AppMode? _lastMode;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(firestoreSyncServiceProvider).updateFCMToken());
  }

  // ── Screen lists (same index structure for both modes) ───────────────────

  static const _cycleScreens = [
    HomeScreen(),
    CalendarScreen(),
    HealthGateWrapper(child: NourishScreen()),
    HealthGateWrapper(child: InsightsScreen()),
    ProfileScreen(),
  ];

  static const _pregnancyScreens = [
    PregnancyHomeScreen(),
    BabyScreen(),
    HealthGateWrapper(child: PregnancyHealthScreen()),
    HealthGateWrapper(child: InsightsScreen()),
    ProfileScreen(),
  ];

  // ── Nav item definitions ─────────────────────────────────────────────────

  static const _cycleNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Today',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today_rounded),
      label: 'Calendar',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.restaurant_menu_outlined),
      activeIcon: Icon(Icons.restaurant_menu_rounded),
      label: 'Health',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.insights_outlined),
      activeIcon: Icon(Icons.insights_rounded),
      label: 'Insights',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      activeIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  static const _pregnancyNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Today',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.child_care_rounded),
      activeIcon: Icon(Icons.child_care_rounded),
      label: 'Baby',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite_outline_rounded),
      activeIcon: Icon(Icons.favorite_rounded),
      label: 'Health',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart_rounded),
      activeIcon: Icon(Icons.bar_chart_rounded),
      label: 'Insights',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      activeIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appModeProvider);

    // Reset tab index on mode switch to prevent showing wrong content
    if (_lastMode != null && _lastMode != mode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedIndex = 0);
      });
    }
    _lastMode = mode;

    final screens = mode == AppMode.cycle ? _cycleScreens : _pregnancyScreens;
    final navItems = mode == AppMode.cycle ? _cycleNavItems : _pregnancyNavItems;

    // Active colour adapts to mode
    final activeColor = mode == AppMode.pregnancy ? const Color(0xFF4A9373) : AppColors.nudeRose;

    // The AI sparkle FAB only makes sense on screens that surface an AI action
    // (Health Coach chat, hormonal profile, nutrition recommendations, Insights).
    // Cycle mode: Today(0), Nourish(2), Insights(3).  Pregnancy mode: Insights(3).
    final bool showAiFab = mode == AppMode.cycle
        ? _selectedIndex == 0 || _selectedIndex == 2 || _selectedIndex == 3
        : _selectedIndex == 3;

    return Scaffold(
      body: Stack(
        children: [
          // ── Main content ──────────────────────────────────────────────
          IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),

          // ── FAB: HerCycle Bloom AI (only on AI-enabled screens) ────────────────
          if (showAiFab)
            Positioned(
              right: 16,
              // Clear margin above the bottom nav; lift above an open keyboard.
              bottom: 80 + MediaQuery.of(context).viewInsets.bottom,
              child: _HerCycleBloomAiFab(),
            ),
        ],
      ),

      // ── Mode badge in nav bar ────────────────────────────────────────
      bottomNavigationBar: _ModeAwareNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: navItems,
        activeColor: activeColor,
        mode: mode,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HerCycle Bloom AI Floating Action Button
// ─────────────────────────────────────────────────────────────────────────────

class _HerCycleBloomAiFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const AiChatScreen(),
        ),
      ),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.nudeRose, Color(0xFFD4607A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.nudeRose.withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mode-Aware Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────

class _ModeAwareNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final Color activeColor;
  final AppMode mode;

  const _ModeAwareNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.activeColor,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Mode indicator strip ──────────────────────────────────────
          Container(
            width: double.infinity,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: mode == AppMode.pregnancy
                    ? [const Color(0xFF4A9373), const Color(0xFF6DB99A)]
                    : [AppColors.nudeRose, const Color(0xFFE8AABB)],
              ),
            ),
          ),
          BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: activeColor,
            unselectedItemColor: AppColors.textSecondary,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: items,
          ),
        ],
      ),
    );
  }
}
