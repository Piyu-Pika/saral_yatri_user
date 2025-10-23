import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/subsidy_application.dart';
import '../../../data/providers/subsidy_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import 'subsidy_application_form_screen.dart';
import 'subsidy_application_detail_screen.dart';

class SubsidyApplicationScreen extends ConsumerStatefulWidget {
  const SubsidyApplicationScreen({super.key});

  @override
  ConsumerState<SubsidyApplicationScreen> createState() =>
      _SubsidyApplicationScreenState();
}

class _SubsidyApplicationScreenState
    extends ConsumerState<SubsidyApplicationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subsidyProvider.notifier).loadApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subsidyState = ref.watch(subsidyProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Subsidy Applications'),
      body: subsidyState.isLoading
          ? const LoadingWidget()
          : subsidyState.error != null
              ? _buildErrorWidget(subsidyState.error!)
              : _buildContent(subsidyState.applications),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SubsidyApplicationFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Apply for Subsidy'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
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
            'Error loading applications',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(subsidyProvider.notifier).loadApplications();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<SubsidyApplication> applications) {
    if (applications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(subsidyProvider.notifier).loadApplications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return _buildApplicationCard(application);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Applications Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Apply for a subsidy to get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(SubsidyApplication application) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SubsidyApplicationDetailScreen(
                applicationId: application.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      application.subsidyType.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(application.applicationStatus),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Application ID: ${application.id.substring(0, 8)}...',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Submitted: ${_formatDate(application.submittedAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (application.processedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Processed: ${_formatDate(application.processedAt!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (application.adminRemarks?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    application.adminRemarks!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ApplicationStatus status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case ApplicationStatus.pending:
        backgroundColor = AppColors.warning;
        break;
      case ApplicationStatus.underReview:
        backgroundColor = AppColors.info;
        break;
      case ApplicationStatus.approved:
        backgroundColor = AppColors.success;
        break;
      case ApplicationStatus.rejected:
        backgroundColor = AppColors.error;
        break;
      case ApplicationStatus.expired:
        backgroundColor = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}