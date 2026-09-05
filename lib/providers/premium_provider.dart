import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';

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
  final user = ref.watch(currentUserProvider);
  
  // Hardcoded test email always premium
  if (user != null && user.email != null && premiumTestEmails.contains(user.email!.toLowerCase())) {
    return true;
  }

  // Remote Firestore flag
  final remoteFlagAsync = ref.watch(remotePremiumFlagProvider);
  return remoteFlagAsync.value ?? false;
});
