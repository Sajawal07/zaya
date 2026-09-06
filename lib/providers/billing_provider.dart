import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'auth_provider.dart';
import 'metrics_provider.dart';
import 'premium_provider.dart';
import '../core/premium_limits.dart';

// --- Configuration ---
// One-time non-consumable product ID for Google Play Console
const String premiumUpgradeId = 'premium_upgrade';

const List<String> kProductIds = <String>[
  premiumUpgradeId,
];

class BillingState {
  final bool isAvailable;
  final List<ProductDetails> products;
  final bool isPurchasing;
  final bool isLoadingProducts;
  /// True when Play Billing works but the IAP product is not listed yet
  /// (app not published / product not created / wrong product ID).
  final bool isSetupPending;
  final String? errorMessage;
  final bool isPro;

  BillingState({
    this.isAvailable = false,
    this.products = const [],
    this.isPurchasing = false,
    this.isLoadingProducts = false,
    this.isSetupPending = false,
    this.errorMessage,
    this.isPro = false,
  });

  BillingState copyWith({
    bool? isAvailable,
    List<ProductDetails>? products,
    bool? isPurchasing,
    bool? isLoadingProducts,
    bool? isSetupPending,
    String? errorMessage,
    bool clearError = false,
    bool? isPro,
  }) {
    return BillingState(
      isAvailable: isAvailable ?? this.isAvailable,
      products: products ?? this.products,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isSetupPending: isSetupPending ?? this.isSetupPending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPro: isPro ?? this.isPro,
    );
  }

  /// Safely retrieves the target premium_upgrade product by ID.
  ProductDetails? get premiumUpgradeProduct {
    for (final p in products) {
      if (p.id == premiumUpgradeId) return p;
    }
    return products.isNotEmpty ? products.first : null;
  }
}

class BillingNotifier extends StateNotifier<BillingState> {
  final Ref ref;
  final String? _userId;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  BillingNotifier(this.ref, this._userId) : super(BillingState()) {
    if (!isFreeLaunch) {
      _init();
    }
  }

  Future<void> _init() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      debugPrint("Purchase Stream Error: $error");
      state = state.copyWith(
        isLoadingProducts: false,
        errorMessage: 'Unable to load pricing. Please check your connection and try again.',
      );
    });

    // Hydrate isPro from Firestore-backed premium status without blocking product load.
    unawaited(_hydrateIsProFromPremiumStatus());

    await loadProducts();
  }

  /// Seeds [BillingState.isPro] from the existing Firestore premium system.
  /// Never clears an entitlement to false based on a still-loading remote flag.
  Future<void> _hydrateIsProFromPremiumStatus() async {
    if (_userId == null || FirebaseAuth.instance.currentUser == null) {
      if (mounted) syncIsProFromAuthoritative(false);
      return;
    }

    try {
      // Prefer settled provider value (covers test-email bypass + Firestore).
      final known = ref.read(isPremiumProvider);
      if (known) {
        if (mounted) syncIsProFromAuthoritative(true);
        return;
      }

      final remote = ref.read(remotePremiumFlagProvider);
      if (remote.isLoading) {
        // Wait for first Firestore snapshot; do not block UI / product loading.
        final isPremium = await ref
            .read(remotePremiumFlagProvider.future)
            .timeout(const Duration(seconds: 5), onTimeout: () => false);
        if (!mounted) return;
        // Re-read isPremiumProvider so test-email bypass is included.
        syncIsProFromAuthoritative(ref.read(isPremiumProvider) || isPremium);
        return;
      }

      if (mounted) syncIsProFromAuthoritative(ref.read(isPremiumProvider));
    } catch (e) {
      debugPrint("Premium status hydration failed: $e");
      // Leave isPro unchanged on error — never wipe an existing entitlement.
    }
  }

  /// Keeps [BillingState.isPro] aligned with authoritative premium state.
  /// Skips false-downgrades while the remote flag is still loading (startup /
  /// post-purchase refresh) or errored so entitlements are not wiped by a
  /// loading flicker or transient Firestore failure.
  void syncIsProFromAuthoritative(bool isPremium) {
    if (!mounted) return;
    if (isPremium) {
      if (!state.isPro) {
        state = state.copyWith(isPro: true);
      }
      return;
    }

    final remote = ref.read(remotePremiumFlagProvider);
    if (remote.isLoading || remote.hasError) return;

    if (state.isPro) {
      state = state.copyWith(isPro: false);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(
      isLoadingProducts: true,
      isSetupPending: false,
      clearError: true,
    );

    final available = await _iap.isAvailable();
    if (!available) {
      state = state.copyWith(
        isAvailable: false,
        isLoadingProducts: false,
        isSetupPending: false,
        errorMessage:
            'Google Play Billing is unavailable on this device. Premium purchase will work after the app is on Play Store with a signed release build.',
      );
      return;
    }

    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(kProductIds.toSet());
      if (response.error != null) {
        debugPrint("Query product details error: ${response.error!.message}");
        state = state.copyWith(
          isAvailable: true,
          isLoadingProducts: false,
          isSetupPending: false,
          errorMessage: 'Unable to load pricing. Please check your connection and try again.',
        );
        return;
      }

      final products = response.productDetails;
      if (products.isEmpty) {
        // Billing library works, but product isn't in Play Console yet /
        // app not published / testers not added — not an infinite load.
        debugPrint(
          'IAP query returned 0 products. notFoundIDs=${response.notFoundIDs}',
        );
        state = state.copyWith(
          isAvailable: true,
          products: const [],
          isLoadingProducts: false,
          isSetupPending: true,
          clearError: true,
        );
        return;
      }

      state = state.copyWith(
        isAvailable: true,
        products: products,
        isLoadingProducts: false,
        isSetupPending: false,
        clearError: true,
      );
    } catch (e) {
      debugPrint("Load products exception: $e");
      state = state.copyWith(
        isAvailable: true,
        isLoadingProducts: false,
        isSetupPending: false,
        errorMessage: 'Unable to load pricing. Please check your connection and try again.',
      );
    }
  }

  /// Initiates a one-time non-consumable purchase flow for [product].
  Future<void> buyProduct(ProductDetails product) async {
    state = state.copyWith(isPurchasing: true, clearError: true);
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (!success) {
        state = state.copyWith(
          isPurchasing: false,
          errorMessage: 'Unable to initiate store purchase. Please try again.',
        );
      }
    } catch (e) {
      debugPrint("buyNonConsumable initiation exception: $e");
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: 'Unable to initiate store purchase. Please try again.',
      );
    }
  }

  /// Restores previous non-consumable Google Play purchases.
  Future<void> restorePurchases() async {
    state = state.copyWith(isPurchasing: true, clearError: true);
    try {
      await _iap.restorePurchases();
      // If Play returns nothing, don't leave the button spinning forever.
      await Future<void>.delayed(const Duration(seconds: 5));
      if (state.isPurchasing) {
        state = state.copyWith(isPurchasing: false);
      }
    } catch (e) {
      debugPrint("Restore purchases exception: $e");
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: 'Unable to restore purchases. Please check your connection and try again.',
      );
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        state = state.copyWith(isPurchasing: true, clearError: true);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        state = state.copyWith(isPurchasing: false, clearError: true);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        final rawMsg = purchaseDetails.error?.message.toLowerCase() ?? '';
        final isCancel = rawMsg.contains('cancel') || rawMsg.contains('user_canceled');
        state = state.copyWith(
          isPurchasing: false,
          errorMessage: isCancel ? null : 'Purchase could not be completed. Please try again.',
          clearError: isCancel,
        );
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        bool isValid = await _verifyPurchase(purchaseDetails);
        if (isValid) {
          await _refreshPremiumState();
          state = state.copyWith(isPurchasing: false, isPro: true, clearError: true);
        } else {
          state = state.copyWith(
            isPurchasing: false,
            errorMessage: 'Purchase verification failed. Please try again or contact support.',
          );
        }
      }

      if (purchaseDetails.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchaseDetails);
        } catch (e) {
          debugPrint("Complete purchase error: $e");
        }
      }
    }
  }

  /// Strictly verifies the Google Play purchase token via Firebase Cloud Function.
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    final verificationData = purchaseDetails.verificationData;
    final token = verificationData.serverVerificationData.isNotEmpty
        ? verificationData.serverVerificationData
        : verificationData.localVerificationData;

    if (token.isEmpty) {
      debugPrint("Purchase verification failed: missing verification token payload.");
      return false;
    }

    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('verifyGooglePlayPurchase');
      final response = await callable.call({
        'productId': purchaseDetails.productID,
        'purchaseToken': token,
      });

      return response.data is Map && response.data['success'] == true;
    } catch (e) {
      debugPrint("Server-side Google Play verification failed: $e");
      return false;
    }
  }

  /// Refreshes Firestore-backed premium providers and local metrics after a
  /// verified purchase/restore so app-wide UI reacts without restart.
  /// Caller only invokes this after server verification succeeded.
  Future<void> _refreshPremiumState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Authoritative persistent entitlement lives on the user doc stream.
      ref.invalidate(remotePremiumFlagProvider);
      // Local Isar metrics mirror of premium (used by metrics flows).
      ref.invalidate(userMetricsProvider);

      // Await first settled Firestore value so isPremiumProvider updates now.
      final isPremium = await ref
          .read(remotePremiumFlagProvider.future)
          .timeout(const Duration(seconds: 8), onTimeout: () => true);
      syncIsProFromAuthoritative(ref.read(isPremiumProvider) || isPremium);
    } catch (e) {
      debugPrint("Error refreshing premium providers: $e");
      // Purchase/restore already verified — keep billing + UI in sync locally
      // while Firestore catches up via the user-doc stream.
      if (mounted) syncIsProFromAuthoritative(true);
    }
  }
}

final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  // Recreate billing state when the authenticated uid changes so premium
  // never leaks across logout / account switch (ignore token-only refreshes).
  final userId = ref.watch(currentUserProvider.select((u) => u?.uid));
  final notifier = BillingNotifier(ref, userId);

  // Keep BillingState.isPro synchronized with the Firestore-backed flag
  // (and test-email bypass) as it settles or changes.
  ref.listen<bool>(isPremiumProvider, (previous, next) {
    notifier.syncIsProFromAuthoritative(next);
  }, fireImmediately: true);

  return notifier;
});
