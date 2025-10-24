import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BookingOptionsDrawer extends StatelessWidget {
  const BookingOptionsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                ],
              ),
            ),
            child: const SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.directions_bus,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Book Your Ticket',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Choose your preferred method',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Booking Options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBookingOption(
                  context,
                  icon: Icons.qr_code_scanner,
                  title: 'Scan Bus QR Code',
                  subtitle: 'Scan the QR code displayed on the bus',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/qr-scanner');
                  },
                ),

                const SizedBox(height: 12),

                _buildBookingOption(
                  context,
                  icon: Icons.qr_code,
                  title: 'Scan Conductor QR',
                  subtitle: 'Scan conductor\'s QR code for assistance',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/qr-scanner');
                  },
                ),

                const SizedBox(height: 12),

                _buildBookingOption(
                  context,
                  icon: Icons.edit,
                  title: 'Enter Bus Number',
                  subtitle: 'Manually enter the bus number plate',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/booking');
                  },
                ),

                const SizedBox(height: 24),

                const Divider(),

                const SizedBox(height: 12),

                // Additional Options
                ListTile(
                  leading: const Icon(
                    Icons.confirmation_number,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('My Tickets'),
                  subtitle: const Text('View your booked tickets'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/ticket');
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.history,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Booking History'),
                  subtitle: const Text('View your past bookings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/booking-history');
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.help,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Help & Support'),
                  subtitle: const Text('Get help with booking'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/help-support');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
