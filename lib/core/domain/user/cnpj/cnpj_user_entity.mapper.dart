// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cnpj_user_entity.dart';

class CnpjUserEntityMapper extends ClassMapperBase<CnpjUserEntity> {
  CnpjUserEntityMapper._();

  static CnpjUserEntityMapper? _instance;
  static CnpjUserEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CnpjUserEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CnpjUserEntity';

  static String? _$cnpj(CnpjUserEntity v) => v.cnpj;
  static const Field<CnpjUserEntity, String> _f$cnpj = Field(
    'cnpj',
    _$cnpj,
    opt: true,
  );
  static String? _$companyName(CnpjUserEntity v) => v.companyName;
  static const Field<CnpjUserEntity, String> _f$companyName = Field(
    'companyName',
    _$companyName,
    opt: true,
  );
  static String? _$fantasyName(CnpjUserEntity v) => v.fantasyName;
  static const Field<CnpjUserEntity, String> _f$fantasyName = Field(
    'fantasyName',
    _$fantasyName,
    opt: true,
  );
  static String? _$stateRegistration(CnpjUserEntity v) => v.stateRegistration;
  static const Field<CnpjUserEntity, String> _f$stateRegistration = Field(
    'stateRegistration',
    _$stateRegistration,
    opt: true,
  );

  @override
  final MappableFields<CnpjUserEntity> fields = const {
    #cnpj: _f$cnpj,
    #companyName: _f$companyName,
    #fantasyName: _f$fantasyName,
    #stateRegistration: _f$stateRegistration,
  };

  static CnpjUserEntity _instantiate(DecodingData data) {
    return CnpjUserEntity(
      cnpj: data.dec(_f$cnpj),
      companyName: data.dec(_f$companyName),
      fantasyName: data.dec(_f$fantasyName),
      stateRegistration: data.dec(_f$stateRegistration),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CnpjUserEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CnpjUserEntity>(map);
  }

  static CnpjUserEntity fromJson(String json) {
    return ensureInitialized().decodeJson<CnpjUserEntity>(json);
  }
}

mixin CnpjUserEntityMappable {
  String toJson() {
    return CnpjUserEntityMapper.ensureInitialized().encodeJson<CnpjUserEntity>(
      this as CnpjUserEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return CnpjUserEntityMapper.ensureInitialized().encodeMap<CnpjUserEntity>(
      this as CnpjUserEntity,
    );
  }

  CnpjUserEntityCopyWith<CnpjUserEntity, CnpjUserEntity, CnpjUserEntity>
  get copyWith => _CnpjUserEntityCopyWithImpl<CnpjUserEntity, CnpjUserEntity>(
    this as CnpjUserEntity,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return CnpjUserEntityMapper.ensureInitialized().stringifyValue(
      this as CnpjUserEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return CnpjUserEntityMapper.ensureInitialized().equalsValue(
      this as CnpjUserEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return CnpjUserEntityMapper.ensureInitialized().hashValue(
      this as CnpjUserEntity,
    );
  }
}

extension CnpjUserEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CnpjUserEntity, $Out> {
  CnpjUserEntityCopyWith<$R, CnpjUserEntity, $Out> get $asCnpjUserEntity =>
      $base.as((v, t, t2) => _CnpjUserEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CnpjUserEntityCopyWith<$R, $In extends CnpjUserEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? cnpj,
    String? companyName,
    String? fantasyName,
    String? stateRegistration,
  });
  CnpjUserEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CnpjUserEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CnpjUserEntity, $Out>
    implements CnpjUserEntityCopyWith<$R, CnpjUserEntity, $Out> {
  _CnpjUserEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CnpjUserEntity> $mapper =
      CnpjUserEntityMapper.ensureInitialized();
  @override
  $R call({
    Object? cnpj = $none,
    Object? companyName = $none,
    Object? fantasyName = $none,
    Object? stateRegistration = $none,
  }) => $apply(
    FieldCopyWithData({
      if (cnpj != $none) #cnpj: cnpj,
      if (companyName != $none) #companyName: companyName,
      if (fantasyName != $none) #fantasyName: fantasyName,
      if (stateRegistration != $none) #stateRegistration: stateRegistration,
    }),
  );
  @override
  CnpjUserEntity $make(CopyWithData data) => CnpjUserEntity(
    cnpj: data.get(#cnpj, or: $value.cnpj),
    companyName: data.get(#companyName, or: $value.companyName),
    fantasyName: data.get(#fantasyName, or: $value.fantasyName),
    stateRegistration: data.get(
      #stateRegistration,
      or: $value.stateRegistration,
    ),
  );

  @override
  CnpjUserEntityCopyWith<$R2, CnpjUserEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CnpjUserEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

