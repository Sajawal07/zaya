import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/providers/metrics_provider.dart';
import 'package:hercycle_bloom/providers/database_provider.dart';
import 'package:hercycle_bloom/models/user_metrics.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';

class HealthMetricsSetupScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  const HealthMetricsSetupScreen({super.key, this.onComplete});

  @override
  ConsumerState<HealthMetricsSetupScreen> createState() => _HealthMetricsSetupScreenState();
}

class _HealthMetricsSetupScreenState extends ConsumerState<HealthMetricsSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  String? _activityLevel;
  HealthMode _healthMode = HealthMode.standard;
  bool _isSaving = false;

  final List<String> _activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'Active',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final metrics = ref.read(userMetricsProvider).value;
      if (metrics != null) {
        _ageController.text = metrics.age?.toString() ?? '';
        _heightController.text = metrics.height?.toString() ?? '';
        _weightController.text = metrics.weight?.toString() ?? '';
        _activityLevel = metrics.activityLevel;
        _healthMode = metrics.healthMode;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    try {
      await ref.read(userMetricsProvider.notifier).updateMetrics(
        age: int.tryParse(_ageController.text),
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        activityLevel: _activityLevel,
      );

      // Also update health mode
      final metrics = ref.read(userMetricsProvider).value;
      if (metrics != null) {
        metrics.healthMode = _healthMode;
        // If pregnancy mode is selected, we might want to trigger pregnancy mode setup too
        if (_healthMode == HealthMode.pregnancy && !metrics.isPregnant) {
           // For now just set the flag, but usually it needs a start date
           // Maybe we should just stick to healthMode for now as the 'intent'
        }
        await ref.read(databaseServiceProvider).saveUserMetrics(metrics);
        ref.invalidate(userMetricsProvider);
      }

      // When shown inside HealthGateWrapper (tab body), do NOT pop —
      // popping would remove MainLayout and leave a black screen.
      // Provider update rebuilds the gate to show the real tab content.
      if (mounted && widget.onComplete != null) {
        widget.onComplete!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Set Up Your\nBody Metrics',
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Unlock personalized calorie goals, hormone insights, cycle analysis, and diet plans.',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                _buildLabel('Health Mode'),
                const SizedBox(height: 12),
                _buildModeSelector(),
                
                const SizedBox(height: 24),
                _buildLabel('Physical Details'),
                const SizedBox(height: 12),
                _buildCard([
                  _buildField(
                    controller: _ageController,
                    label: 'Age',
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v == null || v.isEmpty ? 'Age required' : null,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildField(
                    controller: _heightController,
                    label: 'Height (cm)',
                    icon: Icons.height_rounded,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    validator: (v) => v == null || v.isEmpty ? 'Height required' : null,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildField(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    icon: Icons.monitor_weight_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    validator: (v) => v == null || v.isEmpty ? 'Weight required' : null,
                  ),
                ]),

                const SizedBox(height: 24),
                _buildLabel('Activity Level'),
                const SizedBox(height: 12),
                _buildCard([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<String>(
                      value: _activityLevel,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.directions_run_rounded, color: AppColors.nudeRose, size: 20),
                        labelText: 'Daily Activity',
                        border: InputBorder.none,
                      ),
                      items: _activityLevels.map((lvl) {
                        return DropdownMenuItem(value: lvl, child: Text(lvl));
                      }).toList(),
                      onChanged: (v) => setState(() => _activityLevel = v),
                      validator: (v) => v == null ? 'Please select' : null,
                    ),
                  ),
                ]),

                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.nudeRose,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const AppLoader(size: 22, color: Colors.white)
                      : Text(
                          'Save & Unlock',
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildModeSelector() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _ModeButton(
          label: 'Standard',
          isSelected: _healthMode == HealthMode.standard,
          onTap: () => setState(() => _healthMode = HealthMode.standard),
        ),
        _ModeButton(
          label: 'PCOS',
          isSelected: _healthMode == HealthMode.pcos,
          onTap: () => setState(() => _healthMode = HealthMode.pcos),
        ),
        _ModeButton(
          label: 'Pregnancy',
          isSelected: _healthMode == HealthMode.pregnancy,
          onTap: () => setState(() => _healthMode = HealthMode.pregnancy),
        ),
        _ModeButton(
          label: 'TTC',
          isSelected: _healthMode == HealthMode.ttc,
          onTap: () => setState(() => _healthMode = HealthMode.ttc),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.nudeRose, size: 20),
          labelText: label,
          labelStyle: GoogleFonts.montserrat(color: AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.nudeRose : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.nudeRose : AppColors.nudeRose.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
