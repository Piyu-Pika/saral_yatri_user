// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subsidy_application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SubsidyApplication _$SubsidyApplicationFromJson(Map<String, dynamic> json) {
  return _SubsidyApplication.fromJson(json);
}

/// @nodoc
mixin _$SubsidyApplication {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  SubsidyType get subsidyType => throw _privateConstructorUsedError;
  ApplicationStatus get applicationStatus => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get aadhaarNumber => throw _privateConstructorUsedError;
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  Gender get gender => throw _privateConstructorUsedError;
  Address get address => throw _privateConstructorUsedError;
  String get applicationReason => throw _privateConstructorUsedError;
  IncomeDetails get incomeDetails => throw _privateConstructorUsedError;
  List<DocumentUpload> get documents => throw _privateConstructorUsedError;
  DateTime get submittedAt => throw _privateConstructorUsedError;
  DateTime? get processedAt => throw _privateConstructorUsedError;
  String? get processedBy => throw _privateConstructorUsedError;
  String? get adminRemarks => throw _privateConstructorUsedError;
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  String? get approvedBy => throw _privateConstructorUsedError;
  DateTime? get validFrom => throw _privateConstructorUsedError;
  DateTime? get validUntil => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SubsidyApplication to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubsidyApplication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubsidyApplicationCopyWith<SubsidyApplication> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubsidyApplicationCopyWith<$Res> {
  factory $SubsidyApplicationCopyWith(
          SubsidyApplication value, $Res Function(SubsidyApplication) then) =
      _$SubsidyApplicationCopyWithImpl<$Res, SubsidyApplication>;
  @useResult
  $Res call(
      {String id,
      String userId,
      SubsidyType subsidyType,
      ApplicationStatus applicationStatus,
      String fullName,
      String phone,
      String email,
      String aadhaarNumber,
      DateTime dateOfBirth,
      Gender gender,
      Address address,
      String applicationReason,
      IncomeDetails incomeDetails,
      List<DocumentUpload> documents,
      DateTime submittedAt,
      DateTime? processedAt,
      String? processedBy,
      String? adminRemarks,
      DateTime? approvedAt,
      String? approvedBy,
      DateTime? validFrom,
      DateTime? validUntil,
      DateTime createdAt,
      DateTime updatedAt});

  $AddressCopyWith<$Res> get address;
  $IncomeDetailsCopyWith<$Res> get incomeDetails;
}

/// @nodoc
class _$SubsidyApplicationCopyWithImpl<$Res, $Val extends SubsidyApplication>
    implements $SubsidyApplicationCopyWith<$Res> {
  _$SubsidyApplicationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubsidyApplication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subsidyType = null,
    Object? applicationStatus = null,
    Object? fullName = null,
    Object? phone = null,
    Object? email = null,
    Object? aadhaarNumber = null,
    Object? dateOfBirth = null,
    Object? gender = null,
    Object? address = null,
    Object? applicationReason = null,
    Object? incomeDetails = null,
    Object? documents = null,
    Object? submittedAt = null,
    Object? processedAt = freezed,
    Object? processedBy = freezed,
    Object? adminRemarks = freezed,
    Object? approvedAt = freezed,
    Object? approvedBy = freezed,
    Object? validFrom = freezed,
    Object? validUntil = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      subsidyType: null == subsidyType
          ? _value.subsidyType
          : subsidyType // ignore: cast_nullable_to_non_nullable
              as SubsidyType,
      applicationStatus: null == applicationStatus
          ? _value.applicationStatus
          : applicationStatus // ignore: cast_nullable_to_non_nullable
              as ApplicationStatus,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      aadhaarNumber: null == aadhaarNumber
          ? _value.aadhaarNumber
          : aadhaarNumber // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: null == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address,
      applicationReason: null == applicationReason
          ? _value.applicationReason
          : applicationReason // ignore: cast_nullable_to_non_nullable
              as String,
      incomeDetails: null == incomeDetails
          ? _value.incomeDetails
          : incomeDetails // ignore: cast_nullable_to_non_nullable
              as IncomeDetails,
      documents: null == documents
          ? _value.documents
          : documents // ignore: cast_nullable_to_non_nullable
              as List<DocumentUpload>,
      submittedAt: null == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      processedBy: freezed == processedBy
          ? _value.processedBy
          : processedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      adminRemarks: freezed == adminRemarks
          ? _value.adminRemarks
          : adminRemarks // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAt: freezed == approvedAt
          ? _value.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      approvedBy: freezed == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      validFrom: freezed == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of SubsidyApplication
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AddressCopyWith<$Res> get address {
    return $AddressCopyWith<$Res>(_value.address, (value) {
      return _then(_value.copyWith(address: value) as $Val);
    });
  }

  /// Create a copy of SubsidyApplication
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IncomeDetailsCopyWith<$Res> get incomeDetails {
    return $IncomeDetailsCopyWith<$Res>(_value.incomeDetails, (value) {
      return _then(_value.copyWith(incomeDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SubsidyApplicationImplCopyWith<$Res>
    implements $SubsidyApplicationCopyWith<$Res> {
  factory _$$SubsidyApplicationImplCopyWith(_$SubsidyApplicationImpl value,
          $Res Function(_$SubsidyApplicationImpl) then) =
      __$$SubsidyApplicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      SubsidyType subsidyType,
      ApplicationStatus applicationStatus,
      String fullName,
      String phone,
      String email,
      String aadhaarNumber,
      DateTime dateOfBirth,
      Gender gender,
      Address address,
      String applicationReason,
      IncomeDetails incomeDetails,
      List<DocumentUpload> documents,
      DateTime submittedAt,
      DateTime? processedAt,
      String? processedBy,
      String? adminRemarks,
      DateTime? approvedAt,
      String? approvedBy,
      DateTime? validFrom,
      DateTime? validUntil,
      DateTime createdAt,
      DateTime updatedAt});

  @override
  $AddressCopyWith<$Res> get address;
  @override
  $IncomeDetailsCopyWith<$Res> get incomeDetails;
}

/// @nodoc
class __$$SubsidyApplicationImplCopyWithImpl<$Res>
    extends _$SubsidyApplicationCopyWithImpl<$Res, _$SubsidyApplicationImpl>
    implements _$$SubsidyApplicationImplCopyWith<$Res> {
  __$$SubsidyApplicationImplCopyWithImpl(_$SubsidyApplicationImpl _value,
      $Res Function(_$SubsidyApplicationImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubsidyApplication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? subsidyType = null,
    Object? applicationStatus = null,
    Object? fullName = null,
    Object? phone = null,
    Object? email = null,
    Object? aadhaarNumber = null,
    Object? dateOfBirth = null,
    Object? gender = null,
    Object? address = null,
    Object? applicationReason = null,
    Object? incomeDetails = null,
    Object? documents = null,
    Object? submittedAt = null,
    Object? processedAt = freezed,
    Object? processedBy = freezed,
    Object? adminRemarks = freezed,
    Object? approvedAt = freezed,
    Object? approvedBy = freezed,
    Object? validFrom = freezed,
    Object? validUntil = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SubsidyApplicationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      subsidyType: null == subsidyType
          ? _value.subsidyType
          : subsidyType // ignore: cast_nullable_to_non_nullable
              as SubsidyType,
      applicationStatus: null == applicationStatus
          ? _value.applicationStatus
          : applicationStatus // ignore: cast_nullable_to_non_nullable
              as ApplicationStatus,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      aadhaarNumber: null == aadhaarNumber
          ? _value.aadhaarNumber
          : aadhaarNumber // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: null == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address,
      applicationReason: null == applicationReason
          ? _value.applicationReason
          : applicationReason // ignore: cast_nullable_to_non_nullable
              as String,
      incomeDetails: null == incomeDetails
          ? _value.incomeDetails
          : incomeDetails // ignore: cast_nullable_to_non_nullable
              as IncomeDetails,
      documents: null == documents
          ? _value._documents
          : documents // ignore: cast_nullable_to_non_nullable
              as List<DocumentUpload>,
      submittedAt: null == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      processedBy: freezed == processedBy
          ? _value.processedBy
          : processedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      adminRemarks: freezed == adminRemarks
          ? _value.adminRemarks
          : adminRemarks // ignore: cast_nullable_to_non_nullable
              as String?,
      approvedAt: freezed == approvedAt
          ? _value.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      approvedBy: freezed == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      validFrom: freezed == validFrom
          ? _value.validFrom
          : validFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      validUntil: freezed == validUntil
          ? _value.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubsidyApplicationImpl implements _SubsidyApplication {
  const _$SubsidyApplicationImpl(
      {required this.id,
      required this.userId,
      required this.subsidyType,
      required this.applicationStatus,
      required this.fullName,
      required this.phone,
      required this.email,
      required this.aadhaarNumber,
      required this.dateOfBirth,
      required this.gender,
      required this.address,
      required this.applicationReason,
      required this.incomeDetails,
      required final List<DocumentUpload> documents,
      required this.submittedAt,
      this.processedAt,
      this.processedBy,
      this.adminRemarks,
      this.approvedAt,
      this.approvedBy,
      this.validFrom,
      this.validUntil,
      required this.createdAt,
      required this.updatedAt})
      : _documents = documents;

  factory _$SubsidyApplicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubsidyApplicationImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final SubsidyType subsidyType;
  @override
  final ApplicationStatus applicationStatus;
  @override
  final String fullName;
  @override
  final String phone;
  @override
  final String email;
  @override
  final String aadhaarNumber;
  @override
  final DateTime dateOfBirth;
  @override
  final Gender gender;
  @override
  final Address address;
  @override
  final String applicationReason;
  @override
  final IncomeDetails incomeDetails;
  final List<DocumentUpload> _documents;
  @override
  List<DocumentUpload> get documents {
    if (_documents is EqualUnmodifiableListView) return _documents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_documents);
  }

  @override
  final DateTime submittedAt;
  @override
  final DateTime? processedAt;
  @override
  final String? processedBy;
  @override
  final String? adminRemarks;
  @override
  final DateTime? approvedAt;
  @override
  final String? approvedBy;
  @override
  final DateTime? validFrom;
  @override
  final DateTime? validUntil;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SubsidyApplication(id: $id, userId: $userId, subsidyType: $subsidyType, applicationStatus: $applicationStatus, fullName: $fullName, phone: $phone, email: $email, aadhaarNumber: $aadhaarNumber, dateOfBirth: $dateOfBirth, gender: $gender, address: $address, applicationReason: $applicationReason, incomeDetails: $incomeDetails, documents: $documents, submittedAt: $submittedAt, processedAt: $processedAt, processedBy: $processedBy, adminRemarks: $adminRemarks, approvedAt: $approvedAt, approvedBy: $approvedBy, validFrom: $validFrom, validUntil: $validUntil, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubsidyApplicationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.subsidyType, subsidyType) ||
                other.subsidyType == subsidyType) &&
            (identical(other.applicationStatus, applicationStatus) ||
                other.applicationStatus == applicationStatus) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.aadhaarNumber, aadhaarNumber) ||
                other.aadhaarNumber == aadhaarNumber) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.applicationReason, applicationReason) ||
                other.applicationReason == applicationReason) &&
            (identical(other.incomeDetails, incomeDetails) ||
                other.incomeDetails == incomeDetails) &&
            const DeepCollectionEquality()
                .equals(other._documents, _documents) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt) &&
            (identical(other.processedBy, processedBy) ||
                other.processedBy == processedBy) &&
            (identical(other.adminRemarks, adminRemarks) ||
                other.adminRemarks == adminRemarks) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.validFrom, validFrom) ||
                other.validFrom == validFrom) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        subsidyType,
        applicationStatus,
        fullName,
        phone,
        email,
        aadhaarNumber,
        dateOfBirth,
        gender,
        address,
        applicationReason,
        incomeDetails,
        const DeepCollectionEquality().hash(_documents),
        submittedAt,
        processedAt,
        processedBy,
        adminRemarks,
        approvedAt,
        approvedBy,
        validFrom,
        validUntil,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of SubsidyApplication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubsidyApplicationImplCopyWith<_$SubsidyApplicationImpl> get copyWith =>
      __$$SubsidyApplicationImplCopyWithImpl<_$SubsidyApplicationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubsidyApplicationImplToJson(
      this,
    );
  }
}

abstract class _SubsidyApplication implements SubsidyApplication {
  const factory _SubsidyApplication(
      {required final String id,
      required final String userId,
      required final SubsidyType subsidyType,
      required final ApplicationStatus applicationStatus,
      required final String fullName,
      required final String phone,
      required final String email,
      required final String aadhaarNumber,
      required final DateTime dateOfBirth,
      required final Gender gender,
      required final Address address,
      required final String applicationReason,
      required final IncomeDetails incomeDetails,
      required final List<DocumentUpload> documents,
      required final DateTime submittedAt,
      final DateTime? processedAt,
      final String? processedBy,
      final String? adminRemarks,
      final DateTime? approvedAt,
      final String? approvedBy,
      final DateTime? validFrom,
      final DateTime? validUntil,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$SubsidyApplicationImpl;

  factory _SubsidyApplication.fromJson(Map<String, dynamic> json) =
      _$SubsidyApplicationImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  SubsidyType get subsidyType;
  @override
  ApplicationStatus get applicationStatus;
  @override
  String get fullName;
  @override
  String get phone;
  @override
  String get email;
  @override
  String get aadhaarNumber;
  @override
  DateTime get dateOfBirth;
  @override
  Gender get gender;
  @override
  Address get address;
  @override
  String get applicationReason;
  @override
  IncomeDetails get incomeDetails;
  @override
  List<DocumentUpload> get documents;
  @override
  DateTime get submittedAt;
  @override
  DateTime? get processedAt;
  @override
  String? get processedBy;
  @override
  String? get adminRemarks;
  @override
  DateTime? get approvedAt;
  @override
  String? get approvedBy;
  @override
  DateTime? get validFrom;
  @override
  DateTime? get validUntil;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SubsidyApplication
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubsidyApplicationImplCopyWith<_$SubsidyApplicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Address _$AddressFromJson(Map<String, dynamic> json) {
  return _Address.fromJson(json);
}

/// @nodoc
mixin _$Address {
  String get street => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get district => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  String get pincode => throw _privateConstructorUsedError;

  /// Serializes this Address to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressCopyWith<Address> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressCopyWith<$Res> {
  factory $AddressCopyWith(Address value, $Res Function(Address) then) =
      _$AddressCopyWithImpl<$Res, Address>;
  @useResult
  $Res call(
      {String street,
      String city,
      String district,
      String state,
      String pincode});
}

/// @nodoc
class _$AddressCopyWithImpl<$Res, $Val extends Address>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? street = null,
    Object? city = null,
    Object? district = null,
    Object? state = null,
    Object? pincode = null,
  }) {
    return _then(_value.copyWith(
      street: null == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      pincode: null == pincode
          ? _value.pincode
          : pincode // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AddressImplCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$$AddressImplCopyWith(
          _$AddressImpl value, $Res Function(_$AddressImpl) then) =
      __$$AddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String street,
      String city,
      String district,
      String state,
      String pincode});
}

/// @nodoc
class __$$AddressImplCopyWithImpl<$Res>
    extends _$AddressCopyWithImpl<$Res, _$AddressImpl>
    implements _$$AddressImplCopyWith<$Res> {
  __$$AddressImplCopyWithImpl(
      _$AddressImpl _value, $Res Function(_$AddressImpl) _then)
      : super(_value, _then);

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? street = null,
    Object? city = null,
    Object? district = null,
    Object? state = null,
    Object? pincode = null,
  }) {
    return _then(_$AddressImpl(
      street: null == street
          ? _value.street
          : street // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      district: null == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      pincode: null == pincode
          ? _value.pincode
          : pincode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AddressImpl implements _Address {
  const _$AddressImpl(
      {required this.street,
      required this.city,
      required this.district,
      required this.state,
      required this.pincode});

  factory _$AddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressImplFromJson(json);

  @override
  final String street;
  @override
  final String city;
  @override
  final String district;
  @override
  final String state;
  @override
  final String pincode;

  @override
  String toString() {
    return 'Address(street: $street, city: $city, district: $district, state: $state, pincode: $pincode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressImpl &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pincode, pincode) || other.pincode == pincode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, street, city, district, state, pincode);

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      __$$AddressImplCopyWithImpl<_$AddressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddressImplToJson(
      this,
    );
  }
}

abstract class _Address implements Address {
  const factory _Address(
      {required final String street,
      required final String city,
      required final String district,
      required final String state,
      required final String pincode}) = _$AddressImpl;

  factory _Address.fromJson(Map<String, dynamic> json) = _$AddressImpl.fromJson;

  @override
  String get street;
  @override
  String get city;
  @override
  String get district;
  @override
  String get state;
  @override
  String get pincode;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IncomeDetails _$IncomeDetailsFromJson(Map<String, dynamic> json) {
  return _IncomeDetails.fromJson(json);
}

/// @nodoc
mixin _$IncomeDetails {
  double get monthlyIncome => throw _privateConstructorUsedError;
  double get annualIncome => throw _privateConstructorUsedError;
  String get incomeSource => throw _privateConstructorUsedError;
  int get familyMembers => throw _privateConstructorUsedError;
  double get familyIncome => throw _privateConstructorUsedError;

  /// Serializes this IncomeDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IncomeDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IncomeDetailsCopyWith<IncomeDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncomeDetailsCopyWith<$Res> {
  factory $IncomeDetailsCopyWith(
          IncomeDetails value, $Res Function(IncomeDetails) then) =
      _$IncomeDetailsCopyWithImpl<$Res, IncomeDetails>;
  @useResult
  $Res call(
      {double monthlyIncome,
      double annualIncome,
      String incomeSource,
      int familyMembers,
      double familyIncome});
}

/// @nodoc
class _$IncomeDetailsCopyWithImpl<$Res, $Val extends IncomeDetails>
    implements $IncomeDetailsCopyWith<$Res> {
  _$IncomeDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IncomeDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthlyIncome = null,
    Object? annualIncome = null,
    Object? incomeSource = null,
    Object? familyMembers = null,
    Object? familyIncome = null,
  }) {
    return _then(_value.copyWith(
      monthlyIncome: null == monthlyIncome
          ? _value.monthlyIncome
          : monthlyIncome // ignore: cast_nullable_to_non_nullable
              as double,
      annualIncome: null == annualIncome
          ? _value.annualIncome
          : annualIncome // ignore: cast_nullable_to_non_nullable
              as double,
      incomeSource: null == incomeSource
          ? _value.incomeSource
          : incomeSource // ignore: cast_nullable_to_non_nullable
              as String,
      familyMembers: null == familyMembers
          ? _value.familyMembers
          : familyMembers // ignore: cast_nullable_to_non_nullable
              as int,
      familyIncome: null == familyIncome
          ? _value.familyIncome
          : familyIncome // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IncomeDetailsImplCopyWith<$Res>
    implements $IncomeDetailsCopyWith<$Res> {
  factory _$$IncomeDetailsImplCopyWith(
          _$IncomeDetailsImpl value, $Res Function(_$IncomeDetailsImpl) then) =
      __$$IncomeDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double monthlyIncome,
      double annualIncome,
      String incomeSource,
      int familyMembers,
      double familyIncome});
}

/// @nodoc
class __$$IncomeDetailsImplCopyWithImpl<$Res>
    extends _$IncomeDetailsCopyWithImpl<$Res, _$IncomeDetailsImpl>
    implements _$$IncomeDetailsImplCopyWith<$Res> {
  __$$IncomeDetailsImplCopyWithImpl(
      _$IncomeDetailsImpl _value, $Res Function(_$IncomeDetailsImpl) _then)
      : super(_value, _then);

  /// Create a copy of IncomeDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? monthlyIncome = null,
    Object? annualIncome = null,
    Object? incomeSource = null,
    Object? familyMembers = null,
    Object? familyIncome = null,
  }) {
    return _then(_$IncomeDetailsImpl(
      monthlyIncome: null == monthlyIncome
          ? _value.monthlyIncome
          : monthlyIncome // ignore: cast_nullable_to_non_nullable
              as double,
      annualIncome: null == annualIncome
          ? _value.annualIncome
          : annualIncome // ignore: cast_nullable_to_non_nullable
              as double,
      incomeSource: null == incomeSource
          ? _value.incomeSource
          : incomeSource // ignore: cast_nullable_to_non_nullable
              as String,
      familyMembers: null == familyMembers
          ? _value.familyMembers
          : familyMembers // ignore: cast_nullable_to_non_nullable
              as int,
      familyIncome: null == familyIncome
          ? _value.familyIncome
          : familyIncome // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IncomeDetailsImpl implements _IncomeDetails {
  const _$IncomeDetailsImpl(
      {required this.monthlyIncome,
      required this.annualIncome,
      required this.incomeSource,
      required this.familyMembers,
      required this.familyIncome});

  factory _$IncomeDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$IncomeDetailsImplFromJson(json);

  @override
  final double monthlyIncome;
  @override
  final double annualIncome;
  @override
  final String incomeSource;
  @override
  final int familyMembers;
  @override
  final double familyIncome;

  @override
  String toString() {
    return 'IncomeDetails(monthlyIncome: $monthlyIncome, annualIncome: $annualIncome, incomeSource: $incomeSource, familyMembers: $familyMembers, familyIncome: $familyIncome)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncomeDetailsImpl &&
            (identical(other.monthlyIncome, monthlyIncome) ||
                other.monthlyIncome == monthlyIncome) &&
            (identical(other.annualIncome, annualIncome) ||
                other.annualIncome == annualIncome) &&
            (identical(other.incomeSource, incomeSource) ||
                other.incomeSource == incomeSource) &&
            (identical(other.familyMembers, familyMembers) ||
                other.familyMembers == familyMembers) &&
            (identical(other.familyIncome, familyIncome) ||
                other.familyIncome == familyIncome));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, monthlyIncome, annualIncome,
      incomeSource, familyMembers, familyIncome);

  /// Create a copy of IncomeDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IncomeDetailsImplCopyWith<_$IncomeDetailsImpl> get copyWith =>
      __$$IncomeDetailsImplCopyWithImpl<_$IncomeDetailsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IncomeDetailsImplToJson(
      this,
    );
  }
}

abstract class _IncomeDetails implements IncomeDetails {
  const factory _IncomeDetails(
      {required final double monthlyIncome,
      required final double annualIncome,
      required final String incomeSource,
      required final int familyMembers,
      required final double familyIncome}) = _$IncomeDetailsImpl;

  factory _IncomeDetails.fromJson(Map<String, dynamic> json) =
      _$IncomeDetailsImpl.fromJson;

  @override
  double get monthlyIncome;
  @override
  double get annualIncome;
  @override
  String get incomeSource;
  @override
  int get familyMembers;
  @override
  double get familyIncome;

  /// Create a copy of IncomeDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IncomeDetailsImplCopyWith<_$IncomeDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DocumentUpload _$DocumentUploadFromJson(Map<String, dynamic> json) {
  return _DocumentUpload.fromJson(json);
}

/// @nodoc
mixin _$DocumentUpload {
  DocumentType get documentType => throw _privateConstructorUsedError;
  String get documentName => throw _privateConstructorUsedError;
  String get base64Data => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;
  DateTime get uploadedAt => throw _privateConstructorUsedError;
  int get fileSize => throw _privateConstructorUsedError;

  /// Serializes this DocumentUpload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DocumentUpload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DocumentUploadCopyWith<DocumentUpload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentUploadCopyWith<$Res> {
  factory $DocumentUploadCopyWith(
          DocumentUpload value, $Res Function(DocumentUpload) then) =
      _$DocumentUploadCopyWithImpl<$Res, DocumentUpload>;
  @useResult
  $Res call(
      {DocumentType documentType,
      String documentName,
      String base64Data,
      String mimeType,
      DateTime uploadedAt,
      int fileSize});
}

/// @nodoc
class _$DocumentUploadCopyWithImpl<$Res, $Val extends DocumentUpload>
    implements $DocumentUploadCopyWith<$Res> {
  _$DocumentUploadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DocumentUpload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentType = null,
    Object? documentName = null,
    Object? base64Data = null,
    Object? mimeType = null,
    Object? uploadedAt = null,
    Object? fileSize = null,
  }) {
    return _then(_value.copyWith(
      documentType: null == documentType
          ? _value.documentType
          : documentType // ignore: cast_nullable_to_non_nullable
              as DocumentType,
      documentName: null == documentName
          ? _value.documentName
          : documentName // ignore: cast_nullable_to_non_nullable
              as String,
      base64Data: null == base64Data
          ? _value.base64Data
          : base64Data // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      uploadedAt: null == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentUploadImplCopyWith<$Res>
    implements $DocumentUploadCopyWith<$Res> {
  factory _$$DocumentUploadImplCopyWith(_$DocumentUploadImpl value,
          $Res Function(_$DocumentUploadImpl) then) =
      __$$DocumentUploadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DocumentType documentType,
      String documentName,
      String base64Data,
      String mimeType,
      DateTime uploadedAt,
      int fileSize});
}

/// @nodoc
class __$$DocumentUploadImplCopyWithImpl<$Res>
    extends _$DocumentUploadCopyWithImpl<$Res, _$DocumentUploadImpl>
    implements _$$DocumentUploadImplCopyWith<$Res> {
  __$$DocumentUploadImplCopyWithImpl(
      _$DocumentUploadImpl _value, $Res Function(_$DocumentUploadImpl) _then)
      : super(_value, _then);

  /// Create a copy of DocumentUpload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentType = null,
    Object? documentName = null,
    Object? base64Data = null,
    Object? mimeType = null,
    Object? uploadedAt = null,
    Object? fileSize = null,
  }) {
    return _then(_$DocumentUploadImpl(
      documentType: null == documentType
          ? _value.documentType
          : documentType // ignore: cast_nullable_to_non_nullable
              as DocumentType,
      documentName: null == documentName
          ? _value.documentName
          : documentName // ignore: cast_nullable_to_non_nullable
              as String,
      base64Data: null == base64Data
          ? _value.base64Data
          : base64Data // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: null == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String,
      uploadedAt: null == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentUploadImpl implements _DocumentUpload {
  const _$DocumentUploadImpl(
      {required this.documentType,
      required this.documentName,
      required this.base64Data,
      required this.mimeType,
      required this.uploadedAt,
      required this.fileSize});

  factory _$DocumentUploadImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentUploadImplFromJson(json);

  @override
  final DocumentType documentType;
  @override
  final String documentName;
  @override
  final String base64Data;
  @override
  final String mimeType;
  @override
  final DateTime uploadedAt;
  @override
  final int fileSize;

  @override
  String toString() {
    return 'DocumentUpload(documentType: $documentType, documentName: $documentName, base64Data: $base64Data, mimeType: $mimeType, uploadedAt: $uploadedAt, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentUploadImpl &&
            (identical(other.documentType, documentType) ||
                other.documentType == documentType) &&
            (identical(other.documentName, documentName) ||
                other.documentName == documentName) &&
            (identical(other.base64Data, base64Data) ||
                other.base64Data == base64Data) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, documentType, documentName,
      base64Data, mimeType, uploadedAt, fileSize);

  /// Create a copy of DocumentUpload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentUploadImplCopyWith<_$DocumentUploadImpl> get copyWith =>
      __$$DocumentUploadImplCopyWithImpl<_$DocumentUploadImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentUploadImplToJson(
      this,
    );
  }
}

abstract class _DocumentUpload implements DocumentUpload {
  const factory _DocumentUpload(
      {required final DocumentType documentType,
      required final String documentName,
      required final String base64Data,
      required final String mimeType,
      required final DateTime uploadedAt,
      required final int fileSize}) = _$DocumentUploadImpl;

  factory _DocumentUpload.fromJson(Map<String, dynamic> json) =
      _$DocumentUploadImpl.fromJson;

  @override
  DocumentType get documentType;
  @override
  String get documentName;
  @override
  String get base64Data;
  @override
  String get mimeType;
  @override
  DateTime get uploadedAt;
  @override
  int get fileSize;

  /// Create a copy of DocumentUpload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DocumentUploadImplCopyWith<_$DocumentUploadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubsidyApplicationRequest _$SubsidyApplicationRequestFromJson(
    Map<String, dynamic> json) {
  return _SubsidyApplicationRequest.fromJson(json);
}

/// @nodoc
mixin _$SubsidyApplicationRequest {
  SubsidyType get subsidyType => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get aadhaarNumber => throw _privateConstructorUsedError;
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  Gender get gender => throw _privateConstructorUsedError;
  Address get address => throw _privateConstructorUsedError;
  String get applicationReason => throw _privateConstructorUsedError;
  IncomeDetails get incomeDetails => throw _privateConstructorUsedError;
  List<DocumentUpload> get documents => throw _privateConstructorUsedError;

  /// Serializes this SubsidyApplicationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubsidyApplicationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubsidyApplicationRequestCopyWith<SubsidyApplicationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubsidyApplicationRequestCopyWith<$Res> {
  factory $SubsidyApplicationRequestCopyWith(SubsidyApplicationRequest value,
          $Res Function(SubsidyApplicationRequest) then) =
      _$SubsidyApplicationRequestCopyWithImpl<$Res, SubsidyApplicationRequest>;
  @useResult
  $Res call(
      {SubsidyType subsidyType,
      String fullName,
      String phone,
      String email,
      String aadhaarNumber,
      DateTime dateOfBirth,
      Gender gender,
      Address address,
      String applicationReason,
      IncomeDetails incomeDetails,
      List<DocumentUpload> documents});

  $AddressCopyWith<$Res> get address;
  $IncomeDetailsCopyWith<$Res> get incomeDetails;
}

/// @nodoc
class _$SubsidyApplicationRequestCopyWithImpl<$Res,
        $Val extends SubsidyApplicationRequest>
    implements $SubsidyApplicationRequestCopyWith<$Res> {
  _$SubsidyApplicationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubsidyApplicationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subsidyType = null,
    Object? fullName = null,
    Object? phone = null,
    Object? email = null,
    Object? aadhaarNumber = null,
    Object? dateOfBirth = null,
    Object? gender = null,
    Object? address = null,
    Object? applicationReason = null,
    Object? incomeDetails = null,
    Object? documents = null,
  }) {
    return _then(_value.copyWith(
      subsidyType: null == subsidyType
          ? _value.subsidyType
          : subsidyType // ignore: cast_nullable_to_non_nullable
              as SubsidyType,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      aadhaarNumber: null == aadhaarNumber
          ? _value.aadhaarNumber
          : aadhaarNumber // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: null == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address,
      applicationReason: null == applicationReason
          ? _value.applicationReason
          : applicationReason // ignore: cast_nullable_to_non_nullable
              as String,
      incomeDetails: null == incomeDetails
          ? _value.incomeDetails
          : incomeDetails // ignore: cast_nullable_to_non_nullable
              as IncomeDetails,
      documents: null == documents
          ? _value.documents
          : documents // ignore: cast_nullable_to_non_nullable
              as List<DocumentUpload>,
    ) as $Val);
  }

  /// Create a copy of SubsidyApplicationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AddressCopyWith<$Res> get address {
    return $AddressCopyWith<$Res>(_value.address, (value) {
      return _then(_value.copyWith(address: value) as $Val);
    });
  }

  /// Create a copy of SubsidyApplicationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IncomeDetailsCopyWith<$Res> get incomeDetails {
    return $IncomeDetailsCopyWith<$Res>(_value.incomeDetails, (value) {
      return _then(_value.copyWith(incomeDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SubsidyApplicationRequestImplCopyWith<$Res>
    implements $SubsidyApplicationRequestCopyWith<$Res> {
  factory _$$SubsidyApplicationRequestImplCopyWith(
          _$SubsidyApplicationRequestImpl value,
          $Res Function(_$SubsidyApplicationRequestImpl) then) =
      __$$SubsidyApplicationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SubsidyType subsidyType,
      String fullName,
      String phone,
      String email,
      String aadhaarNumber,
      DateTime dateOfBirth,
      Gender gender,
      Address address,
      String applicationReason,
      IncomeDetails incomeDetails,
      List<DocumentUpload> documents});

  @override
  $AddressCopyWith<$Res> get address;
  @override
  $IncomeDetailsCopyWith<$Res> get incomeDetails;
}

/// @nodoc
class __$$SubsidyApplicationRequestImplCopyWithImpl<$Res>
    extends _$SubsidyApplicationRequestCopyWithImpl<$Res,
        _$SubsidyApplicationRequestImpl>
    implements _$$SubsidyApplicationRequestImplCopyWith<$Res> {
  __$$SubsidyApplicationRequestImplCopyWithImpl(
      _$SubsidyApplicationRequestImpl _value,
      $Res Function(_$SubsidyApplicationRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubsidyApplicationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subsidyType = null,
    Object? fullName = null,
    Object? phone = null,
    Object? email = null,
    Object? aadhaarNumber = null,
    Object? dateOfBirth = null,
    Object? gender = null,
    Object? address = null,
    Object? applicationReason = null,
    Object? incomeDetails = null,
    Object? documents = null,
  }) {
    return _then(_$SubsidyApplicationRequestImpl(
      subsidyType: null == subsidyType
          ? _value.subsidyType
          : subsidyType // ignore: cast_nullable_to_non_nullable
              as SubsidyType,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      aadhaarNumber: null == aadhaarNumber
          ? _value.aadhaarNumber
          : aadhaarNumber // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: null == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address,
      applicationReason: null == applicationReason
          ? _value.applicationReason
          : applicationReason // ignore: cast_nullable_to_non_nullable
              as String,
      incomeDetails: null == incomeDetails
          ? _value.incomeDetails
          : incomeDetails // ignore: cast_nullable_to_non_nullable
              as IncomeDetails,
      documents: null == documents
          ? _value._documents
          : documents // ignore: cast_nullable_to_non_nullable
              as List<DocumentUpload>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubsidyApplicationRequestImpl implements _SubsidyApplicationRequest {
  const _$SubsidyApplicationRequestImpl(
      {required this.subsidyType,
      required this.fullName,
      required this.phone,
      required this.email,
      required this.aadhaarNumber,
      required this.dateOfBirth,
      required this.gender,
      required this.address,
      required this.applicationReason,
      required this.incomeDetails,
      required final List<DocumentUpload> documents})
      : _documents = documents;

  factory _$SubsidyApplicationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubsidyApplicationRequestImplFromJson(json);

  @override
  final SubsidyType subsidyType;
  @override
  final String fullName;
  @override
  final String phone;
  @override
  final String email;
  @override
  final String aadhaarNumber;
  @override
  final DateTime dateOfBirth;
  @override
  final Gender gender;
  @override
  final Address address;
  @override
  final String applicationReason;
  @override
  final IncomeDetails incomeDetails;
  final List<DocumentUpload> _documents;
  @override
  List<DocumentUpload> get documents {
    if (_documents is EqualUnmodifiableListView) return _documents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_documents);
  }

  @override
  String toString() {
    return 'SubsidyApplicationRequest(subsidyType: $subsidyType, fullName: $fullName, phone: $phone, email: $email, aadhaarNumber: $aadhaarNumber, dateOfBirth: $dateOfBirth, gender: $gender, address: $address, applicationReason: $applicationReason, incomeDetails: $incomeDetails, documents: $documents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubsidyApplicationRequestImpl &&
            (identical(other.subsidyType, subsidyType) ||
                other.subsidyType == subsidyType) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.aadhaarNumber, aadhaarNumber) ||
                other.aadhaarNumber == aadhaarNumber) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.applicationReason, applicationReason) ||
                other.applicationReason == applicationReason) &&
            (identical(other.incomeDetails, incomeDetails) ||
                other.incomeDetails == incomeDetails) &&
            const DeepCollectionEquality()
                .equals(other._documents, _documents));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      subsidyType,
      fullName,
      phone,
      email,
      aadhaarNumber,
      dateOfBirth,
      gender,
      address,
      applicationReason,
      incomeDetails,
      const DeepCollectionEquality().hash(_documents));

  /// Create a copy of SubsidyApplicationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubsidyApplicationRequestImplCopyWith<_$SubsidyApplicationRequestImpl>
      get copyWith => __$$SubsidyApplicationRequestImplCopyWithImpl<
          _$SubsidyApplicationRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubsidyApplicationRequestImplToJson(
      this,
    );
  }
}

abstract class _SubsidyApplicationRequest implements SubsidyApplicationRequest {
  const factory _SubsidyApplicationRequest(
          {required final SubsidyType subsidyType,
          required final String fullName,
          required final String phone,
          required final String email,
          required final String aadhaarNumber,
          required final DateTime dateOfBirth,
          required final Gender gender,
          required final Address address,
          required final String applicationReason,
          required final IncomeDetails incomeDetails,
          required final List<DocumentUpload> documents}) =
      _$SubsidyApplicationRequestImpl;

  factory _SubsidyApplicationRequest.fromJson(Map<String, dynamic> json) =
      _$SubsidyApplicationRequestImpl.fromJson;

  @override
  SubsidyType get subsidyType;
  @override
  String get fullName;
  @override
  String get phone;
  @override
  String get email;
  @override
  String get aadhaarNumber;
  @override
  DateTime get dateOfBirth;
  @override
  Gender get gender;
  @override
  Address get address;
  @override
  String get applicationReason;
  @override
  IncomeDetails get incomeDetails;
  @override
  List<DocumentUpload> get documents;

  /// Create a copy of SubsidyApplicationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubsidyApplicationRequestImplCopyWith<_$SubsidyApplicationRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
