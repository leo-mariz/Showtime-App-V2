// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
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
    return ensureInitialized()
        .decodeMap<FavoriteEnsembleEntity>(map);
  }

  static FavoriteEnsembleEntity fromJson(String json) {
    return ensureInitialized()
        .decodeJson<FavoriteEnsembleEntity>(json);
  }
}

mixin FavoriteEnsembleEntityMappable {
  Map<String, dynamic> toMap() {
    return FavoriteEnsembleEntityMapper.ensureInitialized()
        .encodeMap<FavoriteEnsembleEntity>(this as FavoriteEnsembleEntity);
  }

  @override
  String toString() {
    return FavoriteEnsembleEntityMapper.ensureInitialized()
        .stringifyValue(this as FavoriteEnsembleEntity);
  }

  @override
  bool operator ==(Object other) {
    return FavoriteEnsembleEntityMapper.ensureInitialized()
        .equalsValue(this as FavoriteEnsembleEntity, other);
  }

  @override
  int get hashCode {
    return FavoriteEnsembleEntityMapper.ensureInitialized()
        .hashValue(this as FavoriteEnsembleEntity);
  }
}
