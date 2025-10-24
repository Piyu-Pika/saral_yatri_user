import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/subsidy_application.dart';
import '../../../data/providers/subsidy_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';

class SubsidyApplicationDetailScreen extends ConsumerStatefulWidget {
  final String applicationId;

  const SubsidyApplicationDetailScreen({
    super.key,
    required this.applicationId,
  });

  @override
  ConsumerState<SubsidyApplicationDetailScreen> createState() =>
      _SubsidyApplicationDetailScreenState();
}

class _SubsidyApplicationDetailScreenState
    extends ConsumerState<SubsidyApplicationDetailScreen> {
  SubsidyApplication? _application;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApplicationDetails();
  }

  Future<void> _loadApplicationDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final application = await ref
        .read(subsidyProvider.notifier)
        .getApplicationDetails(widget.applicationId);

    setState(() {
      _application = application;
      _isLoading = false;
      if (application == null) {
        _error = 'Failed to load application details';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Application Details'),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? _buildErrorWidget()
              : _application != null
                  ? _buildContent()
                  : const Center(child: Text('Application not found')),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading application',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadApplicationDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final application = _application!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(application),
          const SizedBox(height: 16),
          _buildApplicationInfo(application),
          const SizedBox(height: 16),
          _buildPersonalInfo(application),
          const SizedBox(height: 16),
          _buildAddressInfo(application),
          const SizedBox(height: 16),
          _buildIncomeInfo(application),
          const SizedBox(height: 16),
          _buildDocumentsInfo(application),
          if (application.adminRemarks?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _buildAdminRemarks(application),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(SubsidyApplication application) {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (application.applicationStatus) {
      case ApplicationStatus.pending:
        backgroundColor = AppColors.warning;
        icon = Icons.hourglass_empty;
        break;
      case ApplicationStatus.underReview:
        backgroundColor = AppColors.info;
        icon = Icons.visibility;
        break;
      case ApplicationStatus.approved:
        backgroundColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      case ApplicationStatus.rejected:
        backgroundColor = AppColors.error;
        icon = Icons.cancel;
        break;
      case ApplicationStatus.expired:
        backgroundColor = AppColors.textSecondary;
        icon = Icons.schedule;
        break;
    }

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: textColor),
            const SizedBox(height: 8),
            Text(
              application.applicationStatus.displayName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              application.subsidyType.displayName,
              style: TextStyle(
                fontSize: 16,
                color: textColor.withValues(alpha: 0.9),
              ),
            ),
            if (application.validFrom != null &&
                application.validUntil != null) ...[
              const SizedBox(height: 8),
              Text(
                'Valid: ${_formatDate(application.validFrom!)} - ${_formatDate(application.validUntil!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationInfo(SubsidyApplication application) {
    return _buildInfoCard(
      'Application Information',
      [
        _buildInfoRow('Application ID', application.id.substring(0, 8) + '...'),
        _buildInfoRow('Submitted', _formatDateTime(application.submittedAt)),
        if (application.processedAt != null)
          _buildInfoRow('Processed', _formatDateTime(application.processedAt!)),
        if (application.approvedAt != null)
          _buildInfoRow('Approved', _formatDateTime(application.approvedAt!)),
        _buildInfoRow('Reason', application.applicationReason),
      ],
    );
  }

  Widget _buildPersonalInfo(SubsidyApplication application) {
    return _buildInfoCard(
      'Personal Information',
      [
        _buildInfoRow('Full Name', application.fullName),
        _buildInfoRow('Phone', application.phone),
        _buildInfoRow('Email', application.email),
        _buildInfoRow('Aadhaar Number', application.aadhaarNumber),
        _buildInfoRow('Date of Birth', _formatDate(application.dateOfBirth)),
        _buildInfoRow('Gender', application.gender.name.toUpperCase()),
      ],
    );
  }

  Widget _buildAddressInfo(SubsidyApplication application) {
    final address = application.address;
    return _buildInfoCard(
      'Address Information',
      [
        _buildInfoRow('Street', address.street),
        _buildInfoRow('City', address.city),
        _buildInfoRow('District', address.district),
        _buildInfoRow('State', address.state),
        _buildInfoRow('Pincode', address.pincode),
      ],
    );
  }

  Widget _buildIncomeInfo(SubsidyApplication application) {
    final income = application.incomeDetails;
    return _buildInfoCard(
      'Income Information',
      [
        _buildInfoRow(
            'Monthly Income', '₹${income.monthlyIncome.toStringAsFixed(0)}'),
        _buildInfoRow(
            'Annual Income', '₹${income.annualIncome.toStringAsFixed(0)}'),
        _buildInfoRow('Income Source', income.incomeSource),
        _buildInfoRow('Family Members', income.familyMembers.toString()),
        _buildInfoRow(
            'Family Income', '₹${income.familyIncome.toStringAsFixed(0)}'),
      ],
    );
  }

  Widget _buildDocumentsInfo(SubsidyApplication application) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...application.documents.map((document) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      _getDocumentIcon(document.documentType),
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.documentType.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${document.documentName} (${_formatFileSize(document.fileSize)})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 16,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminRemarks(SubsidyApplication application) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Remarks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                application.adminRemarks!,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(DocumentType documentType) {
    switch (documentType) {
      case DocumentType.aadhaarCard:
        return Icons.credit_card;
      case DocumentType.photo:
        return Icons.photo;
      case DocumentType.studentId:
        return Icons.school;
      case DocumentType.seniorCitizenCard:
        return Icons.elderly;
      case DocumentType.disabilityCard:
        return Icons.accessible;
      case DocumentType.bplCard:
        return Icons.card_membership;
      case DocumentType.incomeProof:
        return Icons.receipt;
      case DocumentType.freedomFighterCard:
        return Icons.military_tech;
      case DocumentType.govtEmployeeId:
        return Icons.badge;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
