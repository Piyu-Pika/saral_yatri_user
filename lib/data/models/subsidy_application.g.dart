// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subsidy_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubsidyApplicationImpl _$$SubsidyApplicationImplFromJson(
        Map<String, dynamic> json) =>
    _$SubsidyApplicationImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subsidyType: $enumDecode(_$SubsidyTypeEnumMap, json['subsidyType']),
      applicationStatus:
          $enumDecode(_$ApplicationStatusEnumMap, json['applicationStatus']),
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      aadhaarNumber: json['aadhaarNumber'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      applicationReason: json['applicationReason'] as String,
      incomeDetails:
          IncomeDetails.fromJson(json['incomeDetails'] as Map<String, dynamic>),
      documents: (json['documents'] as List<dynamic>)
          .map((e) => DocumentUpload.fromJson(e as Map<String, dynamic>))
          .toList(),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
      processedBy: json['processedBy'] as String?,
      adminRemarks: json['adminRemarks'] as String?,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      approvedBy: json['approvedBy'] as String?,
      validFrom: json['validFrom'] == null
          ? null
          : DateTime.parse(json['validFrom'] as String),
      validUntil: json['validUntil'] == null
          ? null
          : DateTime.parse(json['validUntil'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SubsidyApplicationImplToJson(
        _$SubsidyApplicationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'subsidyType': _$SubsidyTypeEnumMap[instance.subsidyType]!,
      'applicationStatus':
          _$ApplicationStatusEnumMap[instance.applicationStatus]!,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'email': instance.email,
      'aadhaarNumber': instance.aadhaarNumber,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': _$GenderEnumMap[instance.gender]!,
      'address': instance.address,
      'applicationReason': instance.applicationReason,
      'incomeDetails': instance.incomeDetails,
      'documents': instance.documents,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'processedAt': instance.processedAt?.toIso8601String(),
      'processedBy': instance.processedBy,
      'adminRemarks': instance.adminRemarks,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'approvedBy': instance.approvedBy,
      'validFrom': instance.validFrom?.toIso8601String(),
      'validUntil': instance.validUntil?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$SubsidyTypeEnumMap = {
  SubsidyType.seniorCitizen: 'senior_citizen',
  SubsidyType.student: 'student',
  SubsidyType.disabledPerson: 'disabled_person',
  SubsidyType.bpl: 'bpl',
  SubsidyType.freedomFighter: 'freedom_fighter',
  SubsidyType.govtEmployee: 'govt_employee',
};

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.pending: 'pending',
  ApplicationStatus.underReview: 'under_review',
  ApplicationStatus.approved: 'approved',
  ApplicationStatus.rejected: 'rejected',
  ApplicationStatus.expired: 'expired',
};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};

_$AddressImpl _$$AddressImplFromJson(Map<String, dynamic> json) =>
    _$AddressImpl(
      street: json['street'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
    );

Map<String, dynamic> _$$AddressImplToJson(_$AddressImpl instance) =>
    <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'district': instance.district,
      'state': instance.state,
      'pincode': instance.pincode,
    };

_$IncomeDetailsImpl _$$IncomeDetailsImplFromJson(Map<String, dynamic> json) =>
    _$IncomeDetailsImpl(
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      annualIncome: (json['annualIncome'] as num).toDouble(),
      incomeSource: json['incomeSource'] as String,
      familyMembers: (json['familyMembers'] as num).toInt(),
      familyIncome: (json['familyIncome'] as num).toDouble(),
    );

Map<String, dynamic> _$$IncomeDetailsImplToJson(_$IncomeDetailsImpl instance) =>
    <String, dynamic>{
      'monthlyIncome': instance.monthlyIncome,
      'annualIncome': instance.annualIncome,
      'incomeSource': instance.incomeSource,
      'familyMembers': instance.familyMembers,
      'familyIncome': instance.familyIncome,
    };

_$DocumentUploadImpl _$$DocumentUploadImplFromJson(Map<String, dynamic> json) =>
    _$DocumentUploadImpl(
      documentType: $enumDecode(_$DocumentTypeEnumMap, json['documentType']),
      documentName: json['documentName'] as String,
      base64Data: json['base64Data'] as String,
      mimeType: json['mimeType'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      fileSize: (json['fileSize'] as num).toInt(),
    );

Map<String, dynamic> _$$DocumentUploadImplToJson(
        _$DocumentUploadImpl instance) =>
    <String, dynamic>{
      'documentType': _$DocumentTypeEnumMap[instance.documentType]!,
      'documentName': instance.documentName,
      'base64Data': instance.base64Data,
      'mimeType': instance.mimeType,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'fileSize': instance.fileSize,
    };

const _$DocumentTypeEnumMap = {
  DocumentType.aadhaarCard: 'aadhaar_card',
  DocumentType.seniorCitizenCard: 'senior_citizen_card',
  DocumentType.studentId: 'student_id',
  DocumentType.disabilityCard: 'disability_card',
  DocumentType.bplCard: 'bpl_card',
  DocumentType.incomeProof: 'income_proof',
  DocumentType.freedomFighterCard: 'freedom_fighter_card',
  DocumentType.govtEmployeeId: 'govt_employee_id',
  DocumentType.photo: 'photo',
};

_$SubsidyApplicationRequestImpl _$$SubsidyApplicationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SubsidyApplicationRequestImpl(
      subsidyType: $enumDecode(_$SubsidyTypeEnumMap, json['subsidyType']),
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      aadhaarNumber: json['aadhaarNumber'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      applicationReason: json['applicationReason'] as String,
      incomeDetails:
          IncomeDetails.fromJson(json['incomeDetails'] as Map<String, dynamic>),
      documents: (json['documents'] as List<dynamic>)
          .map((e) => DocumentUpload.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SubsidyApplicationRequestImplToJson(
        _$SubsidyApplicationRequestImpl instance) =>
    <String, dynamic>{
      'subsidyType': _$SubsidyTypeEnumMap[instance.subsidyType]!,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'email': instance.email,
      'aadhaarNumber': instance.aadhaarNumber,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': _$GenderEnumMap[instance.gender]!,
      'address': instance.address,
      'applicationReason': instance.applicationReason,
      'incomeDetails': instance.incomeDetails,
      'documents': instance.documents,
    };
