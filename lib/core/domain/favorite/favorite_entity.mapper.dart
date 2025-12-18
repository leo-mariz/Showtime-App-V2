// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'favorite_entity.dart';

class FavoriteEntityMapper extends ClassMapperBase<FavoriteEntity> {
  FavoriteEntityMapper._();

  static FavoriteEntityMapper? _instance;
  static FavoriteEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FavoriteEntityMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'FavoriteEntity';

  static String _$uid(FavoriteEntity v) => v.uid;
  static const Field<FavoriteEntity, String> _f$uid = Field('uid', _$uid);
  static String _$artistId(FavoriteEntity v) => v.artistId;
  static const Field<FavoriteEntity, String> _f$artistId = Field(
    'artistId',
    _$artistId,
  );
  static String _$userId(FavoriteEntity v) => v.userId;
  static const Field<FavoriteEntity, String> _f$userId = Field(
    'userId',
    _$userId,
  );

  @override
  final MappableFields<FavoriteEntity> fields = const {
    #uid: _f$uid,
    #artistId: _f$artistId,
    #userId: _f$userId,
  };

  static FavoriteEntity _instantiate(DecodingData data) {
    return FavoriteEntity(
      uid: data.dec(_f$uid),
      artistId: data.dec(_f$artistId),
      userId: data.dec(_f$userId),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FavoriteEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FavoriteEntity>(map);
  }

  static FavoriteEntity fromJson(String json) {
    return ensureInitialized().decodeJson<FavoriteEntity>(json);
  }
}

mixin FavoriteEntityMappable {
  String toJson() {
    return FavoriteEntityMapper.ensureInitialized().encodeJson<FavoriteEntity>(
      this as FavoriteEntity,
    );
  }

  Map<String, dynamic> toMap() {
    return FavoriteEntityMapper.ensureInitialized().encodeMap<FavoriteEntity>(
      this as FavoriteEntity,
    );
  }

  FavoriteEntityCopyWith<FavoriteEntity, FavoriteEntity, FavoriteEntity>
  get copyWith => _FavoriteEntityCopyWithImpl<FavoriteEntity, FavoriteEntity>(
    this as FavoriteEntity,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return FavoriteEntityMapper.ensureInitialized().stringifyValue(
      this as FavoriteEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return FavoriteEntityMapper.ensureInitialized().equalsValue(
      this as FavoriteEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return FavoriteEntityMapper.ensureInitialized().hashValue(
      this as FavoriteEntity,
    );
  }
}

extension FavoriteEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FavoriteEntity, $Out> {
  FavoriteEntityCopyWith<$R, FavoriteEntity, $Out> get $asFavoriteEntity =>
      $base.as((v, t, t2) => _FavoriteEntityCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FavoriteEntityCopyWith<$R, $In extends FavoriteEntity, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? uid, String? artistId, String? userId});
  FavoriteEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FavoriteEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FavoriteEntity, $Out>
    implements FavoriteEntityCopyWith<$R, FavoriteEntity, $Out> {
  _FavoriteEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FavoriteEntity> $mapper =
      FavoriteEntityMapper.ensureInitialized();
  @override
  $R call({String? uid, String? artistId, String? userId}) => $apply(
    FieldCopyWithData({
      if (uid != null) #uid: uid,
      if (artistId != null) #artistId: artistId,
      if (userId != null) #userId: userId,
    }),
  );
  @override
  FavoriteEntity $make(CopyWithData data) => FavoriteEntity(
    uid: data.get(#uid, or: $value.uid),
    artistId: data.get(#artistId, or: $value.artistId),
    userId: data.get(#userId, or: $value.userId),
  );

  @override
  FavoriteEntityCopyWith<$R2, FavoriteEntity, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FavoriteEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

