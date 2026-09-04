import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'metrics_provider.dart';

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
  final String? errorMessage;
  final bool isPro;

  BillingState({
    this.isAvailable = false,
    this.products = const [],
    this.isPurchasing = false,
    this.errorMessage,
    this.isPro = false,
  });

  BillingState copyWith({
    bool? isAvailable,
    List<ProductDetails>? products,
    bool? isPurchasing,
    String? errorMessage,
    bool? isPro,
  }) {
    return BillingState(
      isAvailable: isAvailable ?? this.isAvailable,
      products: products ?? this.products,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      errorMessage: errorMessage,
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
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  BillingNotifier(this.ref) : super(BillingState()) {
    _init();
  }

  Future<void> _init() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("Purchase Stream Error: $error");
      state = state.copyWith(
        errorMessage: 'Unable to load pricing. Please check your connection and try again.',
      );
    });

    await loadProducts();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> loadProducts() async {
    final available = await _iap.isAvailable();
    if (!available) {
      state = state.copyWith(
        isAvailable: false,
        errorMessage: 'Unable to load pricing. Please check your connection and try again.',
      );
      return;
    }

    state = state.copyWith(isAvailable: true, errorMessage: null);

    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(kProductIds.toSet());
      if (response.error != null) {
        debugPrint("Query product details error: ${response.error!.message}");
        state = state.copyWith(
          errorMessage: 'Unable to load pricing. Please check your connection and try again.',
        );
        return;
      }

      final products = response.productDetails;
      state = state.copyWith(products: products, errorMessage: null);
    } catch (e) {
      debugPrint("Load products exception: $e");
      state = state.copyWith(
        errorMessage: 'Unable to load pricing. Please check your connection and try again.',
      );
    }
  }

  /// Initiates a one-time non-consumable purchase flow for [product].
  Future<void> buyProduct(ProductDetails product) async {
    state = state.copyWith(isPurchasing: true, errorMessage: null);
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
    state = state.copyWith(isPurchasing: true, errorMessage: null);
    try {
      await _iap.restorePurchases();
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
        state = state.copyWith(isPurchasing: true, errorMessage: null);
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        state = state.copyWith(isPurchasing: false, errorMessage: null);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        final rawMsg = purchaseDetails.error?.message.toLowerCase() ?? '';
        final isCancel = rawMsg.contains('cancel') || rawMsg.contains('user_canceled');
        state = state.copyWith(
          isPurchasing: false,
          errorMessage: isCancel ? null : 'Purchase could not be completed. Please try again.',
        );
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Strict Server-side Cloud Function verification calling Google Play Developer API
        bool isValid = await _verifyPurchase(purchaseDetails);
        if (isValid) {
          await _refreshPremiumState();
          state = state.copyWith(isPurchasing: false, isPro: true, errorMessage: null);
        } else {
          state = state.copyWith(
            isPurchasing: false,
            errorMessage: 'Purchase verification failed. Please try again or contact support.',
          );
        }
      }

      // Complete purchase (acknowledgement) after verification and entitlement logic
      if (purchaseDetails.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchaseDetails);
        } catch (e) {
          debugPrint("Complete purchase error: $e");
        }
      }
    }
  }

  /// Strictly verifies the Google Play purchase token via Firebase Cloud Function (Server-Side).
  /// Google Play Developer API checks genuineness of token and Admin SDK sets isPremium = true in Firestore.
  /// NO CLIENT-SIDE FALLBACK IS PERMITTED!
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
      final callable = FirebaseFunctions.instance.httpsCallable('verifyGooglePlayPurchase');
      final response = await callable.call({
        'productId': purchaseDetails.productID,
        'purchaseToken': token,
      });

      return response.data is Map && response.data['success'] == true;
    } catch (e) {
      debugPrint("Server-side Google Play verification failed: $e");
      return false; // STRICT NO-FALLBACK SECURITY: Failed server check = false
    }
  }

  Future<void> _refreshPremiumState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Invalidate local user metrics state to fetch server-updated isPremium flag from Firestore
      ref.invalidate(userMetricsProvider);
    } catch (e) {
      debugPrint("Error invalidating userMetricsProvider: $e");
    }
  }
}

final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  return BillingNotifier(ref);
});
