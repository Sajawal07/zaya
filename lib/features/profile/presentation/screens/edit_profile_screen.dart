import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/providers/metrics_provider.dart';
import 'package:hercycle_bloom/providers/auth_provider.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _prePregnancyWeightController;
  String? _activityLevel;
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
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _prePregnancyWeightController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        _nameController.text = user.displayName ?? '';
      }
      final metrics = ref.read(userMetricsProvider).value;
      if (metrics != null) {
        _ageController.text = metrics.age?.toString() ?? '';
        _heightController.text = metrics.height?.toString() ?? '';
        _weightController.text = metrics.weight?.toString() ?? '';
        _prePregnancyWeightController.text = metrics.prePregnancyWeight?.toString() ?? '';
        _activityLevel = metrics.activityLevel;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _prePregnancyWeightController.dispose();
    super.dispose();
  }

  double? _computeBmi() {
    final h = double.tryParse(_heightController.text);
    final w = double.tryParse(_weightController.text);
    if (h == null || h == 0 || w == null) return null;
    return w / ((h / 100) * (h / 100));
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return AppColors.fertileGreen;
    if (bmi < 30) return Colors.orange;
    return AppColors.periodRed;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      // Update display name
      final newName = _nameController.text.trim();
      if (newName.isNotEmpty && newName != user.displayName) {
        await user.updateDisplayName(newName);
      }

      // Update metrics via notifier
      await ref.read(userMetricsProvider.notifier).updateMetrics(
        age: int.tryParse(_ageController.text),
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        prePregnancyWeight: double.tryParse(_prePregnancyWeightController.text),
        activityLevel: _activityLevel,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.fertileGreen,
          ),
        );
        Navigator.pop(context);
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
    final bmi = _computeBmi();
    final isPregnant = ref.watch(userMetricsProvider).value?.isPregnant ?? false;

    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.oldLace,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Row
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.nudeRose.withValues(alpha: 0.2),
                  backgroundImage: ref.watch(currentUserProvider)?.photoURL != null
                      ? NetworkImage(ref.watch(currentUserProvider)!.photoURL!)
                      : null,
                  child: ref.watch(currentUserProvider)?.photoURL == null
                      ? const Icon(Icons.person, size: 44, color: AppColors.nudeRose)
                      : null,
                ),
              ),
              const SizedBox(height: 32),

              // Section label
              _sectionLabel('Personal Information'),
              const SizedBox(height: 12),
              _buildCard([
                _buildField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const Divider(height: 1, indent: 56),
                _buildField(
                  controller: _ageController,
                  label: 'Age',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Age is required for health insights';
                    final age = int.tryParse(v);
                    if (age == null || age < 10 || age > 99) return 'Enter a valid age (10–99)';
                    return null;
                  },
                ),
              ]),

              const SizedBox(height: 24),
              _sectionLabel('Body Measurements'),
              const SizedBox(height: 12),
              _buildCard([
                _buildField(
                  controller: _heightController,
                  label: 'Height (cm)',
                  icon: Icons.height_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Height is required for BMI';
                    final h = double.tryParse(v);
                    if (h == null || h < 50 || h > 250) return 'Enter a valid height (50–250 cm)';
                    return null;
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildField(
                  controller: _weightController,
                  label: isPregnant ? 'Current Weight (kg)' : 'Weight (kg)',
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Weight is required';
                    final w = double.tryParse(v);
                    if (w == null || w < 20 || w > 300) return 'Enter a valid weight (20–300 kg)';
                    return null;
                  },
                ),
                if (isPregnant) ...[
                  const Divider(height: 1, indent: 56),
                  _buildField(
                    controller: _prePregnancyWeightController,
                    label: 'Pre-pregnancy Weight (kg)',
                    icon: Icons.history_rounded,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required for gain guidance';
                      final w = double.tryParse(v);
                      if (w == null || w < 20 || w > 300) return 'Enter a valid weight';
                      return null;
                    },
                  ),
                ],
              ]),

              const SizedBox(height: 24),
              _sectionLabel('Lifestyle'),
              const SizedBox(height: 12),
              _buildCard([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    value: _activityLevel,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.directions_run_rounded, color: AppColors.nudeRose, size: 20),
                      labelText: 'Activity Level',
                      labelStyle: GoogleFonts.montserrat(color: AppColors.textSecondary, fontSize: 14),
                      border: InputBorder.none,
                    ),
                    items: _activityLevels.map((lvl) {
                      return DropdownMenuItem(value: lvl, child: Text(lvl, style: GoogleFonts.montserrat(fontSize: 14)));
                    }).toList(),
                    onChanged: (v) => setState(() => _activityLevel = v),
                    validator: (v) => v == null ? 'Please select your activity level' : null,
                  ),
                ),
              ]),

              // Live BMI Preview
              if (bmi != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _bmiColor(bmi).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _bmiColor(bmi).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calculate_outlined, color: _bmiColor(bmi), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'BMI: ${bmi.toStringAsFixed(1)} — ${_bmiCategory(bmi)}',
                            style: GoogleFonts.montserrat(
                              color: _bmiColor(bmi),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Healthy Range: ${(18.5 * (double.tryParse(_heightController.text)!/100) * (double.tryParse(_heightController.text)!/100)).toStringAsFixed(1)} – ${(24.9 * (double.tryParse(_heightController.text)!/100) * (double.tryParse(_heightController.text)!/100)).toStringAsFixed(1)} kg',
                        style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.nudeRose,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const AppLoader(size: 22, color: Colors.white)
                    : Text(
                        'Save Changes',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
        ),
      ),
    );
  }
}
