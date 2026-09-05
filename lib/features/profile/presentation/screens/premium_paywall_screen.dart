import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/premium_limits.dart';
import '../../../../providers/premium_provider.dart';
import '../../../../providers/billing_provider.dart';
import '../../../../shared/widgets/app_loader.dart';

class PremiumPaywallScreen extends ConsumerStatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  ConsumerState<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(billingProvider.notifier).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);
    final billingState = ref.watch(billingProvider);
    final product = billingState.premiumUpgradeProduct;

    if (isPremium) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.pregnancyGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 80,
                    color: AppColors.pregnancyGold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'You are a Premium Member!',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You have permanent lifetime access to all HerCycle Bloom features.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: billingState.isPurchasing
                ? null
                : () {
                    ref.read(billingProvider.notifier).restorePurchases();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checking for previous Google Play purchases…'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            child: const Text('Restore', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Icon Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.pregnancyGold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 72,
                    color: AppColors.pregnancyGold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title & Subtitle
              Text(
                'Unlock HerCycle Bloom Premium',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Free includes cycle tracking, daily wellness log, and 10 AI questions/day. Premium unlocks food logging, full Insights, and advanced Health tools.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 32),

              // Premium Feature List (from FreemiumCatalog)
              ...FreemiumCatalog.premiumFeatures.map((f) => _FeatureRow(f)),

              const SizedBox(height: 36),

              if (billingState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        billingState.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            ref.read(billingProvider.notifier).loadProducts(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.nudeRose),
                        ),
                        child: const Text('Retry',
                            style: TextStyle(color: AppColors.nudeRose)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Brief load only — never infinite
              if (billingState.isLoadingProducts) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: AppLoaderCentered(),
                ),
                const Text(
                  'Checking Google Play…',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
              ],

              // Product not on Play Console yet (common before publish)
              if (!billingState.isLoadingProducts &&
                  billingState.isSetupPending) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.pregnancyGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.pregnancyGold.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.hourglass_top_rounded,
                          color: AppColors.pregnancyGold, size: 36),
                      const SizedBox(height: 12),
                      Text(
                        'Premium purchase is in progress',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Google Play in-app purchase is being set up. After you publish the app and add the Premium product in Play Console, the buy button and price will appear here automatically.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () =>
                            ref.read(billingProvider.notifier).loadProducts(),
                        icon: const Icon(Icons.refresh_rounded,
                            color: AppColors.nudeRose),
                        label: const Text('Check again',
                            style: TextStyle(color: AppColors.nudeRose)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.nudeRose),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mistySage,
                    disabledBackgroundColor:
                        AppColors.mistySage.withValues(alpha: 0.45),
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Upgrade — available after Play Store setup',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],

              // Product Details Card & One-Time Purchase Button
              if (!billingState.isLoadingProducts && product != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.nudeRose.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.nudeRose.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.nudeRose.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded,
                            color: AppColors.nudeRose, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Premium Upgrade',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'One-Time Non-Consumable Purchase',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        product.price,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.nudeRose,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: billingState.isPurchasing
                      ? null
                      : () {
                          ref.read(billingProvider.notifier).buyProduct(product);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.nudeRose,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: billingState.isPurchasing
                      ? const AppLoader(size: 22, color: Colors.white)
                      : Text(
                          'Upgrade Now — ${product.price}',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                ),
              ],

              const SizedBox(height: 20),
              const Text(
                'One-time purchase for permanent lifetime access. Payments processed securely via Google Play.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.fertileGreen, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
