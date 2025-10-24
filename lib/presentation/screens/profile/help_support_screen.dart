import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart'; // Add this dependency to pubspec.yaml
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Help & Support'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We\'re here to assist you with any questions or issues',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          icon: Icons.phone,
                          title: 'Call Support',
                          subtitle: '24/7 Available',
                          onTap: () => _makePhoneCall('+91-1800-123-4567'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          icon: Icons.chat,
                          title: 'Live Chat',
                          subtitle: 'Chat with us',
                          onTap: () => _showChatDialog(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          icon: Icons.email,
                          title: 'Email Us',
                          subtitle: 'Get help via email',
                          onTap: () => _sendEmail('support@saralyatri.com'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          icon: Icons.bug_report,
                          title: 'Report Bug',
                          subtitle: 'Report an issue',
                          onTap: () => _showBugReportDialog(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // FAQ Section
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFAQItem(
                    'How do I book a ticket?',
                    'You can book a ticket by scanning the QR code on the bus, entering the bus number manually, or using the booking form in the app.',
                  ),

                  _buildFAQItem(
                    'How do I cancel my ticket?',
                    'Currently, tickets cannot be cancelled once booked. Please contact support if you have special circumstances.',
                  ),

                  _buildFAQItem(
                    'What payment methods are accepted?',
                    'We accept UPI, Credit/Debit Cards, Net Banking, and Digital Wallets like Paytm, PhonePe, and Google Pay.',
                  ),

                  _buildFAQItem(
                    'How do I get a refund?',
                    'Refunds are processed according to our refund policy. Contact support with your ticket details for assistance.',
                  ),

                  _buildFAQItem(
                    'What if I lose my ticket?',
                    'Your tickets are saved in the app. You can access them from the "My Tickets" section even if you lose internet connectivity.',
                  ),

                  _buildFAQItem(
                    'How do I update my profile information?',
                    'Go to Profile > Edit Profile to update your personal information, contact details, and preferences.',
                  ),

                  const SizedBox(height: 32),

                  // Contact Information
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildContactItem(
                          Icons.phone,
                          'Phone',
                          '+91-1800-123-4567',
                          () => _makePhoneCall('+91-1800-123-4567'),
                        ),
                        _buildContactItem(
                          Icons.email,
                          'Email',
                          'support@saralyatri.com',
                          () => _sendEmail('support@saralyatri.com'),
                        ),
                        _buildContactItem(
                          Icons.language,
                          'Website',
                          'www.saralyatri.com',
                          () => _openWebsite('https://www.saralyatri.com'),
                        ),
                        _buildContactItem(
                          Icons.location_on,
                          'Address',
                          'Transport Bhawan, New Delhi - 110001',
                          () => _copyToClipboard(
                              context, 'Transport Bhawan, New Delhi - 110001'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // TODO: Add url_launcher dependency and uncomment
    // final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    // await launchUrl(launchUri);
    _showFeatureDialog(
        'Phone Call', 'This feature requires url_launcher dependency');
  }

  Future<void> _sendEmail(String email) async {
    // TODO: Add url_launcher dependency and uncomment
    // final Uri launchUri = Uri(scheme: 'mailto', path: email, query: 'subject=SaralYatri Support Request');
    // await launchUrl(launchUri);
    _showFeatureDialog(
        'Email', 'This feature requires url_launcher dependency');
  }

  Future<void> _openWebsite(String url) async {
    // TODO: Add url_launcher dependency and uncomment
    // final Uri launchUri = Uri.parse(url);
    // await launchUrl(launchUri);
    _showFeatureDialog(
        'Website', 'This feature requires url_launcher dependency');
  }

  void _showFeatureDialog(String feature, String message) {
    // This is a placeholder - in production, you'd use url_launcher
    Clipboard.setData(ClipboardData(text: 'Feature: $feature'));
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text(
          'Live chat feature is coming soon! For immediate assistance, please call our support number or send us an email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const Text(
          'To report a bug, please send us an email at support@saralyatri.com with details about the issue you encountered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sendEmail('support@saralyatri.com');
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }
}
