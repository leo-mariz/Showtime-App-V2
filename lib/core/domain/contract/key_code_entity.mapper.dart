// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'key_code_entity.dart';

class ConfirmationEntityMapper extends ClassMapperBase<ConfirmationEntity> {
  ConfirmationEntityMapper._();

  static ConfirmationEntityMapper? _instance;
  static ConfirmationEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ConfirmationEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ConfirmationEntity';

  static String _$keyCode(ConfirmationEntity v) => v.keyCode;
  static const Field<ConfirmationEntity, String> _f$keyCode = Field(
    'keyCode',
    _$keyCode,
  );
  static DateTime _$createdAt(ConfirmationEntity v) => v.createdAt;
  static const Field<ConfirmationEntity, DateTime> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
  );

  @override
  final MappableFields<ConfirmationEntity> fields = const {
    #keyCode: _f$keyCode,
    #createdAt: _f$createdAt,
  };

  static ConfirmationEntity _instantiate(DecodingData data) {
    return ConfirmationEntity(
      keyCode: data.dec(_f$keyCode),
      createdAt: data.dec(_f$createdAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ConfirmationEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ConfirmationEntity>(map);
  }

  static ConfirmationEntity fromJson(String json) {
    return ensureInitialized().decodeJson<ConfirmationEntity>(json);
  }
}

mixin ConfirmationEntityMappable {
  String toJson() {
    return ConfirmationEntityMapper.ensureInitialized()
        .encodeJson<ConfirmationEntity>(this as ConfirmationEntity);
  }

  Map<String, dynamic> toMap() {
    return ConfirmationEntityMapper.ensureInitialized()
        .encodeMap<ConfirmationEntity>(this as ConfirmationEntity);
  }

  ConfirmationEntityCopyWith<
    ConfirmationEntity,
    ConfirmationEntity,
    ConfirmationEntity
  >
  get copyWith =>
      _ConfirmationEntityCopyWithImpl<ConfirmationEntity, ConfirmationEntity>(
        this as ConfirmationEntity,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ConfirmationEntityMapper.ensureInitialized().stringifyValue(
      this as ConfirmationEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return ConfirmationEntityMapper.ensureInitialized().equalsValue(
      this as ConfirmationEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return ConfirmationEntityMapper.ensureInitialized().hashValue(
      this as ConfirmationEntity,
    );
  }
}

extension ConfirmationEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ConfirmationEntity, $Out> {
  ConfirmationEntityCopyWith<$R, ConfirmationEntity, $Out>
  get $asConfirmationEntity => $base.as(
    (v, t, t2) => _ConfirmationEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class ConfirmationEntityCopyWith<
  $R,
  $In extends ConfirmationEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? keyCode, DateTime? createdAt});
  ConfirmationEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ConfirmationEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ConfirmationEntity, $Out>
    implements ConfirmationEntityCopyWith<$R, ConfirmationEntity, $Out> {
  _ConfirmationEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ConfirmationEntity> $mapper =
      ConfirmationEntityMapper.ensureInitialized();
  @override
  $R call({String? keyCode, DateTime? createdAt}) => $apply(
    FieldCopyWithData({
      if (keyCode != null) #keyCode: keyCode,
      if (createdAt != null) #createdAt: createdAt,
    }),
  );
  @override
  ConfirmationEntity $make(CopyWithData data) => ConfirmationEntity(
    keyCode: data.get(#keyCode, or: $value.keyCode),
    createdAt: data.get(#createdAt, or: $value.createdAt),
  );

  @override
  ConfirmationEntityCopyWith<$R2, ConfirmationEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ConfirmationEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

