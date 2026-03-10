import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_colors.dart';
import '../../../../models/notification.dart';
import '../../../../providers/database_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
          ),
        ),
        backgroundColor: AppColors.oldLace,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await db.clearNotifications();
            },
            child: const Text('Clear all', style: TextStyle(color: Color(0xFFD47A8E))),
          ),
        ],
      ),
      body: FutureBuilder<List<AppNotification>>(
        future: db.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final notifications = snapshot.data ?? [];
          
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 20),
                  Text(
                    'No notifications yet',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _buildNotificationCard(context, notif);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppNotification notif) {
    final isAuth = notif.category == 'auth';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAuth ? Colors.blue.withOpacity(0.1) : const Color(0xFFD47A8E).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAuth ? Icons.login_rounded : Icons.calendar_today_rounded,
              color: isAuth ? Colors.blue : const Color(0xFFD47A8E),
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notif.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(notif.timestamp),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif.body,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: const Color(0xFF757575),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(notif.timestamp),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: Colors.grey.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
