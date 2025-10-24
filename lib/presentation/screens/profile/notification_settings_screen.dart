import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../widgets/common/custom_app_bar.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _ticketBookingNotifications = true;
  bool _ticketExpiryNotifications = true;
  bool _promotionalNotifications = false;
  bool _systemNotifications = true;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    // await NotificationService.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Notification Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Manage your notification preferences',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Ticket notifications
          _buildNotificationSection(
            'Ticket Notifications',
            [
              _buildNotificationTile(
                'Booking Confirmations',
                'Get notified when your ticket is booked successfully',
                _ticketBookingNotifications,
                (value) {
                  setState(() {
                    _ticketBookingNotifications = value;
                  });
                },
              ),
              _buildNotificationTile(
                'Expiry Reminders',
                'Get reminded before your ticket expires',
                _ticketExpiryNotifications,
                (value) {
                  setState(() {
                    _ticketExpiryNotifications = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // General notifications
          _buildNotificationSection(
            'General Notifications',
            [
              _buildNotificationTile(
                'System Updates',
                'Important app updates and maintenance notifications',
                _systemNotifications,
                (value) {
                  setState(() {
                    _systemNotifications = value;
                  });
                },
              ),
              _buildNotificationTile(
                'Promotional Offers',
                'Special offers and discounts on tickets',
                _promotionalNotifications,
                (value) {
                  setState(() {
                    _promotionalNotifications = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Test notification button
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: AppColors.info,
                ),
              ),
              title: const Text('Test Notification'),
              subtitle:
                  const Text('Send a test notification to check if it works'),
              trailing: ElevatedButton(
                onPressed: () async {
                  // await NotificationService.showNotification(
                  //   id: 999,
                  //   title: 'Test Notification',
                  //   body: 'This is a test notification from SaralYatri',
                  // );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test notification sent!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Send'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildNotificationTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
    );
  }
}
