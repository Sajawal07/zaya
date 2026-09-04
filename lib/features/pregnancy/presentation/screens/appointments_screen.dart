import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/app_colors.dart';
import '../../../../models/pregnancy_data.dart';
import '../../../../providers/database_provider.dart';
import '../../../../services/notification_service.dart';
import '../../../../shared/widgets/app_loader.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  List<PregnancyAppointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = ref.read(databaseServiceProvider);
    final list = await db.getAppointments(user.uid);
    if (mounted) {
      setState(() {
        _appointments = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: AppColors.oldLace,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAppointmentDialog,
        backgroundColor: AppColors.nudeRose,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Add New', style: TextStyle(color: AppColors.white)),
      ),
      body: _isLoading 
          ? const AppLoaderCentered()
          : _appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.mistySage.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No upcoming appointments',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final apt = _appointments[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getTypeColor(apt.type).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getTypeIcon(apt.type),
                                color: _getTypeColor(apt.type),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    apt.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    apt.doctor,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.oldLace,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.nudeRose.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${apt.date.day}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppColors.nudeRose,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _getMonth(apt.date.month),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (apt.notes != null && apt.notes!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.oldLace.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.description_outlined, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    apt.notes!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => _deleteAppointment(apt.id, apt.notificationId),
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          label: const Text('Remove', style: TextStyle(color: AppColors.error, fontSize: 12)),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _deleteAppointment(int id, int? notificationId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseServiceProvider);
      await db.deleteAppointment(id);
      if (notificationId != null) {
        await NotificationService.cancelNotification(notificationId);
      }
      await _loadAppointments();
    }
  }

  void _showAddAppointmentDialog() {
    final titleController = TextEditingController();
    final doctorController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String selectedType = 'checkup';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title (e.g. Ultrasound)'),
                ),
                TextField(
                  controller: doctorController,
                  decoration: const InputDecoration(labelText: 'Doctor/Clinic'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'checkup', child: Text('Regular Checkup')),
                    DropdownMenuItem(value: 'scan', child: Text('Ultrasound Scan')),
                    DropdownMenuItem(value: 'test', child: Text('Lab Test')),
                  ],
                  onChanged: (val) => setDialogState(() => selectedType = val!),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;
                
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                final db = ref.read(databaseServiceProvider);
                
                // Generate a unique notification ID (int)
                final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

                final apt = PregnancyAppointment()
                  ..userId = user.uid
                  ..title = titleController.text
                  ..doctor = doctorController.text.isEmpty ? 'General' : doctorController.text
                  ..date = selectedDate
                  ..notes = notesController.text
                  ..type = selectedType
                  ..isReminderEnabled = true
                  ..notificationId = notificationId;

                await db.saveAppointment(apt);
                
                // Schedule notification
                await NotificationService.scheduleAppointmentReminder(
                  id: notificationId,
                  title: 'Upcoming Appointment: ${apt.title}',
                  body: 'With ${apt.doctor} at ${apt.date.hour}:${apt.date.minute.toString().padLeft(2, '0')}',
                  scheduledDate: apt.date,
                );

                await _loadAppointments();
                
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'scan':
        return AppColors.pregnancyGold;
      case 'test':
        return AppColors.periodRed;
      default:
        return AppColors.mistySage;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'scan':
        return Icons.radar_rounded;
      case 'test':
        return Icons.science_outlined;
      default:
        return Icons.medical_services_outlined;
    }
  }

  String _getMonth(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}

