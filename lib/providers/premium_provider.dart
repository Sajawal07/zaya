import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';
import '../core/premium_limits.dart';

const premiumTestEmails = [
  "sarkrar48@gmail.com",
  "hercyclebloom.test@gmail.com",
];

final remotePremiumFlagProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    return data['isPremium'] == true;
  });
});

final isPremiumProvider = Provider<bool>((ref) {
  // During free launch: everyone has premium access (all features unlocked)
  if (isFreeLaunch) return true;

  final user = ref.watch(currentUserProvider);

  // Unauthenticated users are never premium (prevents cross-account leak).
  if (user == null) return false;

  // Hardcoded test email always premium
  if (user.email != null &&
      premiumTestEmails.contains(user.email!.toLowerCase())) {
    return true;
  }

  // Remote Firestore flag (authoritative persistent entitlement).
  // skipLoadingOnReload/Refresh keeps the prior settled value during a
  // post-purchase invalidate so UI does not briefly flash free/non-premium.
  final remoteFlagAsync = ref.watch(remotePremiumFlagProvider);
  return remoteFlagAsync.when(
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: (value) => value,
    loading: () => false,
    error: (_, __) => false,
  );
});
