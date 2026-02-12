// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'favorite_ensemble_entity.dart';

class FavoriteEnsembleEntityMapper
    extends ClassMapperBase<FavoriteEnsembleEntity> {
  FavoriteEnsembleEntityMapper._();

  static FavoriteEnsembleEntityMapper? _instance;
  static FavoriteEnsembleEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FavoriteEnsembleEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'FavoriteEnsembleEntity';

  static String _$ensembleId(FavoriteEnsembleEntity v) => v.ensembleId;
  static const Field<FavoriteEnsembleEntity, String> _f$ensembleId = Field(
    'ensembleId',
    _$ensembleId,
  );
  static DateTime _$addedAt(FavoriteEnsembleEntity v) => v.addedAt;
  static const Field<FavoriteEnsembleEntity, DateTime> _f$addedAt = Field(
    'addedAt',
    _$addedAt,
    opt: true,
  );

  @override
  final MappableFields<FavoriteEnsembleEntity> fields = const {
    #ensembleId: _f$ensembleId,
    #addedAt: _f$addedAt,
  };

  static FavoriteEnsembleEntity _instantiate(DecodingData data) {
    return FavoriteEnsembleEntity(
      ensembleId: data.dec(_f$ensembleId),
      addedAt: data.dec(_f$addedAt),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FavoriteEnsembleEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FavoriteEnsembleEntity>(map);
  }

  static FavoriteEnsembleEntity fromJson(String json) {
    return ensureInitialized().decodeJson<FavoriteEnsembleEntity>(json);
  }
}

mixin FavoriteEnsembleEntityMappable {
  String toJson() {
    return FavoriteEnsembleEntityMapper.ensureInitialized()
        .encodeJson<FavoriteEnsembleEntity>(this as FavoriteEnsembleEntity);
  }

  Map<String, dynamic> toMap() {
    return FavoriteEnsembleEntityMapper.ensureInitialized()
        .encodeMap<FavoriteEnsembleEntity>(this as FavoriteEnsembleEntity);
  }

  FavoriteEnsembleEntityCopyWith<
    FavoriteEnsembleEntity,
    FavoriteEnsembleEntity,
    FavoriteEnsembleEntity
  >
  get copyWith =>
      _FavoriteEnsembleEntityCopyWithImpl<
        FavoriteEnsembleEntity,
        FavoriteEnsembleEntity
      >(this as FavoriteEnsembleEntity, $identity, $identity);
  @override
  String toString() {
    return FavoriteEnsembleEntityMapper.ensureInitialized().stringifyValue(
      this as FavoriteEnsembleEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return FavoriteEnsembleEntityMapper.ensureInitialized().equalsValue(
      this as FavoriteEnsembleEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return FavoriteEnsembleEntityMapper.ensureInitialized().hashValue(
      this as FavoriteEnsembleEntity,
    );
  }
}

extension FavoriteEnsembleEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FavoriteEnsembleEntity, $Out> {
  FavoriteEnsembleEntityCopyWith<$R, FavoriteEnsembleEntity, $Out>
  get $asFavoriteEnsembleEntity => $base.as(
    (v, t, t2) => _FavoriteEnsembleEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class FavoriteEnsembleEntityCopyWith<
  $R,
  $In extends FavoriteEnsembleEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? ensembleId, DateTime? addedAt});
  FavoriteEnsembleEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FavoriteEnsembleEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FavoriteEnsembleEntity, $Out>
    implements
        FavoriteEnsembleEntityCopyWith<$R, FavoriteEnsembleEntity, $Out> {
  _FavoriteEnsembleEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FavoriteEnsembleEntity> $mapper =
      FavoriteEnsembleEntityMapper.ensureInitialized();
  @override
  $R call({String? ensembleId, Object? addedAt = $none}) => $apply(
    FieldCopyWithData({
      if (ensembleId != null) #ensembleId: ensembleId,
      if (addedAt != $none) #addedAt: addedAt,
    }),
  );
  @override
  FavoriteEnsembleEntity $make(CopyWithData data) => FavoriteEnsembleEntity(
    ensembleId: data.get(#ensembleId, or: $value.ensembleId),
    addedAt: data.get(#addedAt, or: $value.addedAt),
  );

  @override
  FavoriteEnsembleEntityCopyWith<$R2, FavoriteEnsembleEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _FavoriteEnsembleEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

