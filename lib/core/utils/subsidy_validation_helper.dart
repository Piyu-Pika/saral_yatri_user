import '../utils/logger.dart';
import '../../data/models/subsidy_application.dart';

class SubsidyValidationHelper {
  static void validateAndLogRequest(SubsidyApplicationRequest request) {
    AppLogger.info('[SubsidyValidation] Validating request...');

    // Log basic info
    AppLogger.info('[SubsidyValidation] Subsidy Type: ${request.subsidyType}');
    AppLogger.info('[SubsidyValidation] Full Name: ${request.fullName}');
    AppLogger.info('[SubsidyValidation] Phone: ${request.phone}');
    AppLogger.info('[SubsidyValidation] Email: ${request.email}');
    AppLogger.info('[SubsidyValidation] Aadhaar: ${request.aadhaarNumber}');
    AppLogger.info(
        '[SubsidyValidation] DOB: ${request.dateOfBirth.toIso8601String()}');
    AppLogger.info('[SubsidyValidation] Gender: ${request.gender}');

    // Log address
    AppLogger.info(
        '[SubsidyValidation] Address: ${request.address.street}, ${request.address.city}, ${request.address.district}, ${request.address.state} - ${request.address.pincode}');

    // Log income details
    AppLogger.info(
        '[SubsidyValidation] Monthly Income: ${request.incomeDetails.monthlyIncome}');
    AppLogger.info(
        '[SubsidyValidation] Annual Income: ${request.incomeDetails.annualIncome}');
    AppLogger.info(
        '[SubsidyValidation] Income Source: ${request.incomeDetails.incomeSource}');
    AppLogger.info(
        '[SubsidyValidation] Family Members: ${request.incomeDetails.familyMembers}');
    AppLogger.info(
        '[SubsidyValidation] Family Income: ${request.incomeDetails.familyIncome}');

    // Log documents
    AppLogger.info(
        '[SubsidyValidation] Documents count: ${request.documents.length}');
    for (int i = 0; i < request.documents.length; i++) {
      final doc = request.documents[i];
      AppLogger.info(
          '[SubsidyValidation] Document $i: ${doc.documentType} - ${doc.documentName} (${doc.fileSize} bytes)');
    }

    // Validate required fields
    final validationErrors = <String>[];

    if (request.fullName.trim().isEmpty) {
      validationErrors.add('Full name is empty');
    }

    if (request.phone.trim().isEmpty) {
      validationErrors.add('Phone is empty');
    }

    if (request.email.trim().isEmpty) {
      validationErrors.add('Email is empty');
    }

    if (request.aadhaarNumber.trim().isEmpty) {
      validationErrors.add('Aadhaar number is empty');
    }

    if (request.address.street.trim().isEmpty) {
      validationErrors.add('Street address is empty');
    }

    if (request.address.city.trim().isEmpty) {
      validationErrors.add('City is empty');
    }

    if (request.address.state.trim().isEmpty) {
      validationErrors.add('State is empty');
    }

    if (request.address.pincode.trim().isEmpty) {
      validationErrors.add('Pincode is empty');
    }

    if (request.incomeDetails.monthlyIncome < 0) {
      validationErrors.add('Monthly income is negative');
    }

    if (request.incomeDetails.annualIncome < 0) {
      validationErrors.add('Annual income is negative');
    }

    if (request.incomeDetails.familyMembers < 1) {
      validationErrors.add('Family members is less than 1');
    }

    if (request.documents.isEmpty) {
      validationErrors.add('No documents provided');
    }

    // Check required documents for subsidy type
    final requiredDocs = request.subsidyType.requiredDocuments;
    final providedDocTypes =
        request.documents.map((d) => d.documentType).toSet();

    for (final requiredDoc in requiredDocs) {
      if (!providedDocTypes.contains(requiredDoc)) {
        validationErrors
            .add('Missing required document: ${requiredDoc.displayName}');
      }
    }

    if (validationErrors.isNotEmpty) {
      AppLogger.error('[SubsidyValidation] Validation errors found:');
      for (final error in validationErrors) {
        AppLogger.error('[SubsidyValidation] - $error');
      }
    } else {
      AppLogger.info('[SubsidyValidation] All validations passed');
    }

    // Log the JSON structure
    try {
      final json = request.toJson();
      AppLogger.info(
          '[SubsidyValidation] JSON structure keys: ${json.keys.toList()}');

      // Check for any null values
      json.forEach((key, value) {
        if (value == null) {
          AppLogger.warning(
              '[SubsidyValidation] Null value found for key: $key');
        }
      });
    } catch (e) {
      AppLogger.error('[SubsidyValidation] Error serializing to JSON: $e');
    }
  }

  static bool validatePhoneNumber(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if it's a valid Indian phone number
    if (digits.length == 10) {
      // 10 digit number (without country code)
      return digits
          .startsWith(RegExp(r'[6-9]')); // Indian mobile numbers start with 6-9
    } else if (digits.length == 12 && digits.startsWith('91')) {
      // 12 digit number with country code
      final mobileNumber = digits.substring(2);
      return mobileNumber.startsWith(RegExp(r'[6-9]'));
    }

    return false;
  }

  static bool validateAadhaarNumber(String aadhaar) {
    final digits = aadhaar.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length == 12;
  }

  static bool validatePincode(String pincode) {
    final digits = pincode.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length == 6;
  }

  static bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }
}
