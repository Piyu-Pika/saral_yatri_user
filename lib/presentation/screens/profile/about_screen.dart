import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart'; // Add this dependency to pubspec.yaml
// import 'package:package_info_plus/package_info_plus.dart'; // Add this dependency to pubspec.yaml
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // PackageInfo? _packageInfo; // Uncomment when package_info_plus is added

  @override
  void initState() {
    super.initState();
    // _loadPackageInfo(); // Uncomment when package_info_plus is added
  }

  // Future<void> _loadPackageInfo() async {
  //   final info = await PackageInfo.fromPlatform();
  //   setState(() {
  //     _packageInfo = info;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'About'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.directions_bus,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SaralYatri',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Version 1.0.0 (1)', // TODO: Use _packageInfo when available
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Smart Public Transportation Solution',
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section
                  _buildSection(
                    'About SaralYatri',
                    'SaralYatri is a comprehensive digital platform designed to revolutionize public transportation. Our mission is to make bus travel more convenient, efficient, and accessible for everyone.\n\nWith features like QR code ticketing, real-time tracking, and seamless payment integration, we\'re transforming the way people experience public transport.',
                  ),

                  const SizedBox(height: 24),

                  // Features Section
                  _buildSection(
                    'Key Features',
                    null,
                    child: Column(
                      children: [
                        _buildFeatureItem(
                          Icons.qr_code_scanner,
                          'QR Code Ticketing',
                          'Quick and contactless ticket booking',
                        ),
                        _buildFeatureItem(
                          Icons.payment,
                          'Multiple Payment Options',
                          'UPI, Cards, Wallets, and more',
                        ),
                        _buildFeatureItem(
                          Icons.location_on,
                          'Real-time Tracking',
                          'Track buses and plan your journey',
                        ),
                        _buildFeatureItem(
                          Icons.eco,
                          'Eco-friendly',
                          'Promoting sustainable transportation',
                        ),
                        _buildFeatureItem(
                          Icons.accessibility,
                          'Accessible Design',
                          'Designed for users of all abilities',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Developer Information
                  _buildSection(
                    'Development Team',
                    'SaralYatri is developed by a dedicated team of engineers and designers committed to improving public transportation through technology.',
                  ),

                  const SizedBox(height: 24),

                  // Legal & Links
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Legal & Links',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildLinkItem(
                          'Privacy Policy',
                          'Learn how we protect your data',
                          () => _openLink('https://saralyatri.com/privacy'),
                        ),

                        _buildLinkItem(
                          'Terms of Service',
                          'Read our terms and conditions',
                          () => _openLink('https://saralyatri.com/terms'),
                        ),

                        _buildLinkItem(
                          'Open Source Licenses',
                          'View third-party licenses',
                          () => _showLicensesDialog(),
                        ),

                        _buildLinkItem(
                          'Rate This App',
                          'Help us improve by rating the app',
                          () => _rateApp(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact & Social
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
                          'Connect With Us',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSocialButton(
                              Icons.language,
                              'Website',
                              () => _openLink('https://saralyatri.com'),
                            ),
                            _buildSocialButton(
                              Icons.email,
                              'Email',
                              () => _sendEmail('info@saralyatri.com'),
                            ),
                            _buildSocialButton(
                              Icons.phone,
                              'Support',
                              () => _makePhoneCall('+91-1800-123-4567'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Copyright
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '© ${DateTime.now().year} SaralYatri',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'All rights reserved',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Made with ❤️ in India',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
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

  Widget _buildSection(String title, String? content, {Widget? child}) {
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
        const SizedBox(height: 12),
        if (content != null)
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        if (child != null) child,
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
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
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLink(String url) async {
    // TODO: Add url_launcher dependency and uncomment
    // final Uri launchUri = Uri.parse(url);
    // await launchUrl(launchUri);
    _showFeatureDialog('Open Link', url);
  }

  Future<void> _sendEmail(String email) async {
    // TODO: Add url_launcher dependency and uncomment
    // final Uri launchUri = Uri(scheme: 'mailto', path: email);
    // await launchUrl(launchUri);
    _showFeatureDialog('Send Email', email);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // TODO: Add url_launcher dependency and uncomment
    // final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    // await launchUrl(launchUri);
    _showFeatureDialog('Make Call', phoneNumber);
  }

  void _showFeatureDialog(String action, String value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action),
        content: Text('$action: $value\n\nThis feature requires url_launcher dependency.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLicensesDialog() {
    showLicensePage(
      context: context,
      applicationName: 'SaralYatri',
      applicationVersion: '1.0.0', // TODO: Use _packageInfo?.version when available
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.directions_bus,
          color: AppColors.primary,
          size: 32,
        ),
      ),
    );
  }

  void _rateApp() {
    // In a real app, this would open the app store
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate SaralYatri'),
        content: const Text(
          'Thank you for using SaralYatri! Your feedback helps us improve the app. Would you like to rate us on the app store?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Open app store rating page
              _openLink('https://play.google.com/store/apps/details?id=com.saralyatri.app');
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }
}