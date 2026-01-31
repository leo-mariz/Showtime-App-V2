// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'support_request_entity.dart';

class SupportRequestEntityMapper extends ClassMapperBase<SupportRequestEntity> {
  SupportRequestEntityMapper._();

  static SupportRequestEntityMapper? _instance;
  static SupportRequestEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SupportRequestEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SupportRequestEntity';

  static String? _$id(SupportRequestEntity v) => v.id;
  static const Field<SupportRequestEntity, String> _f$id = Field(
    'id',
    _$id,
    opt: true,
  );
  static String _$userId(SupportRequestEntity v) => v.userId;
  static const Field<SupportRequestEntity, String> _f$userId = Field(
    'userId',
    _$userId,
  );
  static String _$name(SupportRequestEntity v) => v.name;
  static const Field<SupportRequestEntity, String> _f$name = Field(
    'name',
    _$name,
  );
  static String? _$userEmail(SupportRequestEntity v) => v.userEmail;
  static const Field<SupportRequestEntity, String> _f$userEmail = Field(
    'userEmail',
    _$userEmail,
    opt: true,
  );
  static String _$subject(SupportRequestEntity v) => v.subject;
  static const Field<SupportRequestEntity, String> _f$subject = Field(
    'subject',
    _$subject,
  );
  static String _$message(SupportRequestEntity v) => v.message;
  static const Field<SupportRequestEntity, String> _f$message = Field(
    'message',
    _$message,
  );
  static String? _$protocolNumber(SupportRequestEntity v) => v.protocolNumber;
  static const Field<SupportRequestEntity, String> _f$protocolNumber = Field(
    'protocolNumber',
    _$protocolNumber,
    opt: true,
  );
  static DateTime? _$createdAt(SupportRequestEntity v) => v.createdAt;
  static const Field<SupportRequestEntity, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    opt: true,
  );
  static String? _$status(SupportRequestEntity v) => v.status;
  static const Field<SupportRequestEntity, String> _f$status = Field(
    'status',
    _$status,
    opt: true,
  );
  static String? _$contractId(SupportRequestEntity v) => v.contractId;
  static const Field<SupportRequestEntity, String> _f$contractId = Field(
    'contractId',
    _$contractId,
    opt: true,
  );

  @override
  final MappableFields<SupportRequestEntity> fields = const {
    #id: _f$id,
    #userId: _f$userId,
    #name: _f$name,
    #userEmail: _f$userEmail,
    #subject: _f$subject,
    #message: _f$message,
    #protocolNumber: _f$protocolNumber,
    #createdAt: _f$createdAt,
    #status: _f$status,
    #contractId: _f$contractId,
  };

  static SupportRequestEntity _instantiate(DecodingData data) {
    return SupportRequestEntity(
      id: data.dec(_f$id),
      userId: data.dec(_f$userId),
      name: data.dec(_f$name),
      userEmail: data.dec(_f$userEmail),
      subject: data.dec(_f$subject),
      message: data.dec(_f$message),
      protocolNumber: data.dec(_f$protocolNumber),
      createdAt: data.dec(_f$createdAt),
      status: data.dec(_f$status),
      contractId: data.dec(_f$contractId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SupportRequestEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SupportRequestEntity>(map);
  }

  static SupportRequestEntity fromJson(String json) {
    return ensureInitialized().decodeJson<SupportRequestEntity>(json);
  }
}

mixin SupportRequestEntityMappable {
  String toJson() {
    return SupportRequestEntityMapper.ensureInitialized()
        .encodeJson<SupportRequestEntity>(this as SupportRequestEntity);
  }

  Map<String, dynamic> toMap() {
    return SupportRequestEntityMapper.ensureInitialized()
        .encodeMap<SupportRequestEntity>(this as SupportRequestEntity);
  }

  SupportRequestEntityCopyWith<
    SupportRequestEntity,
    SupportRequestEntity,
    SupportRequestEntity
  >
  get copyWith =>
      _SupportRequestEntityCopyWithImpl<
        SupportRequestEntity,
        SupportRequestEntity
      >(this as SupportRequestEntity, $identity, $identity);
  @override
  String toString() {
    return SupportRequestEntityMapper.ensureInitialized().stringifyValue(
      this as SupportRequestEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return SupportRequestEntityMapper.ensureInitialized().equalsValue(
      this as SupportRequestEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return SupportRequestEntityMapper.ensureInitialized().hashValue(
      this as SupportRequestEntity,
    );
  }
}

extension SupportRequestEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SupportRequestEntity, $Out> {
  SupportRequestEntityCopyWith<$R, SupportRequestEntity, $Out>
  get $asSupportRequestEntity => $base.as(
    (v, t, t2) => _SupportRequestEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class SupportRequestEntityCopyWith<
  $R,
  $In extends SupportRequestEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? userId,
    String? name,
    String? userEmail,
    String? subject,
    String? message,
    String? protocolNumber,
    DateTime? createdAt,
    String? status,
    String? contractId,
  });
  SupportRequestEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SupportRequestEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SupportRequestEntity, $Out>
    implements SupportRequestEntityCopyWith<$R, SupportRequestEntity, $Out> {
  _SupportRequestEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SupportRequestEntity> $mapper =
      SupportRequestEntityMapper.ensureInitialized();
  @override
  $R call({
    Object? id = $none,
    String? userId,
    String? name,
    Object? userEmail = $none,
    String? subject,
    String? message,
    Object? protocolNumber = $none,
    Object? createdAt = $none,
    Object? status = $none,
    Object? contractId = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (userId != null) #userId: userId,
      if (name != null) #name: name,
      if (userEmail != $none) #userEmail: userEmail,
      if (subject != null) #subject: subject,
      if (message != null) #message: message,
      if (protocolNumber != $none) #protocolNumber: protocolNumber,
      if (createdAt != $none) #createdAt: createdAt,
      if (status != $none) #status: status,
      if (contractId != $none) #contractId: contractId,
    }),
  );
  @override
  SupportRequestEntity $make(CopyWithData data) => SupportRequestEntity(
    id: data.get(#id, or: $value.id),
    userId: data.get(#userId, or: $value.userId),
    name: data.get(#name, or: $value.name),
    userEmail: data.get(#userEmail, or: $value.userEmail),
    subject: data.get(#subject, or: $value.subject),
    message: data.get(#message, or: $value.message),
    protocolNumber: data.get(#protocolNumber, or: $value.protocolNumber),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    status: data.get(#status, or: $value.status),
    contractId: data.get(#contractId, or: $value.contractId),
  );

  @override
  SupportRequestEntityCopyWith<$R2, SupportRequestEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SupportRequestEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

