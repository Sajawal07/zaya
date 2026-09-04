import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/providers/database_provider.dart';
import 'package:hercycle_bloom/providers/auth_provider.dart';
import 'package:hercycle_bloom/models/health_records.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';

class MedicationRemindersScreen extends ConsumerStatefulWidget {
  const MedicationRemindersScreen({super.key});

  @override
  ConsumerState<MedicationRemindersScreen> createState() => _MedicationRemindersScreenState();
}

class _MedicationRemindersScreenState extends ConsumerState<MedicationRemindersScreen> {
  List<Medication> _meds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeds();
  }

  Future<void> _loadMeds() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final db = ref.read(databaseServiceProvider);
    final meds = await db.getMedications(user.uid);
    if (mounted) {
      setState(() {
        _meds = meds;
        _isLoading = false;
      });
    }
  }

  void _showAddMedSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMedicationSheet(onSaved: _loadMeds),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Medications', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedSheet,
        backgroundColor: AppColors.nudeRose,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const AppLoaderCentered()
          : _meds.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _meds.length,
                  itemBuilder: (context, index) {
                    final med = _meds[index];
                    return _MedicationCard(med: med, onRefresh: _loadMeds);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          Text(
            'No Medications Logged',
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your supplements, Inositol, or\nprescribed medicines for daily reminders.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends ConsumerWidget {
  final Medication med;
  final VoidCallback onRefresh;
  const _MedicationCard({required this.med, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.nudeRose.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_rounded, color: AppColors.nudeRose),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${med.dosage} • ${med.frequency}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch.adaptive(
            value: med.isActive,
            activeColor: AppColors.nudeRose,
            onChanged: (v) async {
              med.isActive = v;
              await ref.read(databaseServiceProvider).saveMedication(med);
              onRefresh();
            },
          ),
        ],
      ),
    );
  }
}

class _AddMedicationSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _AddMedicationSheet({required this.onSaved});

  @override
  ConsumerState<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends ConsumerState<_AddMedicationSheet> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  String _frequency = 'Daily';
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final db = ref.read(databaseServiceProvider);

    final med = Medication()
      ..userId = user.uid
      ..name = _nameController.text
      ..dosage = _dosageController.text
      ..frequency = _frequency
      ..reminderTimes = [_time.hour * 60 + _time.minute]
      ..createdAt = DateTime.now();

    await db.saveMedication(med);
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Add Medication', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildField(_nameController, 'Name (e.g. Myo-Inositol)', Icons.medication_rounded),
          _buildField(_dosageController, 'Dosage (e.g. 500mg)', Icons.straighten),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _frequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: ['Daily', 'Weekly', 'Twice Daily'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (v) => setState(() => _frequency = v!),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _time);
                    if (picked != null) setState(() => _time = picked);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reminder Time', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Text(_time.format(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.nudeRose,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Add Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.nudeRose),
        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.nudeRose.withValues(alpha: 0.2))),
      ),
    );
  }
}
