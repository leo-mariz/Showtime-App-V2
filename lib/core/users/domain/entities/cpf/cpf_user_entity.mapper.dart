// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cpf_user_entity.dart';

class CpfUserEntityMapper extends ClassMapperBase<CpfUserEntity> {
  CpfUserEntityMapper._();

  static CpfUserEntityMapper? _instance;
  static CpfUserEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CpfUserEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CpfUserEntity';

  static String? _$cpf(CpfUserEntity v) => v.cpf;
  static const Field<CpfUserEntity, String> _f$cpf = Field(
    'cpf',
    _$cpf,
    opt: true,
  );
  static String? _$firstName(CpfUserEntity v) => v.firstName;
  static const Field<CpfUserEntity, String> _f$firstName = Field(
    'firstName',
    _$firstName,
    opt: true,
  );
  static String? _$lastName(CpfUserEntity v) => v.lastName;
  static const Field<CpfUserEntity, String> _f$lastName = Field(
    'lastName',
    _$lastName,
    opt: true,
  );
  static String? _$birthDate(CpfUserEntity v) => v.birthDate;
  static const Field<CpfUserEntity, String> _f$birthDate = Field(
    'birthDate',
    _$birthDate,
    opt: true,
  );
  static String? _$gender(CpfUserEntity v) => v.gender;
  static const Field<CpfUserEntity, String> _f$gender = Field(
    'gender',
    _$gender,
    opt: true,
  );

  @override
  final MappableFields<CpfUserEntity> fields = const {
    #cpf: _f$cpf,
    #firstName: _f$firstName,
    #lastName: _f$lastName,
    #birthDate: _f$birthDate,
    #gender: _f$gender,
  };

  static CpfUserEntity _instantiate(DecodingData data) {
    return CpfUserEntity(
      cpf: data.dec(_f$cpf),
      firstName: data.dec(_f$firstName),
      lastName: data.dec(_f$lastName),
      birthDate: data.dec(_f$birthDate),
      gender: data.dec(_f$gender),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CpfUserEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CpfUserEntity>(map);
  }

  static CpfUserEntity fromJson(String json) {
    return ensureInitialized().decodeJson<CpfUserEntity>(json);
  }
}

mixin CpfUserEntityMappable {
  String toJson() {
    return CpfUserEntityMapper.ensureInitialized().encodeJson<CpfUserEntity>(
      this as CpfUserEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return CpfUserEntityMapper.ensureInitialized().encodeMap<CpfUserEntity>(
      this as CpfUserEntity,
    );
  }

  CpfUserEntityCopyWith<CpfUserEntity, CpfUserEntity, CpfUserEntity>
  get copyWith => _CpfUserEntityCopyWithImpl<CpfUserEntity, CpfUserEntity>(
    this as CpfUserEntity,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return CpfUserEntityMapper.ensureInitialized().stringifyValue(
      this as CpfUserEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return CpfUserEntityMapper.ensureInitialized().equalsValue(
      this as CpfUserEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return CpfUserEntityMapper.ensureInitialized().hashValue(
      this as CpfUserEntity,
    );
  }
}

extension CpfUserEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CpfUserEntity, $Out> {
  CpfUserEntityCopyWith<$R, CpfUserEntity, $Out> get $asCpfUserEntity =>
      $base.as((v, t, t2) => _CpfUserEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CpfUserEntityCopyWith<$R, $In extends CpfUserEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? cpf,
    String? firstName,
    String? lastName,
    String? birthDate,
    String? gender,
  });
  CpfUserEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CpfUserEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CpfUserEntity, $Out>
    implements CpfUserEntityCopyWith<$R, CpfUserEntity, $Out> {
  _CpfUserEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CpfUserEntity> $mapper =
      CpfUserEntityMapper.ensureInitialized();
  @override
  $R call({
    Object? cpf = $none,
    Object? firstName = $none,
    Object? lastName = $none,
    Object? birthDate = $none,
    Object? gender = $none,
  }) => $apply(
    FieldCopyWithData({
      if (cpf != $none) #cpf: cpf,
      if (firstName != $none) #firstName: firstName,
      if (lastName != $none) #lastName: lastName,
      if (birthDate != $none) #birthDate: birthDate,
      if (gender != $none) #gender: gender,
    }),
  );
  @override
  CpfUserEntity $make(CopyWithData data) => CpfUserEntity(
    cpf: data.get(#cpf, or: $value.cpf),
    firstName: data.get(#firstName, or: $value.firstName),
    lastName: data.get(#lastName, or: $value.lastName),
    birthDate: data.get(#birthDate, or: $value.birthDate),
    gender: data.get(#gender, or: $value.gender),
  );

  @override
  CpfUserEntityCopyWith<$R2, CpfUserEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CpfUserEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

