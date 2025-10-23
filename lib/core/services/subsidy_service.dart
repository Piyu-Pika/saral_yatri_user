import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../network/api_client.dart';
import '../utils/logger.dart';
import '../../data/models/subsidy_application.dart';

class SubsidyService {
  Future<SubsidyApplication> submitApplication(
    SubsidyApplicationRequest request,
  ) async {
    try {
      AppLogger.info('[SubsidyService] Submitting application...');
      final requestData = request.toJson();
      AppLogger.info('[SubsidyService] Request data: $requestData');
      
      final response = await ApiClient.post(
        ApiConstants.submitSubsidyApplication,
        data: requestData,
      );

      AppLogger.info('[SubsidyService] Application submitted successfully');
      return SubsidyApplication.fromJson(response.data['application']);
    } on DioException catch (e) {
      AppLogger.error('[SubsidyService] Submission failed: ${e.message}');
      if (e.response?.data != null) {
        AppLogger.error('[SubsidyService] Error response: ${e.response?.data}');
      }
      throw _handleError(e);
    } catch (e) {
      AppLogger.error('[SubsidyService] Unexpected error: $e');
      throw 'Failed to submit application: $e';
    }
  }

  Future<List<SubsidyApplication>> getMyApplications() async {
    try {
      AppLogger.info('[SubsidyService] Loading user applications...');
      final response = await ApiClient.get(ApiConstants.mySubsidyApplications);

      AppLogger.info('[SubsidyService] Response received: ${response.data}');
      final applicationsData = response.data['applications'];
      
      // Handle case when applications is null (no applications yet)
      if (applicationsData == null) {
        AppLogger.info('[SubsidyService] No applications found (null response)');
        return [];
      }
      
      // Handle case when applications is not a list
      if (applicationsData is! List) {
        AppLogger.warning('[SubsidyService] Applications data is not a list: ${applicationsData.runtimeType}');
        return [];
      }
      
      final List<dynamic> applicationsJson = applicationsData;
      AppLogger.info('[SubsidyService] Found ${applicationsJson.length} applications');
      
      return applicationsJson
          .map((json) => SubsidyApplication.fromJson(json))
          .toList();
    } on DioException catch (e) {
      AppLogger.error('[SubsidyService] DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      // Handle any other parsing errors
      AppLogger.error('[SubsidyService] Parsing error: $e');
      throw 'Failed to parse applications data: $e';
    }
  }

  Future<SubsidyApplication> getApplicationDetails(String applicationId) async {
    try {
      final response = await ApiClient.get(
        '${ApiConstants.subsidyApplicationDetails}/$applicationId',
      );

      return SubsidyApplication.fromJson(response.data['application']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    // First check if there's a specific error message from the server
    if (e.response?.data != null) {
      if (e.response?.data['error'] != null) {
        return e.response!.data['error'];
      }
      // Sometimes the error might be in a different field
      if (e.response?.data['message'] != null) {
        return e.response!.data['message'];
      }
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400:
            // Provide more detailed error for 400 responses
            String baseMessage = 'Invalid application data.';
            if (e.response?.data != null) {
              // Try to extract validation errors
              final responseData = e.response!.data;
              if (responseData is Map && responseData.containsKey('errors')) {
                final errors = responseData['errors'];
                if (errors is Map) {
                  final errorMessages = <String>[];
                  errors.forEach((field, message) {
                    errorMessages.add('$field: $message');
                  });
                  if (errorMessages.isNotEmpty) {
                    return '$baseMessage\n${errorMessages.join('\n')}';
                  }
                }
              }
              return '$baseMessage Response: ${e.response?.data}';
            }
            return '$baseMessage Please check your information.';
          case 401:
            return 'Authentication required. Please login again.';
          case 403:
            return 'Access denied.';
          case 404:
            return 'Application not found.';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return 'An error occurred (${e.response?.statusCode}). Please try again.';
        }
      default:
        return 'Network error. Please check your connection.';
    }
  }
}

final subsidyServiceProvider = Provider<SubsidyService>((ref) {
  return SubsidyService();
});