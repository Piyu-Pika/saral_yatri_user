import 'package:freezed_annotation/freezed_annotation.dart';

part 'subsidy_application.freezed.dart';
part 'subsidy_application.g.dart';

@freezed
class SubsidyApplication with _$SubsidyApplication {
  const factory SubsidyApplication({
    required String id,
    required String userId,
    required SubsidyType subsidyType,
    required ApplicationStatus applicationStatus,
    required String fullName,
    required String phone,
    required String email,
    required String aadhaarNumber,
    required DateTime dateOfBirth,
    required Gender gender,
    required Address address,
    required String applicationReason,
    required IncomeDetails incomeDetails,
    required List<DocumentUpload> documents,
    required DateTime submittedAt,
    DateTime? processedAt,
    String? processedBy,
    String? adminRemarks,
    DateTime? approvedAt,
    String? approvedBy,
    DateTime? validFrom,
    DateTime? validUntil,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SubsidyApplication;

  factory SubsidyApplication.fromJson(Map<String, dynamic> json) =>
      _$SubsidyApplicationFromJson(json);
}

@freezed
class Address with _$Address {
  const factory Address({
    required String street,
    required String city,
    required String district,
    required String state,
    required String pincode,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}

@freezed
class IncomeDetails with _$IncomeDetails {
  const factory IncomeDetails({
    required double monthlyIncome,
    required double annualIncome,
    required String incomeSource,
    required int familyMembers,
    required double familyIncome,
  }) = _IncomeDetails;

  factory IncomeDetails.fromJson(Map<String, dynamic> json) =>
      _$IncomeDetailsFromJson(json);
}

@freezed
class DocumentUpload with _$DocumentUpload {
  const factory DocumentUpload({
    required DocumentType documentType,
    required String documentName,
    required String base64Data,
    required String mimeType,
    required DateTime uploadedAt,
    required int fileSize,
  }) = _DocumentUpload;

  factory DocumentUpload.fromJson(Map<String, dynamic> json) =>
      _$DocumentUploadFromJson(json);
}

@freezed
class SubsidyApplicationRequest with _$SubsidyApplicationRequest {
  const factory SubsidyApplicationRequest({
    required SubsidyType subsidyType,
    required String fullName,
    required String phone,
    required String email,
    required String aadhaarNumber,
    required DateTime dateOfBirth,
    required Gender gender,
    required Address address,
    required String applicationReason,
    required IncomeDetails incomeDetails,
    required List<DocumentUpload> documents,
  }) = _SubsidyApplicationRequest;

  factory SubsidyApplicationRequest.fromJson(Map<String, dynamic> json) =>
      _$SubsidyApplicationRequestFromJson(json);
}

enum SubsidyType {
  @JsonValue('senior_citizen')
  seniorCitizen,
  @JsonValue('student')
  student,
  @JsonValue('disabled_person')
  disabledPerson,
  @JsonValue('bpl')
  bpl,
  @JsonValue('freedom_fighter')
  freedomFighter,
  @JsonValue('govt_employee')
  govtEmployee,
}

enum ApplicationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('under_review')
  underReview,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('expired')
  expired,
}

enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
}

enum DocumentType {
  @JsonValue('aadhaar_card')
  aadhaarCard,
  @JsonValue('senior_citizen_card')
  seniorCitizenCard,
  @JsonValue('student_id')
  studentId,
  @JsonValue('disability_card')
  disabilityCard,
  @JsonValue('bpl_card')
  bplCard,
  @JsonValue('income_proof')
  incomeProof,
  @JsonValue('freedom_fighter_card')
  freedomFighterCard,
  @JsonValue('govt_employee_id')
  govtEmployeeId,
  @JsonValue('photo')
  photo,
}

extension SubsidyTypeExtension on SubsidyType {
  String get displayName {
    switch (this) {
      case SubsidyType.seniorCitizen:
        return 'Senior Citizen';
      case SubsidyType.student:
        return 'Student';
      case SubsidyType.disabledPerson:
        return 'Disabled Person';
      case SubsidyType.bpl:
        return 'Below Poverty Line';
      case SubsidyType.freedomFighter:
        return 'Freedom Fighter';
      case SubsidyType.govtEmployee:
        return 'Government Employee';
    }
  }

  String get description {
    switch (this) {
      case SubsidyType.seniorCitizen:
        return 'For citizens above 60 years';
      case SubsidyType.student:
        return 'For students with valid student ID';
      case SubsidyType.disabledPerson:
        return 'For persons with disabilities';
      case SubsidyType.bpl:
        return 'For Below Poverty Line cardholders';
      case SubsidyType.freedomFighter:
        return 'For freedom fighters';
      case SubsidyType.govtEmployee:
        return 'For government employees';
    }
  }

  List<DocumentType> get requiredDocuments {
    switch (this) {
      case SubsidyType.seniorCitizen:
        return [DocumentType.aadhaarCard, DocumentType.seniorCitizenCard, DocumentType.photo];
      case SubsidyType.student:
        return [DocumentType.aadhaarCard, DocumentType.studentId, DocumentType.photo];
      case SubsidyType.disabledPerson:
        return [DocumentType.aadhaarCard, DocumentType.disabilityCard, DocumentType.photo];
      case SubsidyType.bpl:
        return [DocumentType.aadhaarCard, DocumentType.bplCard, DocumentType.incomeProof, DocumentType.photo];
      case SubsidyType.freedomFighter:
        return [DocumentType.aadhaarCard, DocumentType.freedomFighterCard, DocumentType.photo];
      case SubsidyType.govtEmployee:
        return [DocumentType.aadhaarCard, DocumentType.govtEmployeeId, DocumentType.photo];
    }
  }
}

extension ApplicationStatusExtension on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.expired:
        return 'Expired';
    }
  }
}

extension DocumentTypeExtension on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.aadhaarCard:
        return 'Aadhaar Card';
      case DocumentType.seniorCitizenCard:
        return 'Senior Citizen Card';
      case DocumentType.studentId:
        return 'Student ID';
      case DocumentType.disabilityCard:
        return 'Disability Card';
      case DocumentType.bplCard:
        return 'BPL Card';
      case DocumentType.incomeProof:
        return 'Income Proof';
      case DocumentType.freedomFighterCard:
        return 'Freedom Fighter Card';
      case DocumentType.govtEmployeeId:
        return 'Government Employee ID';
      case DocumentType.photo:
        return 'Passport Photo';
    }
  }
}