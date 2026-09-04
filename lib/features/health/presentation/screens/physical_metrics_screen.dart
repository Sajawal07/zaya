import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/providers/database_provider.dart';
import 'package:hercycle_bloom/providers/auth_provider.dart';
import 'package:hercycle_bloom/models/health_records.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';

class PhysicalMetricsScreen extends ConsumerStatefulWidget {
  const PhysicalMetricsScreen({super.key});

  @override
  ConsumerState<PhysicalMetricsScreen> createState() => _PhysicalMetricsScreenState();
}

class _PhysicalMetricsScreenState extends ConsumerState<PhysicalMetricsScreen> {
  final _tempController = TextEditingController();
  String? _mucusTexture;
  String? _mucusColor;
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  final _textures = ['Dry', 'Sticky', 'Creamy', 'Egg White', 'Watery'];
  final _colors = ['Clear', 'White', 'Yellow', 'Tinged'];

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _isSaving = true);

    try {
      final metric = PhysicalMetric()
        ..userId = user.uid
        ..date = DateTime(_date.year, _date.month, _date.day)
        ..bbt = double.tryParse(_tempController.text)
        ..cervicalMucusTexture = _mucusTexture
        ..cervicalMucusColor = _mucusColor;

      await ref.read(databaseServiceProvider).savePhysicalMetric(metric);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Metrics saved')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Physical Metrics', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Tracking Date'),
            const SizedBox(height: 12),
            _buildCard([
              ListTile(
                title: Text(DateFormat('MMMM dd, yyyy').format(_date)),
                leading: const Icon(Icons.calendar_today_rounded, color: AppColors.nudeRose),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildLabel('Basal Body Temperature (BBT)'),
            const SizedBox(height: 12),
            _buildCard([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: _tempController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  decoration: const InputDecoration(
                    hintText: 'e.g. 36.5',
                    suffixText: '°C',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 24),
            _buildLabel('Cervical Mucus'),
            const SizedBox(height: 12),
            _buildCard([
              _buildDropdown('Texture', _textures, _mucusTexture, (v) => setState(() => _mucusTexture = v)),
              const Divider(height: 1, indent: 16),
              _buildDropdown('Color', _colors, _mucusColor, (v) => setState(() => _mucusColor = v)),
            ]),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.nudeRose,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: _isSaving ? const AppLoader(size: 22, color: Colors.white) : const Text('Save Metrics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label.toUpperCase(), style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary));
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)]),
      child: Column(children: children),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
