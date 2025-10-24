import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/subsidy_service.dart';
import '../models/subsidy_application.dart';

class SubsidyState {
  final List<SubsidyApplication> applications;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  const SubsidyState({
    this.applications = const [],
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  SubsidyState copyWith({
    List<SubsidyApplication>? applications,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return SubsidyState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class SubsidyNotifier extends Notifier<SubsidyState> {
  late SubsidyService _subsidyService;

  @override
  SubsidyState build() {
    _subsidyService = ref.watch(subsidyServiceProvider);
    return const SubsidyState();
  }

  Future<void> loadApplications() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final applications = await _subsidyService.getMyApplications();
      state = state.copyWith(
        applications: applications,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> submitApplication(SubsidyApplicationRequest request) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final newApplication = await _subsidyService.submitApplication(request);

      // Add the new application to the list
      final updatedApplications = [newApplication, ...state.applications];

      state = state.copyWith(
        applications: updatedApplications,
        isSubmitting: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<SubsidyApplication?> getApplicationDetails(
      String applicationId) async {
    try {
      return await _subsidyService.getApplicationDetails(applicationId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final subsidyProvider = NotifierProvider<SubsidyNotifier, SubsidyState>(() {
  return SubsidyNotifier();
});
