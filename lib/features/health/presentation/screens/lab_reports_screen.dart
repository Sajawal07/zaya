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

class LabReportsScreen extends ConsumerStatefulWidget {
  const LabReportsScreen({super.key});

  @override
  ConsumerState<LabReportsScreen> createState() => _LabReportsScreenState();
}

class _LabReportsScreenState extends ConsumerState<LabReportsScreen> {
  List<LabReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final db = ref.read(databaseServiceProvider);
    final reports = await db.getLabReports(user.uid);
    if (mounted) {
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    }
  }

  void _showAddReportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddLabReportSheet(onSaved: _loadReports),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Lab Reports', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReportSheet,
        backgroundColor: AppColors.nudeRose,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const AppLoaderCentered()
          : _reports.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return _ReportCard(report: report);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.biotech_outlined, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          Text(
            'No Lab Reports Yet',
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Keep track of your hormone levels,\nthyroid, and vital markers here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final LabReport report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(report.date),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.nudeRose),
              ),
              if (report.labName != null)
                Text(
                  report.labName!,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
            ],
          ),
          const Divider(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (report.lh != null) _Marker(label: 'LH', value: report.lh!),
              if (report.fsh != null) _Marker(label: 'FSH', value: report.fsh!),
              if (report.tsh != null) _Marker(label: 'TSH', value: report.tsh!),
              if (report.t3 != null) _Marker(label: 'T3', value: report.t3!),
              if (report.t4 != null) _Marker(label: 'T4', value: report.t4!),
              if (report.vitaminD != null) _Marker(label: 'Vit D', value: report.vitaminD!),
              if (report.bloodSugar != null) _Marker(label: 'Sugar', value: report.bloodSugar!),
              if (report.insulin != null) _Marker(label: 'Insulin', value: report.insulin!),
            ],
          ),
          if (report.notes != null && report.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              report.notes!,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  final String label;
  final double value;
  const _Marker({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class _AddLabReportSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _AddLabReportSheet({required this.onSaved});

  @override
  ConsumerState<_AddLabReportSheet> createState() => _AddLabReportSheetState();
}

class _AddLabReportSheetState extends ConsumerState<_AddLabReportSheet> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  final _labNameController = TextEditingController();
  final _lhController = TextEditingController();
  final _fshController = TextEditingController();
  final _tshController = TextEditingController();
  final _t3Controller = TextEditingController();
  final _t4Controller = TextEditingController();
  final _vitDController = TextEditingController();
  final _sugarController = TextEditingController();
  final _insulinController = TextEditingController();
  final _notesController = TextEditingController();

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final db = ref.read(databaseServiceProvider);

    final report = LabReport()
      ..userId = user.uid
      ..date = _date
      ..labName = _labNameController.text
      ..lh = double.tryParse(_lhController.text)
      ..fsh = double.tryParse(_fshController.text)
      ..tsh = double.tryParse(_tshController.text)
      ..t3 = double.tryParse(_t3Controller.text)
      ..t4 = double.tryParse(_t4Controller.text)
      ..vitaminD = double.tryParse(_vitDController.text)
      ..bloodSugar = double.tryParse(_sugarController.text)
      ..insulin = double.tryParse(_insulinController.text)
      ..notes = _notesController.text;

    await db.saveLabReport(report);
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
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Log Lab Results', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('Date of Test'),
                subtitle: Text(DateFormat('MMMM dd, yyyy').format(_date)),
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
              _buildField(_labNameController, 'Lab Name / Hospital', Icons.local_hospital_outlined),
              const SizedBox(height: 16),
              const Text('Hormones & Thyroid', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              Row(
                children: [
                  Expanded(child: _buildNumericField(_lhController, 'LH')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumericField(_fshController, 'FSH')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumericField(_tshController, 'TSH')),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildNumericField(_t3Controller, 'T3')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumericField(_t4Controller, 'T4')),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Markers', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              Row(
                children: [
                  Expanded(child: _buildNumericField(_vitDController, 'Vit D')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumericField(_sugarController, 'Sugar')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumericField(_insulinController, 'Insulin')),
                ],
              ),
              _buildField(_notesController, 'Notes', Icons.note_add_outlined, maxLines: 2),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.nudeRose,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Report', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.nudeRose),
        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.nudeRose.withValues(alpha: 0.2))),
      ),
    );
  }

  Widget _buildNumericField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      decoration: InputDecoration(
        labelText: label,
        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.nudeRose.withValues(alpha: 0.2))),
      ),
    );
  }
}
