// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'suspended_entity.dart';

class SuspendedEntityMapper extends ClassMapperBase<SuspendedEntity> {
  SuspendedEntityMapper._();

  static SuspendedEntityMapper? _instance;
  static SuspendedEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SuspendedEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SuspendedEntity';

  static DateTime? _$suspendedAt(SuspendedEntity v) => v.suspendedAt;
  static const Field<SuspendedEntity, DateTime> _f$suspendedAt = Field(
    'suspendedAt',
    _$suspendedAt,
    opt: true,
  );
  static DateTime? _$suspendedUntil(SuspendedEntity v) => v.suspendedUntil;
  static const Field<SuspendedEntity, DateTime> _f$suspendedUntil = Field(
    'suspendedUntil',
    _$suspendedUntil,
    opt: true,
  );
  static String? _$reason(SuspendedEntity v) => v.reason;
  static const Field<SuspendedEntity, String> _f$reason = Field(
    'reason',
    _$reason,
    opt: true,
  );
  static String? _$notes(SuspendedEntity v) => v.notes;
  static const Field<SuspendedEntity, String> _f$notes = Field(
    'notes',
    _$notes,
    opt: true,
  );
  static String? _$appliedByUid(SuspendedEntity v) => v.appliedByUid;
  static const Field<SuspendedEntity, String> _f$appliedByUid = Field(
    'appliedByUid',
    _$appliedByUid,
    opt: true,
  );

  @override
  final MappableFields<SuspendedEntity> fields = const {
    #suspendedAt: _f$suspendedAt,
    #suspendedUntil: _f$suspendedUntil,
    #reason: _f$reason,
    #notes: _f$notes,
    #appliedByUid: _f$appliedByUid,
  };

  static SuspendedEntity _instantiate(DecodingData data) {
    return SuspendedEntity(
      suspendedAt: data.dec(_f$suspendedAt),
      suspendedUntil: data.dec(_f$suspendedUntil),
      reason: data.dec(_f$reason),
      notes: data.dec(_f$notes),
      appliedByUid: data.dec(_f$appliedByUid),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SuspendedEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SuspendedEntity>(map);
  }

  static SuspendedEntity fromJson(String json) {
    return ensureInitialized().decodeJson<SuspendedEntity>(json);
  }
}

mixin SuspendedEntityMappable {
  String toJson() {
    return SuspendedEntityMapper.ensureInitialized()
        .encodeJson<SuspendedEntity>(this as SuspendedEntity);
  }

  Map<String, dynamic> toMap() {
    return SuspendedEntityMapper.ensureInitialized().encodeMap<SuspendedEntity>(
      this as SuspendedEntity,
    );
  }

  SuspendedEntityCopyWith<SuspendedEntity, SuspendedEntity, SuspendedEntity>
  get copyWith =>
      _SuspendedEntityCopyWithImpl<SuspendedEntity, SuspendedEntity>(
        this as SuspendedEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SuspendedEntityMapper.ensureInitialized().stringifyValue(
      this as SuspendedEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return SuspendedEntityMapper.ensureInitialized().equalsValue(
      this as SuspendedEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return SuspendedEntityMapper.ensureInitialized().hashValue(
      this as SuspendedEntity,
    );
  }
}

extension SuspendedEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SuspendedEntity, $Out> {
  SuspendedEntityCopyWith<$R, SuspendedEntity, $Out> get $asSuspendedEntity =>
      $base.as((v, t, t2) => _SuspendedEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SuspendedEntityCopyWith<$R, $In extends SuspendedEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    DateTime? suspendedAt,
    DateTime? suspendedUntil,
    String? reason,
    String? notes,
    String? appliedByUid,
  });
  SuspendedEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SuspendedEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SuspendedEntity, $Out>
    implements SuspendedEntityCopyWith<$R, SuspendedEntity, $Out> {
  _SuspendedEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SuspendedEntity> $mapper =
      SuspendedEntityMapper.ensureInitialized();
  @override
  $R call({
    Object? suspendedAt = $none,
    Object? suspendedUntil = $none,
    Object? reason = $none,
    Object? notes = $none,
    Object? appliedByUid = $none,
  }) => $apply(
    FieldCopyWithData({
      if (suspendedAt != $none) #suspendedAt: suspendedAt,
      if (suspendedUntil != $none) #suspendedUntil: suspendedUntil,
      if (reason != $none) #reason: reason,
      if (notes != $none) #notes: notes,
      if (appliedByUid != $none) #appliedByUid: appliedByUid,
    }),
  );
  @override
  SuspendedEntity $make(CopyWithData data) => SuspendedEntity(
    suspendedAt: data.get(#suspendedAt, or: $value.suspendedAt),
    suspendedUntil: data.get(#suspendedUntil, or: $value.suspendedUntil),
    reason: data.get(#reason, or: $value.reason),
    notes: data.get(#notes, or: $value.notes),
    appliedByUid: data.get(#appliedByUid, or: $value.appliedByUid),
  );

  @override
  SuspendedEntityCopyWith<$R2, SuspendedEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SuspendedEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

